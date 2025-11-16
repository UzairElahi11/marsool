import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';

class SettingsService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>?> fetchCms(String endpoint) async {
    try {
      final url = Uri.parse('${_auth.baseUrl}/$endpoint');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      Future<http.Response> doGet({bool withAuth = true}) async {
        final headers = <String, String>{'Accept': 'application/json'};
        if (withAuth && token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
        final r = await http.get(url, headers: headers);
        log('CMS GET ${url.toString()} auth=$withAuth status=${r.statusCode}');
        log('CMS BODY ${r.body}');
        return r;
      }

      http.Response res = await doGet(withAuth: true);
      if (res.statusCode == 401) {
        res = await doGet(withAuth: false);
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body);
        if (json is Map && json['data'] is Map) {
          return Map<String, dynamic>.from(json['data'] as Map);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}