import 'package:flutter/widgets.dart';
import 'package:vm_ui/app/app.dart';
import 'package:vm_ui/core/config/startup_options.dart';
import 'package:vm_ui/core/network/api_client.dart';

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = StartupOptions.parse(arguments);
  final client = await ApiClient.create(
    initialCredentials: options.credentials,
    replaceCredentials: options.replaceCredentials,
  );
  runApp(VmUiApp(apiClient: client));
}
