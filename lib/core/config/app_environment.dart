enum AppFlavor { development, staging, production }

extension AppFlavorX on AppFlavor {
  static AppFlavor fromDartDefine(String value) {
    return switch (value.toLowerCase()) {
      'dev' || 'development' => AppFlavor.development,
      'stg' || 'staging' => AppFlavor.staging,
      'prod' || 'production' => AppFlavor.production,
      _ => AppFlavor.development,
    };
  }
}

final class AppEnvironment {
  const AppEnvironment._({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.apiVersion,
    required this.enableNetworkLogs,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  final AppFlavor flavor;
  final String appName;
  final String baseUrl;
  final String apiVersion;
  final bool enableNetworkLogs;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  static final AppEnvironment current = _fromFlavor(
    AppFlavorX.fromDartDefine(
      const String.fromEnvironment('FLAVOR', defaultValue: 'development'),
    ),
  );

  static AppEnvironment _fromFlavor(AppFlavor flavor) {
    return switch (flavor) {
      AppFlavor.development => AppEnvironment.development,
      AppFlavor.staging => AppEnvironment.staging,
      AppFlavor.production => AppEnvironment.production,
    };
  }

  static const development = AppEnvironment._(
    flavor: AppFlavor.development,
    appName: 'App Học Tiếng Anh Dev',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dev-api.example.com',
    ),
    apiVersion: String.fromEnvironment('API_VERSION', defaultValue: 'v1'),
    enableNetworkLogs: bool.fromEnvironment(
      'ENABLE_NETWORK_LOGS',
      defaultValue: true,
    ),
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
  );

  static const staging = AppEnvironment._(
    flavor: AppFlavor.staging,
    appName: 'App Học Tiếng Anh Staging',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://staging-api.example.com',
    ),
    apiVersion: String.fromEnvironment('API_VERSION', defaultValue: 'v1'),
    enableNetworkLogs: bool.fromEnvironment(
      'ENABLE_NETWORK_LOGS',
      defaultValue: true,
    ),
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
  );

  static const production = AppEnvironment._(
    flavor: AppFlavor.production,
    appName: 'App Học Tiếng Anh',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    ),
    apiVersion: String.fromEnvironment('API_VERSION', defaultValue: 'v1'),
    enableNetworkLogs: bool.fromEnvironment('ENABLE_NETWORK_LOGS'),
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
  );

  Uri apiUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBaseUrl =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final url = '$normalizedBaseUrl/$apiVersion/$normalizedPath';

    return Uri.parse(url).replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }
}
