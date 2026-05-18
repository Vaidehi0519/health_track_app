class ApiResult<T> {
  const ApiResult.success(this.data) : error = null;
  const ApiResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
}

class ApiClient {
  const ApiClient({this.baseUrl = 'https://api.example.com'});

  final String baseUrl;

  Future<ApiResult<Map<String, Object?>>> getHealthSummary(String uid) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return ApiResult.success({
      'uid': uid,
      'syncedAt': DateTime.now().toIso8601String(),
      'source': 'local-demo',
    });
  }
}
