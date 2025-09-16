import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/service_locator.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await setupServiceLocator();
  
  // Set system UI overlay style
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const WorkNomadsApp());
}

class WorkNomadsApp extends StatelessWidget {
  const WorkNomadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone 12 Pro design size
            minTextAdapt: true,
            splitScreenMode: true,
            useInheritedMediaQuery: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'WorkNomads',
                debugShowCheckedModeBanner: false,
                
                // Theme configuration
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                
                // Home screen
                home: const SplashScreen(),
                
                // Route configuration
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.noScaling,
                    ),
                    child: widget!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
