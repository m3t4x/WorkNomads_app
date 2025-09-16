import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:worknomads/core/constants/app_colors.dart';
import 'package:worknomads/core/constants/app_text_styles.dart';
import 'package:worknomads/core/providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'package:worknomads/core/services/service_locator.dart';
import 'package:worknomads/core/services/api_controller.dart';
import '../home/home_screen.dart';

// Splash screen for WorkNomads
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start logo animation
    await _logoController.forward();
    
    // Wait a bit to show the logo
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    // Decide start destination based on existing tokens
    final api = getIt<ApiController>();
    if (api.isLoggedIn) {
      if (!api.hasRefreshToken) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final refreshed = await api.tryRefresh();
        if (!mounted) return;
        if (refreshed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: math.min(1.0, math.max(0.0, _fadeAnimation.value)),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                      // Animated logo
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              width: 200.w,
                              height: 100.h,
                              padding: EdgeInsets.all(20.w),
                              child: SvgPicture.asset(
                                'assets/logo_long.svg',
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  themeProvider.isDarkMode
                                      ? AppColors.darkOnSurface
                                      : AppColors.lightOnSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 10.h),
                      
                      // App name with fade animation
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: math.min(1.0, math.max(0.0, _logoAnimation.value)),
                            child: Text(
                              'WorkNomads',
                              style: AppTextStyles.logoText.copyWith(
                                color: themeProvider.isDarkMode
                                    ? AppColors.darkOnBackground
                                    : AppColors.lightOnBackground,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Subtitle
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: math.min(1.0, math.max(0.0, _logoAnimation.value * 0.7)),
                            child: Text(
                              'Your Digital Workspace',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: themeProvider.isDarkMode
                                    ? AppColors.darkOnBackground.withOpacity(0.7)
                                    : AppColors.lightOnBackground.withOpacity(0.7),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 60.h),
                      
                      // Loading indicator
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: math.min(1.0, math.max(0.0, _logoAnimation.value)),
                            child: SizedBox(
                              width: 30.w,
                              height: 30.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeProvider.isDarkMode
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
