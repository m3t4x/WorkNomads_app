import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:worknomads/core/constants/app_colors.dart';
import 'package:worknomads/core/constants/app_text_styles.dart';
import 'package:worknomads/core/providers/theme_provider.dart';
import 'package:worknomads/core/services/service_locator.dart';
import 'package:worknomads/core/services/media_service.dart';
import 'package:worknomads/core/services/api_controller.dart';
import 'package:worknomads/core/models/media_file.dart';
import 'package:worknomads/core/widgets/three_finger_tap_detector.dart';
import '../auth/login_screen.dart';

// Home screen with media gallery
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<MediaFile> _mediaFiles = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String _selectedFilter = 'all'; // all, image, audio

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMedia();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);
    
    try {
      final mediaService = getIt<MediaService>();
      final files = await mediaService.getMediaList();
      
      if (mounted) {
        setState(() {
          _mediaFiles = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load media: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await _uploadFile(File(image.path), isImage: true);
    }
  }

  Future<void> _uploadAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.path != null) {
      await _uploadFile(File(result.files.single.path!), isImage: false);
    }
  }

  Future<void> _uploadFile(File file, {required bool isImage}) async {
    setState(() => _isUploading = true);
    
    try {
      final mediaService = getIt<MediaService>();
      final MediaFile uploadedFile;
      
      if (isImage) {
        uploadedFile = await mediaService.uploadImage(file);
      } else {
        uploadedFile = await mediaService.uploadAudio(file);
      }
      
      if (mounted) {
        setState(() {
          _mediaFiles.insert(0, uploadedFile);
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final api = getIt<ApiController>();
      await api.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    }
  }

  List<MediaFile> get _filteredFiles {
    switch (_selectedFilter) {
      case 'image':
        return _mediaFiles.where((f) => f.isImage).toList();
      case 'audio':
        return _mediaFiles.where((f) => f.isAudio).toList();
      default:
        return _mediaFiles;
    }
  }

  Future<void> _showApiConfigDialog(BuildContext context) async {
    final api = getIt<ApiController>();
    final media = getIt<MediaService>();
    final authController = TextEditingController(text: api.baseUrl);
    final mediaController = TextEditingController(text: media.mediaBaseUrl);
    
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('API Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: authController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Auth API URL',
                  hintText: 'http://localhost:8001',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mediaController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Media API URL',
                  hintText: 'http://localhost:8002',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await api.setBaseUrl(authController.text);
                media.setMediaBaseUrl(mediaController.text);
                if (mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ThreeFingerTapDetector(
          onTripleTap: () => _showApiConfigDialog(context),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Gallery',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                // Theme toggle
                IconButton(
                  tooltip: themeProvider.isDarkMode ? 'Switch to Light' : 'Switch to Dark',
                  onPressed: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: themeProvider.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _logout,
                  icon: Icon(Icons.logout, color: themeProvider.isDarkMode ? AppColors.darkError : AppColors.lightError,),
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Filter tabs
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        SizedBox(width: 8.w),
                        _buildFilterChip('Images', 'image'),
                        SizedBox(width: 8.w),
                        _buildFilterChip('Audio', 'audio'),
                        const Spacer(),
                        Text(
                          '${_filteredFiles.length} items',
                          style: AppTextStyles.bodySmall
                        ),
                      ],
                    ),
                  ),
                  
                  // Media grid
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredFiles.isEmpty
                            ? _buildEmptyState()
                            : _buildMediaGrid(),
                  ),
                ],
              ),
            ),
            floatingActionButton: _isUploading
                ? FloatingActionButton(
                    onPressed: null,
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkSurface,),
                    ),
                  )
                : _buildUploadFAB(),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = value;
            });
          },
          selectedColor: themeProvider.isDarkMode
              ? AppColors.darkPrimary
              : AppColors.lightPrimary,
          checkmarkColor: themeProvider.isDarkMode
              ? AppColors.lightPrimary
              : AppColors.darkPrimary,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No media files yet',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Opacity(
            opacity: 0.7,
            child: Text(
              'Upload your first image or audio file',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return RefreshIndicator(
      onRefresh: _loadMedia,
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.w,
          childAspectRatio: 1.0,
        ),
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          final file = _filteredFiles[index];
          return _buildMediaCard(file);
        },
      ),
    );
  }

  Widget _buildMediaCard(MediaFile file) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return InkWell(
          onTap: () {
            if (file.isAudio) {
              _openAudioPlayer(file);
            } else if (file.isImage) {
              _openImageViewer(file);
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? AppColors.darkSurface
                  : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.lightPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Expanded(
                    child: file.isImage
                        ? Image.network(
                            file.url,
                            fit: BoxFit.cover,
                            headers: getIt<ApiController>().accessToken != null
                                ? {
                                    'Authorization': 'Bearer ${getIt<ApiController>().accessToken}'
                                  }
                                : null,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 48),
                              );
                            },
                          )
                        : Container(
                            color: themeProvider.isDarkMode
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.audiotrack,
                                  size: 48.sp,
                                  color: Theme.of(context).scaffoldBackgroundColor
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Audio',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).scaffoldBackgroundColor
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.originalFilename,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      file.formattedSize,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      _formatDate(file.createdAt),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Delete action moved to overlay icon (top-right)
                      ],
                    ),
                  ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await _confirmAndDelete(file);
                        },
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          radius: 16,
                          child: const Icon(Icons.delete, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadFAB() {
    return FloatingActionButton(
      onPressed: () => _showUploadOptions(),
      child: const Icon(Icons.add),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Media',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Upload Image'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('Upload Audio'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadAudio();
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _openImageViewer(MediaFile file) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) {
        return Stack(
          children: [
            // Blurred background of current content
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned.fill(
              child:
              InteractiveViewer(
                minScale: 0.1,
                maxScale: 4.0,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    file.url,
                    fit: BoxFit.contain,
                    headers: getIt<ApiController>().accessToken != null
                        ? {
                            'Authorization': 'Bearer ${getIt<ApiController>().accessToken}'
                          }
                        : null,
                  ),
                ),
              )
            ),
            Positioned(
              top: 20,
              right: 16.w,
              child: IconButton(
                icon:  Icon(Icons.close, color: Colors.white, size: 32.sp,),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAudioPlayer(MediaFile file) async {
    // Ensure audio session is configured (important on iOS)
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    final player = AudioPlayer();
    Duration position = Duration.zero;
    Duration duration = Duration.zero;
    bool isPlaying = false;
    String? localPath; // downloaded file path for secured audio
    bool isDownloading = false;
    bool startedDownload = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        player.onDurationChanged.listen((d) {
          duration = d;
        });
        player.onPositionChanged.listen((p) {
          position = p;
        });
        player.onPlayerStateChanged.listen((state) {
          isPlaying = state == PlayerState.playing;
        });

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Kick off download immediately when sheet opens (mobile/desktop only)
            if (!kIsWeb && localPath == null && !startedDownload) {
              startedDownload = true;
              () async {
                try {
                  setModalState(() => isDownloading = true);
                  final token = getIt<ApiController>().accessToken;
                  final tempDir = await getTemporaryDirectory();
                  // Prefer keeping a valid extension for iOS AVPlayer compatibility
                  String inferredName = file.originalFilename;
                  if (inferredName.trim().isEmpty || !inferredName.contains('.')) {
                    final uri = Uri.tryParse(file.url);
                    final last = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : '';
                    if (last.contains('.')) {
                      inferredName = last;
                    } else {
                      inferredName = 'audio_${file.id}.mp3'; // sensible default
                    }
                  }
                  final fileName = 'media_${file.id}_${DateTime.now().millisecondsSinceEpoch}_${inferredName}';
                  final savePath = '${tempDir.path}/$fileName';
                  final client = dio.Dio();
                  await client.download(
                    file.url,
                    savePath,
                    options: dio.Options(
                      responseType: dio.ResponseType.bytes,
                      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
                    ),
                  );
                  if (mounted) {
                    setModalState(() {
                      localPath = savePath;
                      isDownloading = false;
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    setModalState(() => isDownloading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Unable to download audio. Please try again.', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                        backgroundColor: AppColors.lightError,
                      ),
                    );
                  }
                }
              }();
            }
            Future<void> _play() async {
              if (isDownloading) return; // guard double click during download
              try {
                final token = getIt<ApiController>().accessToken;
                if (kIsWeb) {
                  // Web cannot attach custom headers to audio element reliably; requires CORS/public URL
                  await player.play(UrlSource(file.url));
                } else {
                  // Download to a local temp file with headers, then play from device
                  if (localPath == null) {
                    setModalState(() => isDownloading = true);
                    final tempDir = await getTemporaryDirectory();
                    // Prefer keeping a valid extension for iOS AVPlayer compatibility
                    String inferredName = file.originalFilename;
                    if (inferredName.trim().isEmpty || !inferredName.contains('.')) {
                      final uri = Uri.tryParse(file.url);
                      final last = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : '';
                      if (last.contains('.')) {
                        inferredName = last;
                      } else {
                        inferredName = 'audio_${file.id}.mp3';
                      }
                    }
                    final fileName = 'media_${file.id}_${DateTime.now().millisecondsSinceEpoch}_${inferredName}';
                    final savePath = '${tempDir.path}/$fileName';
                    final client = dio.Dio();
                    await client.download(
                      file.url,
                      savePath,
                      options: dio.Options(
                        responseType: dio.ResponseType.bytes,
                        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
                      ),
                    );
                    localPath = savePath;
                    setModalState(() => isDownloading = false);
                  }
                  // Ensure file exists and is not empty before playing
                  final f = File(localPath!);
                  if (await f.exists() && (await f.length()) > 0) {
                    try {
                      await player.play(DeviceFileSource(localPath!));
                    } catch (e) {
                      // Fallback: try direct URL with headers (iOS can attach headers in UrlSource)
                      final token = getIt<ApiController>().accessToken;
                      await player.play(UrlSource(
                        file.url,
                      ));
                    }
                  } else {
                    // Fallback to URL if local file invalid
                    final token = getIt<ApiController>().accessToken;
                    await player.play(UrlSource(
                      file.url,
                    ));
                  }
                }
                setModalState(() {});
              } catch (e) {
                setModalState(() => isDownloading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unable to play audio. ${kIsWeb ? 'If this is a protected URL, it must be publicly accessible on web.' : 'Please try again.'}', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                      backgroundColor: AppColors.lightError,
                    ),
                  );
                }
              }
            }

            void _pause() async {
              await player.pause();
              setModalState(() {});
            }

            void _stop() async {
              await player.stop();
              setModalState(() {
                position = Duration.zero;
              });
            }

            player.onDurationChanged.listen((d) {
              setModalState(() => duration = d);
            });
            player.onPositionChanged.listen((p) {
              setModalState(() => position = p);
            });
            player.onPlayerStateChanged.listen((state) {
              setModalState(() => isPlaying = state == PlayerState.playing);
            });

            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    file.originalFilename,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: _stop,
                      ),
                      isDownloading
                          ? SizedBox(
                              width: 48.sp,
                              height: 48.sp,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                              iconSize: 48.sp,
                              onPressed: isPlaying ? _pause : _play,
                            ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Slider(
                    value: position.inSeconds.toDouble().clamp(0, (duration.inSeconds.toDouble() == 0 ? 1 : duration.inSeconds.toDouble())),
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey.withAlpha(120),
                    max: (duration.inSeconds == 0 ? 1 : duration.inSeconds).toDouble(),
                    onChanged: (v) async {
                      final newPos = Duration(seconds: v.toInt());
                      await player.seek(newPos);
                      setModalState(() => position = newPos);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position), style: AppTextStyles.bodySmall),
                      Text(_formatDuration(duration), style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    await player.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _confirmAndDelete(MediaFile file) async {
    final mediaService = getIt<MediaService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete file'),
          content: Text('Are you sure you want to delete "${file.originalFilename}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await mediaService.deleteMedia(file.id);
      if (!mounted) return;
      setState(() {
        _mediaFiles.removeWhere((f) => f.id == file.id);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
          backgroundColor: AppColors.lightError,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    }
  }
}
