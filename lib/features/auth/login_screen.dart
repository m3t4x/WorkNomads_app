import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:worknomads/core/constants/app_colors.dart';
import 'package:worknomads/core/constants/app_text_styles.dart';
import 'package:worknomads/core/providers/theme_provider.dart';
import 'signup_screen.dart';
import 'package:worknomads/core/widgets/three_finger_tap_detector.dart';
import 'package:worknomads/core/services/service_locator.dart';
import 'package:worknomads/core/services/api_controller.dart';
import 'package:worknomads/core/services/media_service.dart';
import '../home/home_screen.dart';

// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final api = getIt<ApiController>();
      final res = await api.login(
        usernameOrEmail: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((res['message'] ?? 'Login failed').toString(), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = 'Something went wrong. Please try again.';
      if (e is DioException) {
        // Show actionable guidance for connectivity issues
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown ||
            (e.error != null && e.error.toString().contains('SocketException'))) {
          msg = 'Network error or unreachable API. Triple-tap to set API URLs.';
        } else if (e.response != null) {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            if (data['detail'] is String) msg = data['detail'];
            else if (data['message'] is String) msg = data['message'];
            else if (data['error'] is String) msg = data['error'];
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
          backgroundColor: AppColors.lightError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }
  }

  String? _validateUsernameOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or username is required';
    }
    final v = value.trim();
    // If input looks like an email, validate format; otherwise accept as username
    if (v.contains('@')) {
      if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
        return 'Please enter a valid email';
      }
    } else {
      if (v.length < 3) {
        return 'Username must be at least 3 characters';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ThreeFingerTapDetector(
          onTripleTap: () => _showBaseUrlDialog(context),
          child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: themeProvider.toggleTheme,
                              icon: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: themeProvider.isDarkMode
                                    ? AppColors.darkOnBackground
                                    : AppColors.lightOnBackground,
                                size: 24.sp,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20.h),
                          
                          // Logo section
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              child: SvgPicture.asset(
                                'assets/logo_long.svg',
                                fit: BoxFit.cover,
                                height: 60.h,
                                colorFilter: ColorFilter.mode(
                                  themeProvider.isDarkMode
                                      ? AppColors.darkOnSurface
                                      : AppColors.lightOnSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20.h),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Welcome Back',
                              style: AppTextStyles.headlineLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          
                          Container(
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: 0.7,
                              child: Text(
                                'Sign in to continue your journey',
                                style: AppTextStyles.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 40.h),
                          
                          // Login form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: _validateUsernameOrEmail,
                                  style: AppTextStyles.inputText,
                                  decoration: InputDecoration(
                                    labelText: 'Email or Username',
                                    hintText: 'Enter email or username',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 20.h),
                                
                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  validator: _validatePassword,
                                  style: AppTextStyles.inputText,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      size: 20.sp,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Remember me and forgot password
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: themeProvider.isDarkMode
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary,
                                    ),
                                    Text(
                                      'Remember me',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        // Handle forgot password
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 32.h),
                                
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20.w,
                                            height: 20.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.w,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                themeProvider.isDarkMode
                                                    ? AppColors.darkOnPrimary
                                                    : AppColors.lightOnPrimary,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: AppTextStyles.buttonText,
                                          ),
                                  ),
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: themeProvider.isDarkMode
                                            ? AppColors.grey700
                                            : AppColors.grey300,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                                      child: Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          'OR',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: themeProvider.isDarkMode
                                            ? AppColors.grey700
                                            : AppColors.grey300,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Social login buttons
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Handle Google sign in
                                    },
                                    icon: Icon(
                                      Icons.g_mobiledata,
                                      size: 24.sp,
                                    ),
                                    label: Text(
                                      'Continue with Google',
                                      style: AppTextStyles.buttonText,
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 15.h),
                                
                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    SizedBox(width: 5.w,),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const SignupScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  Future<void> _showBaseUrlDialog(BuildContext context) async {
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
}
