import 'package:vm_ui/core/network/api_client.dart';

class StartupOptions {
  StartupOptions({this.credentials, this.replaceCredentials = false});

  final MachineCredentials? credentials;
  final bool replaceCredentials;

  static StartupOptions parse(List<String> arguments) {
    final values = <String, String>{};
    var replaceCredentials = false;

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      if (argument == '--replace-credentials') {
        if (replaceCredentials) {
          throw const FormatException(
            '--replace-credentials may only be provided once',
          );
        }
        replaceCredentials = true;
        continue;
      }

      final separator = argument.indexOf('=');
      final name = separator == -1
          ? argument
          : argument.substring(0, separator);
      if (!{'--vm-id', '--access-token', '--refresh-token'}.contains(name)) {
        throw const FormatException('Unknown launch argument');
      }
      if (values.containsKey(name)) {
        throw FormatException('$name may only be provided once');
      }

      late final String value;
      if (separator != -1) {
        value = argument.substring(separator + 1);
      } else {
        if (index + 1 >= arguments.length ||
            arguments[index + 1].startsWith('--')) {
          throw FormatException('$name requires a value');
        }
        value = arguments[++index];
      }
      if (value.trim().isEmpty) {
        throw FormatException('$name requires a non-empty value');
      }
      values[name] = value;
    }

    final suppliedCount = values.length;
    if (suppliedCount != 0 && suppliedCount != 3) {
      throw const FormatException(
        '--vm-id, --access-token, and --refresh-token must be provided together',
      );
    }
    if (replaceCredentials && suppliedCount == 0) {
      throw const FormatException(
        '--replace-credentials requires all three credential arguments',
      );
    }
    if (suppliedCount == 0) {
      return StartupOptions();
    }

    final machineId = int.tryParse(values['--vm-id']!.trim());
    if (machineId == null || machineId <= 0) {
      throw const FormatException('--vm-id must be a positive integer');
    }

    return StartupOptions(
      credentials: MachineCredentials(
        machineId: machineId,
        token: values['--access-token']!,
        refreshToken: values['--refresh-token']!,
      ),
      replaceCredentials: replaceCredentials,
    );
  }
}
