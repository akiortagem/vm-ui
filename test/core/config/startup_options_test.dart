import 'package:flutter_test/flutter_test.dart';
import 'package:vm_ui/core/config/startup_options.dart';

void main() {
  test('parses credentials with separate values', () {
    final options = StartupOptions.parse([
      '--vm-id',
      '7',
      '--access-token',
      'access',
      '--refresh-token',
      'refresh',
    ]);

    expect(options.credentials!.machineId, 7);
    expect(options.credentials!.token, 'access');
    expect(options.credentials!.refreshToken, 'refresh');
    expect(options.replaceCredentials, isFalse);
  });

  test('parses equals syntax and replacement flag', () {
    final options = StartupOptions.parse([
      '--vm-id=8',
      '--access-token=access',
      '--refresh-token=refresh',
      '--replace-credentials',
    ]);

    expect(options.credentials!.machineId, 8);
    expect(options.replaceCredentials, isTrue);
  });

  test('allows launch without provisioning arguments', () {
    final options = StartupOptions.parse([]);

    expect(options.credentials, isNull);
    expect(options.replaceCredentials, isFalse);
  });

  test('rejects incomplete credentials', () {
    expect(
      () => StartupOptions.parse(['--vm-id', '7']),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects invalid machine IDs', () {
    expect(
      () => StartupOptions.parse([
        '--vm-id',
        '0',
        '--access-token',
        'access',
        '--refresh-token',
        'refresh',
      ]),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects replacement without credentials', () {
    expect(
      () => StartupOptions.parse(['--replace-credentials']),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unknown and duplicate arguments', () {
    expect(
      () => StartupOptions.parse(['--unknown', 'value']),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => StartupOptions.parse([
        '--vm-id=7',
        '--vm-id=8',
        '--access-token=access',
        '--refresh-token=refresh',
      ]),
      throwsA(isA<FormatException>()),
    );
  });
}
