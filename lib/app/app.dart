import 'package:flutter/material.dart';
import 'package:vm_ui/app/theme/app_theme.dart';
import 'package:vm_ui/core/constants/app_constants.dart';
import 'package:vm_ui/features/splash/presentation/splash_page.dart';

class VmUiApp extends StatelessWidget {
  const VmUiApp({super.key});

  static const designSize = Size(1080, 1920);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _DesignCanvas(child: SplashPage()),
    );
  }
}

class _DesignCanvas extends StatelessWidget {
  const _DesignCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: VmUiApp.designSize.width,
            height: VmUiApp.designSize.height,
            child: MediaQuery(
              data: mediaQuery.copyWith(size: VmUiApp.designSize),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
