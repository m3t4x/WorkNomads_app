import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:worknomads/core/constants/app_colors.dart';
import 'package:worknomads/core/constants/app_text_styles.dart';
import 'package:worknomads/core/providers/theme_provider.dart';
import 'login_screen.dart';
import 'package:worknomads/core/widgets/three_finger_tap_detector.dart';
import 'package:worknomads/core/services/service_locator.dart';
import 'package:worknomads/core/services/api_controller.dart';
import 'package:worknomads/core/services/media_service.dart';
import '../home/home_screen.dart';

// Signup screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final api = getIt<ApiController>();
      final registerRes = await api.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (registerRes['success'] == true) {
        // Attempt auto-login after successful registration
        final loginRes = await api.login(
          usernameOrEmail: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (loginRes['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome aboard!', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          );
          // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((loginRes['message'] ?? 'Login failed').toString(), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
              backgroundColor: AppColors.lightError,
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((registerRes['message'] ?? 'Registration failed').toString(), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
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
          } else if (data is String && data.isNotEmpty) {
            msg = data;
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
          backgroundColor: AppColors.lightError,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateName(String? value, {required String field}) {
    if (value == null || value.isEmpty) {
      return '$field is required';
    }
    if (value.trim().length < 2) {
      return '$field must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+").hasMatch(value.trim())) {
      return 'Please enter a valid $field';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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
                              'Create Account',
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
                                'Join us and start your journey',
                                style: AppTextStyles.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          SizedBox(height: 40.h),

                          // Signup form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // First name and Last name fields (side by side on wide screens)
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 420.w;
                                    if (isWide) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _firstNameController,
                                              textInputAction: TextInputAction.next,
                                              validator: (v) => _validateName(v, field: 'First name'),
                                              style: AppTextStyles.inputText,
                                              decoration: InputDecoration(
                                                labelText: 'First name',
                                                hintText: 'Enter your first name',
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  size: 20.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _lastNameController,
                                              textInputAction: TextInputAction.next,
                                              validator: (v) => _validateName(v, field: 'Last name'),
                                              style: AppTextStyles.inputText,
                                              decoration: InputDecoration(
                                                labelText: 'Last name',
                                                hintText: 'Enter your last name',
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  size: 20.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        TextFormField(
                                          controller: _firstNameController,
                                          textInputAction: TextInputAction.next,
                                          validator: (v) => _validateName(v, field: 'First name'),
                                          style: AppTextStyles.inputText,
                                          decoration: InputDecoration(
                                            labelText: 'First name',
                                            hintText: 'Enter your first name',
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        TextFormField(
                                          controller: _lastNameController,
                                          textInputAction: TextInputAction.next,
                                          validator: (v) => _validateName(v, field: 'Last name'),
                                          style: AppTextStyles.inputText,
                                          decoration: InputDecoration(
                                            labelText: 'Last name',
                                            hintText: 'Enter your last name',
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                SizedBox(height: 20.h),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: _validateEmail,
                                  style: AppTextStyles.inputText,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Enter your email',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // Username field
                                TextFormField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  validator: _validateUsername,
                                  style: AppTextStyles.inputText,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Choose a username',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  textInputAction: TextInputAction.next,
                                  validator: _validatePassword,
                                  style: AppTextStyles.inputText,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Create a strong password',
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

                                SizedBox(height: 20.h),

                                // Confirm Password field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  validator: _validateConfirmPassword,
                                  style: AppTextStyles.inputText,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    hintText: 'Re-enter your password',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      size: 20.sp,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                // Password requirements
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDarkMode
                                        ? AppColors.darkSurface.withOpacity(0.5)
                                        : AppColors.lightSurface.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: themeProvider.isDarkMode
                                          ? AppColors.grey700
                                          : AppColors.grey300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Password Requirements:',
                                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 4.h),
                                      _buildRequirement('At least 8 characters', _passwordController.text.length >= 8),
                                      _buildRequirement('One uppercase letter', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                                      _buildRequirement('One special character', RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.h),

                                // Signup button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleSignup,
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
                                            'Create Account',
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
                                      child: Text(
                                        'OR',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: themeProvider.isDarkMode
                                              ? AppColors.darkOnBackground.withOpacity(0.6)
                                              : AppColors.lightOnBackground.withOpacity(0.6),
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

                                // Social signup button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Handle Google sign up
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

                                // Sign in link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account? ",
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    SizedBox(width: 5.w,),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Sign In',
                                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildRequirement(String text, bool isValid) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16.sp,
                color: isValid
                    ? AppColors.success
                    : themeProvider.isDarkMode
                        ? AppColors.darkOnBackground.withOpacity(0.4)
                        : AppColors.lightOnBackground.withOpacity(0.4),
              ),
              SizedBox(width: 8.w),
              Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isValid
                      ? AppColors.success
                      : themeProvider.isDarkMode
                          ? AppColors.darkOnBackground.withOpacity(0.6)
                          : AppColors.lightOnBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
