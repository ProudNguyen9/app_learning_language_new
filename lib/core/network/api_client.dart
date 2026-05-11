import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:apphoctienganh/core/config/app_environment.dart';
import 'package:apphoctienganh/core/network/api_exception.dart';
import 'package:apphoctienganh/core/network/api_response.dart';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

final class ApiClient {
  ApiClient({http.Client? httpClient, AppEnvironment? environment})
    : _httpClient = httpClient ?? http.Client(),
      _environment = environment ?? AppEnvironment.current;

  final http.Client _httpClient;
  final AppEnvironment _environment;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic json) decoder,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic json) decoder,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic json) decoder,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic json) decoder,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      decoder: decoder,
    );
  }

  Future<ApiResponse<T>> _send<T>({
    required String method,
    required String path,
    required T Function(dynamic json) decoder,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _environment.apiUri(path, queryParameters);
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      _logRequest(method, uri, body);

      final response = await _request(
        method: method,
        uri: uri,
        headers: requestHeaders,
        body: body,
      ).timeout(_environment.receiveTimeout);

      _logResponse(method, uri, response);
      return _handleResponse(response, uri, decoder);
    } on TimeoutException catch (error) {
      throw ApiException(
        message: 'Kết nối quá thời gian. Vui lòng thử lại.',
        endpoint: uri,
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        message: 'Không thể kết nối máy chủ.',
        endpoint: uri,
        cause: error,
      );
    }
  }

  Future<http.Response> _request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
  }) {
    final encodedBody = body == null ? null : jsonEncode(body);

    return switch (method) {
      'GET' => _httpClient.get(uri, headers: headers),
      'POST' => _httpClient.post(uri, headers: headers, body: encodedBody),
      'PUT' => _httpClient.put(uri, headers: headers, body: encodedBody),
      'DELETE' => _httpClient.delete(uri, headers: headers, body: encodedBody),
      _ => throw ApiException(message: 'HTTP method không hỗ trợ: $method'),
    };
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    Uri endpoint,
    T Function(dynamic json) decoder,
  ) {
    final decodedBody =
        response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: _extractMessage(decodedBody) ?? 'Có lỗi xảy ra từ máy chủ.',
        statusCode: response.statusCode,
        endpoint: endpoint,
      );
    }

    final data =
        decodedBody is JsonMap && decodedBody.containsKey('data')
            ? decodedBody['data']
            : decodedBody;

    return ApiResponse<T>(
      data: decoder(data),
      message: _extractMessage(decodedBody),
      statusCode: response.statusCode,
    );
  }

  String? _extractMessage(dynamic json) {
    if (json is JsonMap && json['message'] is String) {
      return json['message'] as String;
    }
    return null;
  }

  void _logRequest(String method, Uri uri, Object? body) {
    if (!_environment.enableNetworkLogs) return;
    log('REQUEST [$method] $uri body=$body', name: 'ApiClient');
  }

  void _logResponse(String method, Uri uri, http.Response response) {
    if (!_environment.enableNetworkLogs) return;
    log(
      'RESPONSE [$method] $uri status=${response.statusCode} body=${response.body}',
      name: 'ApiClient',
    );
  }
}
