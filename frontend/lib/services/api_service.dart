import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../models/member.dart';
import '../models/resource.dart';
import 'api_exception.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static const _headers = {'Content-Type': 'application/json'};

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 15));
      _checkResponse(response);
      return response;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Cannot reach the server. Check that the backend is running.');
    } on TimeoutException {
      throw ApiException('The server did not respond. Please try again.');
    } on http.ClientException {
      throw ApiException('Network error. Please check the backend connection.');
    }
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'Request failed (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        final detail = data['message'] ?? data['detail'] ?? data['error'];
        if (detail != null && detail.toString().isNotEmpty) {
          message = detail.toString();
        }
      }
    } catch (_) {}
    throw ApiException(message);
  }

  Future<List<Resource>> getResources() async {
    final r = await _send(() => http.get(Uri.parse('$baseUrl/api/resources')));
    return (jsonDecode(r.body) as List)
        .map((e) => Resource.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Resource>> getAvailableResources({
    required DateTime startDateTime,
    required DateTime endDateTime,
    int? attendees,
    String? type,
  }) async {
    final params = <String, String>{
      'startDateTime': _formatDateTime(startDateTime),
      'endDateTime': _formatDateTime(endDateTime),
      if (attendees != null) 'attendees': '$attendees',
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final uri = Uri.parse('$baseUrl/api/resources/available')
        .replace(queryParameters: params);
    final r = await _send(() => http.get(uri));
    return (jsonDecode(r.body) as List)
        .map((e) => Resource.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Member>> getMembers() async {
    final r = await _send(() => http.get(Uri.parse('$baseUrl/api/members')));
    return (jsonDecode(r.body) as List)
        .map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Member> createMember(Member m) async {
    final r = await _send(() => http.post(
      Uri.parse('$baseUrl/api/members'), headers: _headers,
      body: jsonEncode(m.toJson()),
    ));
    return Member.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<List<Booking>> getMemberBookings(int memberId) async {
    final r = await _send(() => http.get(
      Uri.parse('$baseUrl/api/members/$memberId/bookings'),
    ));
    return (jsonDecode(r.body) as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Booking>> getBookings() async {
    final r = await _send(() => http.get(Uri.parse('$baseUrl/api/bookings')));
    return (jsonDecode(r.body) as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Booking> createBooking({
    required int memberId,
    required int resourceId,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required int attendees,
  }) async {
    final r = await _send(() => http.post(
      Uri.parse('$baseUrl/api/bookings'), headers: _headers,
      body: jsonEncode({
        // Linked entities are sent by their IDs, not as complete records.
        // Matches the current teammate Booking entity's JSON mapping.
        'member': {'id': memberId},
        'resource': {'id': resourceId},
        'startDateTime': _formatDateTime(startDateTime),
        'endDateTime': _formatDateTime(endDateTime),
        'attendees': attendees,
        'status': 'CONFIRMED',
      }),
    ));
    return Booking.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<Booking> updateBooking(int id, {
    required int memberId,
    required int resourceId,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required int attendees,
    required String status,
  }) async {
    final r = await _send(() => http.put(
      Uri.parse('$baseUrl/api/bookings/$id'), headers: _headers,
      body: jsonEncode({
        'member': {'id': memberId},
        'resource': {'id': resourceId},
        'startDateTime': _formatDateTime(startDateTime),
        'endDateTime': _formatDateTime(endDateTime),
        'attendees': attendees,
        'status': status,
      }),
    ));
    return Booking.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<Booking> cancelBooking(Booking booking) => updateBooking(
    booking.id, memberId: booking.memberId, resourceId: booking.resourceId,
    startDateTime: booking.startDateTime,
    endDateTime: booking.endDateTime, attendees: booking.attendees,
    status: 'CANCELLED',
  );

  // Java LocalDateTime accepts ISO strings without a timezone suffix.
  static String _formatDateTime(DateTime value) =>
      value.toIso8601String().split('.').first;
}
