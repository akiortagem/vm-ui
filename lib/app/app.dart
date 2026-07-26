import 'package:flutter/material.dart';
import 'package:vm_ui/app/theme/app_theme.dart';
import 'package:vm_ui/core/constants/app_constants.dart';
import 'package:vm_ui/core/ui_kit/pages/background.dart';

class VmUiApp extends StatelessWidget {
  const VmUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      home: const VMPageBackground(),
    );
  }
}
