/// Error with a readable message (taken from the backend's {"message": "..."} body).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}