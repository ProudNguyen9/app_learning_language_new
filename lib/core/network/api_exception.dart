final class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.endpoint,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Uri? endpoint;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : '[$statusCode] ';
    final path = endpoint == null ? '' : ' (${endpoint!.path})';
    return 'ApiException: $status$message$path';
  }
}
