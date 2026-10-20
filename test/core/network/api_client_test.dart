import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vm_ui/core/network/api_client.dart';

class MemoryStore implements CredentialStore {
  MachineCredentials? value = MachineCredentials(
    machineId: 12,
    token: 'old',
    refreshToken: 'refresh-old',
  );
  @override
  Future<MachineCredentials?> read() async => value;
  @override
  Future<void> write(MachineCredentials credentials) async =>
      value = credentials;
  @override
  Future<void> clear() async => value = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'initial credentials seed once and preserve rotation on restart',
    () async {
      final store = MemoryStore()..value = null;
      final first = await ApiClient.create(
        baseUrl: 'https://example.test',
        initialCredentials: MachineCredentials(
          machineId: 12,
          token: 'old',
          refreshToken: 'refresh-old',
        ),
        credentialStore: store,
        client: MockClient((request) async {
          if (request.url.path.endsWith('/refresh')) {
            return http.Response(
              '{"token":"new","refresh_token":"rotated"}',
              200,
            );
          }
          return http.Response(
            '{}',
            request.headers['authorization'] == 'Bearer old' ? 401 : 200,
          );
        }),
      );
      addTearDown(first.close);
      expect(store.value!.token, 'old');
      await first.get('items');
      expect(store.value!.refreshToken, 'rotated');
      final restarted = await ApiClient.create(
        baseUrl: 'https://example.test',
        initialCredentials: MachineCredentials(
          machineId: 12,
          token: 'old',
          refreshToken: 'refresh-old',
        ),
        credentialStore: store,
        client: MockClient((request) async {
          if (request.url.path.endsWith('/refresh')) {
            expect(jsonDecode(request.body)['refresh_token'], 'rotated');
            return http.Response(
              '{"token":"latest","refresh_token":"latest-refresh"}',
              200,
            );
          }
          return http.Response(
            '{}',
            request.headers['authorization'] == 'Bearer new' ? 401 : 200,
          );
        }),
      );
      addTearDown(restarted.close);
      expect(store.value!.refreshToken, 'rotated');
      await restarted.get('items');
      expect(store.value!.refreshToken, 'latest-refresh');
    },
  );

  test(
    'secure store restores the complete session in another instance',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = SecureCredentialStore(key: 'test-api');
      await store.write(MemoryStore().value!);
      final restored = await SecureCredentialStore(key: 'test-api').read();
      expect(restored!.machineId, 12);
      expect(restored.refreshToken, 'refresh-old');
      await store.clear();
      expect(await store.read(), isNull);
    },
  );

  test('replacement credentials overwrite the stored session', () async {
    final store = MemoryStore();
    final replacement = MachineCredentials(
      machineId: 24,
      token: 'replacement',
      refreshToken: 'replacement-refresh',
    );

    final api = await ApiClient.create(
      baseUrl: 'https://example.test',
      initialCredentials: replacement,
      replaceCredentials: true,
      credentialStore: store,
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    addTearDown(api.close);

    expect(api.machineId, 24);
    expect(store.value, same(replacement));
  });

  test(
    'JSON requests preserve prefix, query, headers and empty responses',
    () async {
      final api = await ApiClient.create(
        baseUrl: 'https://example.test/api',
        credentialStore: MemoryStore(),
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://example.test/api/items?q=a+b',
          );
          expect(request.headers['authorization'], 'Bearer old');
          expect(jsonDecode(request.body), {'name': 'rice'});
          expect(request.headers['x-test'], 'yes');
          return http.Response('', 204);
        }),
      );
      addTearDown(api.close);
      expect(
        (await api.post(
          '/items',
          body: {'name': 'rice'},
          headers: {'X-Test': 'yes'},
          queryParameters: {'q': 'a b'},
        )).statusCode,
        204,
      );
      await expectLater(api.get('https://other.test/x'), throwsArgumentError);
      await expectLater(api.get('../private'), throwsArgumentError);
    },
  );

  test(
    'concurrent 401s share refresh and persist rotated credentials',
    () async {
      final store = MemoryStore();
      var refreshes = 0;
      var originals = 0;
      final bothStarted = Completer<void>();
      final api = await ApiClient.create(
        baseUrl: 'https://example.test/api/',
        credentialStore: store,
        client: MockClient((request) async {
          if (request.url.path.endsWith('/refresh')) {
            refreshes++;
            expect(request.url.path, '/api/vending-machines/12/refresh');
            expect(request.headers['authorization'], isNull);
            expect(jsonDecode(request.body), {'refresh_token': 'refresh-old'});
            return http.Response(
              '{"token":"new","refresh_token":"refresh-new"}',
              200,
            );
          }
          if (request.headers['authorization'] == 'Bearer old') {
            if (++originals == 2) bothStarted.complete();
            await bothStarted.future;
            return http.Response('', 401);
          }
          expect(request.headers['authorization'], 'Bearer new');
          expect(request.body, '{"quantity":2}');
          return http.Response('{}', 200);
        }),
      );
      addTearDown(api.close);
      await Future.wait([
        api.post('items', body: {'quantity': 2}),
        api.post('items', body: {'quantity': 2}),
      ]);
      expect(refreshes, 1);
      expect(store.value!.refreshToken, 'refresh-new');
    },
  );

  test('replay stops after one refresh even when still unauthorized', () async {
    var calls = 0;
    final api = await ApiClient.create(
      baseUrl: 'https://example.test/',
      credentialStore: MemoryStore(),
      client: MockClient((request) async {
        calls++;
        return request.url.path.endsWith('/refresh')
            ? http.Response('{"token":"new","refresh_token":"next"}', 200)
            : http.Response('', 401);
      }),
    );
    addTearDown(api.close);
    await expectLater(api.get('items'), throwsA(isA<ApiException>()));
    expect(calls, 3);
  });

  test('rejected refresh clears credentials without replay', () async {
    final store = MemoryStore();
    var calls = 0;
    final api = await ApiClient.create(
      baseUrl: 'https://example.test/',
      credentialStore: store,
      client: MockClient((_) async {
        calls++;
        return http.Response('{"error":"expired"}', 401);
      }),
    );
    addTearDown(api.close);
    await expectLater(api.get('items'), throwsA(isA<ApiException>()));
    expect(calls, 2);
    expect(store.value, isNull);
    expect(api.hasCredentials, isFalse);
  });

  test('public 401 and server failures do not refresh', () async {
    var calls = 0;
    final api = await ApiClient.create(
      baseUrl: 'https://example.test/',
      credentialStore: MemoryStore(),
      client: MockClient((request) async {
        calls++;
        return http.Response(
          'not JSON',
          request.url.path == '/public' ? 401 : 500,
        );
      }),
    );
    addTearDown(api.close);
    await expectLater(
      api.get('public', authenticated: false),
      throwsA(isA<ApiException>()),
    );
    await expectLater(api.get('items'), throwsA(isA<ApiException>()));
    expect(calls, 2);
  });

  test('network failures and timeouts propagate without retry', () async {
    var calls = 0;
    final api = await ApiClient.create(
      baseUrl: 'https://example.test/',
      timeout: const Duration(milliseconds: 10),
      credentialStore: MemoryStore(),
      client: MockClient((request) async {
        calls++;
        if (request.url.path == '/offline') {
          throw http.ClientException('offline');
        }
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return http.Response('{}', 200);
      }),
    );
    addTearDown(api.close);
    await expectLater(api.get('offline'), throwsA(isA<http.ClientException>()));
    await expectLater(api.get('slow'), throwsA(isA<TimeoutException>()));
    expect(calls, 2);
  });
}
