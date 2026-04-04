import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

typedef TokenProvider = Future<String?> Function();

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class LaravelApiClient {
  LaravelApiClient({
    http.Client? httpClient,
    String? baseUrl,
    this.tokenProvider,
  }) : _httpClient = httpClient ?? http.Client(),
       baseUrl =
           (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/$'), '');

  final http.Client _httpClient;
  final String baseUrl;
  final TokenProvider? tokenProvider;

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      'GET',
      path,
      queryParameters: queryParameters,
    );
    if (response == null) {
      return [];
    }
    if (response is List) {
      return response;
    }
    if (response is Map<String, dynamic> && response['data'] is List) {
      return List<dynamic>.from(response['data'] as List);
    }
    return [];
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      'GET',
      path,
      queryParameters: queryParameters,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _request(
      'POST',
      path,
      body: body,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _request(
      'PUT',
      path,
      body: body,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders();
    debugPrint('[ApiClient] $method $uri');
    debugPrint('[ApiClient] headers=${headers.keys.toList()}');

    late http.Response httpResponse;
    final encodedBody = body == null ? null : jsonEncode(body);
    if (body != null) {
      final safeBody = Map<String, dynamic>.from(body);
      if (safeBody.containsKey('password')) {
        safeBody['password'] = '***';
      }
      debugPrint('[ApiClient] body=$safeBody');
    }

    try {
      switch (method) {
        case 'POST':
          httpResponse = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.networkTimeout);
          break;
        case 'PUT':
          httpResponse = await _httpClient
              .put(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.networkTimeout);
          break;
        default:
          httpResponse = await _httpClient
              .get(uri, headers: headers)
              .timeout(AppConfig.networkTimeout);
      }
    } on TimeoutException {
      debugPrint(
        '[ApiClient] request timeout after ${AppConfig.networkTimeout.inSeconds}s for $uri',
      );
      throw ApiException(
        'Delai d\'attente depasse apres ${AppConfig.networkTimeout.inSeconds}s.',
      );
    } on SocketException catch (error) {
      final osMessage = error.osError?.message;
      final osCode = error.osError?.errorCode;
      debugPrint(
        '[ApiClient] socket exception for $uri: $error osCode=$osCode osMessage=$osMessage',
      );
      throw ApiException(
        osMessage != null && osMessage.isNotEmpty
            ? 'Erreur reseau: $osMessage'
            : 'Erreur reseau: $error',
      );
    } on http.ClientException catch (error) {
      debugPrint('[ApiClient] client exception for $uri: $error');
      throw ApiException('Erreur reseau: ${error.message}');
    } catch (error) {
      debugPrint('[ApiClient] unexpected request error for $uri: $error');
      rethrow;
    }

    final statusCode = httpResponse.statusCode;
    debugPrint('[ApiClient] response status=$statusCode for $uri');
    if (httpResponse.body.isNotEmpty) {
      final preview = httpResponse.body.length > 300
          ? '${httpResponse.body.substring(0, 300)}...'
          : httpResponse.body;
      debugPrint('[ApiClient] response body preview=$preview');
    } else {
      debugPrint('[ApiClient] response body is empty');
    }

    final decodedBody = httpResponse.body.isNotEmpty
        ? jsonDecode(httpResponse.body)
        : null;

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    String message = 'Unexpected error';
    if (decodedBody is Map && decodedBody['message'] is String) {
      message = decodedBody['message'] as String;
    }
    debugPrint('[ApiClient] request failed status=$statusCode message="$message"');
    throw ApiException(message, statusCode: statusCode);
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    final filtered = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value == null) return;
      filtered[key] = value.toString();
    });
    return uri.replace(queryParameters: filtered);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'close',
    };
    if (tokenProvider != null) {
      final token = await tokenProvider!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}
