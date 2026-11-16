import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member.dart';
import '../models/booking.dart';
import 'api_exception.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

    // ---- Member methods (inside the ApiService class) ----
  // baseUrl is the existing field, e.g. 'http://localhost:8080'

  Future<List<Member>> getMembers() async {
    final r = await http.get(Uri.parse('$baseUrl/api/members'));
    _checkResponse(r);
    return (jsonDecode(r.body) as List)
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Member> createMember(Member m) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/members'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(m.toJson()),
    );
    _checkResponse(r);
    return Member.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<List<Booking>> getMemberBookings(int memberId) async {
    final r = await http.get(Uri.parse('$baseUrl/api/members/$memberId/bookings'));
    _checkResponse(r);
    return (jsonDecode(r.body) as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Skip this if Karem already has a similar helper
  void _checkResponse(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    var msg = 'Request failed (${r.statusCode})';
    try {
      final body = jsonDecode(r.body);
      if (body is Map && body['message'] != null) msg = body['message'].toString();
    } catch (_) {}
    throw ApiException(msg);
  }
}