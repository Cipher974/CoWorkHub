import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resource.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ResourceService {
  static const String baseUrl = 'http://localhost:8080/api/resources';
  static const _headers = {'Content-Type': 'application/json'};

  Future<List<Resource>> getResources({
    String? type,
    int? minCapacity,
    String? location,
    double? maxPrice,
  }) async {
    final params = <String, String>{};
    if (type != null) params['type'] = type;
    if (minCapacity != null) params['minCapacity'] = '$minCapacity';
    if (location != null) params['location'] = location;
    if (maxPrice != null) params['maxPrice'] = '$maxPrice';

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await _send(() => http.get(uri));
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Resource.fromJson(e)).toList();
  }

  Future<void> createRoom(Map<String, dynamic> body) async {
    await _send(() => http.post(Uri.parse('$baseUrl/rooms'),
        headers: _headers, body: jsonEncode(body)));
  }

  Future<void> createDesk(Map<String, dynamic> body) async {
    await _send(() => http.post(Uri.parse('$baseUrl/desks'),
        headers: _headers, body: jsonEncode(body)));
  }

  Future<void> updateResource(int id, Map<String, dynamic> body) async {
    await _send(() => http.put(Uri.parse('$baseUrl/$id'),
        headers: _headers, body: jsonEncode(body)));
  }

  Future<void> deleteResource(int id) async {
    await _send(() => http.delete(Uri.parse('$baseUrl/$id')));
  }

  // Sends the request and turns errors into readable messages
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request();
    } catch (_) {
      throw ApiException('Cannot reach the server. Is the backend running?');
    }
    if (response.statusCode >= 400) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          message = data['message'];
        }
      } catch (_) {}
      throw ApiException(message);
    }
    return response;
  }
}