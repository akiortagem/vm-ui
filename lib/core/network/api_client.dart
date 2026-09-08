import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Credentials returned by machine pairing or refresh.
class MachineCredentials {
  MachineCredentials({
    required this.machineId,
    required this.token,
    required this.refreshToken,
  }) {
    if (machineId <= 0 || token.trim().isEmpty || refreshToken.trim().isEmpty) {
      throw ArgumentError('Machine ID and both tokens are required');
    }
  }

  final int machineId;
  final String token;
  final String refreshToken;

  factory MachineCredentials.fromJson(Map<String, dynamic> json) =>
      MachineCredentials(
        machineId: json['machine_id'] as int,
        token: json['token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  Map<String, dynamic> toJson() => {
    'machine_id': machineId,
    'token': token,
    'refresh_token': refreshToken,
  };
}

abstract interface class CredentialStore {
  Future<MachineCredentials?> read();
  Future<void> write(MachineCredentials credentials);
  Future<void> clear();
}

/// Stores the entire rotating credential pair in one secure-storage entry.
class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore({required this.key, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final String key;
  final FlutterSecureStorage _storage;

  @override
  Future<MachineCredentials?> read() async {
    final value = await _storage.read(key: key);
    return value == null
        ? null
        : MachineCredentials.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          );
  }

  @override
  Future<void> write(MachineCredentials credentials) =>
      _storage.write(key: key, value: jsonEncode(credentials.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: key);
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// JSON requests with raw HTTP responses. Owns and closes its HTTP transport.
/// Use one instance per API/session so concurrent requests share refreshes.
class ApiClient {
  ApiClient._(this.baseUrl, this._http, this._store, this.timeout);

  static Future<ApiClient> create({
    String baseUrl = const String.fromEnvironment('API_BASE_URL'),
    http.Client? client,
    CredentialStore? credentialStore,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    if (!['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('API_BASE_URL must be an absolute HTTP(S) base URL');
    }
    if (timeout <= Duration.zero) {
      throw ArgumentError('Timeout must be positive');
    }
    final store =
        credentialStore ??
        SecureCredentialStore(key: 'vm_ui.machine_credentials.$uri');
    final credentials = await store.read();
    return ApiClient._(uri, client ?? http.Client(), store, timeout)
      .._credentials = credentials;
  }

  final Uri baseUrl;
  final http.Client _http;
  final CredentialStore _store;
  final Duration timeout;
  MachineCredentials? _credentials;
  Future<void>? _refreshing;

  bool get hasCredentials => _credentials != null;

  /// Call after pairing. Pairing UI and endpoint methods live outside this wrapper.
  Future<void> setCredentials(MachineCredentials credentials) async {
    await _refreshing;
    await _store.write(credentials);
    _credentials = credentials;
  }

  Future<void> clearCredentials() async {
    await _refreshing;
    await _store.clear();
    _credentials = null;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) => request(
    'GET',
    path,
    headers: headers,
    queryParameters: queryParameters,
    authenticated: authenticated,
  );

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) => request(
    'POST',
    path,
    body: body,
    headers: headers,
    queryParameters: queryParameters,
    authenticated: authenticated,
  );

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) => request(
    'PUT',
    path,
    body: body,
    headers: headers,
    queryParameters: queryParameters,
    authenticated: authenticated,
  );

  Future<http.Response> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) => request(
    'PATCH',
    path,
    body: body,
    headers: headers,
    queryParameters: queryParameters,
    authenticated: authenticated,
  );

  Future<http.Response> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) => request(
    'DELETE',
    path,
    body: body,
    headers: headers,
    queryParameters: queryParameters,
    authenticated: authenticated,
  );

  Future<http.Response> request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    // Treat leading slashes as relative to the configured API prefix.
    final relative = Uri.parse(path.startsWith('/') ? path.substring(1) : path);
    var uri = baseUrl.resolveUri(relative);
    if (relative.hasScheme ||
        relative.hasAuthority ||
        uri.hasFragment ||
        uri.origin != baseUrl.origin ||
        !uri.path.startsWith(baseUrl.path)) {
      throw ArgumentError('Request path must remain within API_BASE_URL');
    }
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: {...uri.queryParametersAll, ...queryParameters},
      );
    }
    final encoded = body == null ? null : jsonEncode(body);
    final requestHeaders = {
      for (final entry in (headers ?? <String, String>{}).entries)
        entry.key.toLowerCase(): entry.value,
    };
    if (authenticated && requestHeaders.containsKey('authorization')) {
      throw ArgumentError(
        'Use authenticated: false for explicit authorization',
      );
    }
    if (authenticated) await _refreshing;
    final credentials = authenticated ? _credentials : null;
    if (authenticated && credentials == null) {
      throw ApiException(401, 'Machine credentials are required');
    }
    var response = await _send(
      method,
      uri,
      encoded,
      requestHeaders,
      credentials,
    );
    if (response.statusCode == 401 && credentials != null) {
      if (identical(_credentials, credentials)) {
        await _refresh(credentials);
      } else {
        await _refreshing;
      }
      final updated = _credentials;
      if (updated == null || updated.machineId != credentials.machineId) {
        throw ApiException(401, 'Machine session changed');
      }
      response = await _send(method, uri, encoded, requestHeaders, updated);
    }
    _check(response);
    return response;
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    String? body,
    Map<String, String> headers,
    MachineCredentials? credentials,
  ) async {
    final request = http.Request(method, uri)..followRedirects = false;
    request.headers.addAll({'accept': 'application/json', ...headers});
    if (body != null) {
      request.headers['content-type'] = 'application/json; charset=utf-8';
      request.body = body;
    }
    if (credentials != null) {
      request.headers['authorization'] = 'Bearer ${credentials.token}';
    }
    return (() async => http.Response.fromStream(
      await _http.send(request),
    ))().timeout(timeout);
  }

  Future<void> _refresh(MachineCredentials credentials) async {
    if (_refreshing != null) return _refreshing;
    final future = _performRefresh(credentials);
    _refreshing = future;
    try {
      await future;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> _performRefresh(MachineCredentials credentials) async {
    final response = await _send(
      'POST',
      baseUrl.resolve('vending-machines/${credentials.machineId}/refresh'),
      jsonEncode({'refresh_token': credentials.refreshToken}),
      {},
      null,
    );
    if (response.statusCode == 401) {
      _credentials = null;
      await _store.clear();
    }
    _check(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final updated = MachineCredentials(
      machineId: credentials.machineId,
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
    // Keep the rotated pair in memory even if persistence reports a failure.
    _credentials = updated;
    await _store.write(updated);
  }

  static void _check(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    var message = 'HTTP request failed';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] is String) {
        message = body['error'] as String;
      }
    } on FormatException {
      // Proxy errors and empty responses need not be JSON.
    }
    throw ApiException(response.statusCode, message);
  }

  void close() => _http.close();
}
