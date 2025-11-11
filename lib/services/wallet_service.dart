import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';

class WalletService {
  final AuthService _auth = AuthService();

  bool _ok(int status) => status >= 200 && status < 300;

  void _showApiError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  String _extractMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] is String) {
        return data['message'];
      }
    } catch (_) {}
    return fallback;
  }

  Future<Map<String, dynamic>?> getWalletDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${_auth.baseUrl}/wallet');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (_ok(response.statusCode)) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data']);
        }
        return null;
      } else {
        _showApiError(_extractMessage(response, 'Failed to load wallet'));
        return null;
      }
    } catch (e) {
      _showApiError(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> topupWallet({
    required double amount,
    required int paymentMethodId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${_auth.baseUrl}/wallet/topup');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'payment_method_id': paymentMethodId,
        }),
      );

      if (_ok(response.statusCode)) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data']);
        }
        return null;
      } else {
        _showApiError(_extractMessage(response, 'Failed to top up wallet'));
        return null;
      }
    } catch (e) {
      _showApiError(e.toString());
      return null;
    }
  }
}