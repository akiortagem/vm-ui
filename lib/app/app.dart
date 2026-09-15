import 'package:vm_ui/core/network/api_client.dart';
import 'package:vm_ui/features/menu_selection/data/api_menu_repository.dart';
import 'package:vm_ui/features/menu_selection/domain/load_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:vm_ui/app/theme/app_theme.dart';
import 'package:vm_ui/core/constants/app_constants.dart';
import 'package:vm_ui/features/splash/presentation/splash_page.dart';

class VmUiApp extends StatefulWidget {
  const VmUiApp({this.loadMenu, super.key});

  final LoadMenu? loadMenu;

  static const designSize = Size(1080, 1920);

  @override
  State<VmUiApp> createState() => _VmUiAppState();
}

class _VmUiAppState extends State<VmUiApp> {
  Future<ApiClient>? _client;
  late final LoadMenu _loadMenu =
      widget.loadMenu ??
      LoadMenu(ApiMenuRepository(() => _client ??= ApiClient.create()));

  @override
  void dispose() {
    _client?.then((client) => client.close(), onError: (Object _) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          ...const MaterialScrollBehavior().dragDevices,
          PointerDeviceKind.mouse,
        },
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => _DesignCanvas(child: child!),
      home: SplashPage(loadMenu: _loadMenu),
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
