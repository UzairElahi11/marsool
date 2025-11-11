import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponService {
  final String baseUrl = 'https://hcodecraft.com/felwa/api';

  bool _ok(int status) => status >= 200 && status < 300;

  String _extractMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] is String) {
        return data['message'];
      }
    } catch (_) {}
    return fallback;
  }

  void _showApiError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  Future<List<dynamic>> getCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/coupons'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('COUPONS URL::: ${response.request?.url}');
      log('COUPONS RESPONSE::: ${response.body}');

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Failed to fetch coupons'));
        return [];
      }

      final data = jsonDecode(response.body);
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map && inner['items'] is List) {
          return List<dynamic>.from(inner['items']);
        }
        if (inner is List) {
          return List<dynamic>.from(inner);
        }
      } else if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      _showApiError('Error fetching coupons: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createCoupon({
    required String code,
    required String description,
    required String discountType, // e.g., "percent" or "fixed"
    required num discountValue,
    num? maxDiscount,
    num? minOrderAmount,
    required int storeId,
    required String startsAt, // ISO date string
    required String expiresAt, // ISO date string
    required int usageLimit,
    required int usageLimitPerUser,
    required bool isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/coupons'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'code': code,
          'description': description,
          'discount_type': discountType,
          'discount_value': discountValue,
          if (maxDiscount != null) 'max_discount': maxDiscount,
          if (minOrderAmount != null) 'min_order_amount': minOrderAmount,
          'store_id': storeId,
          'starts_at': startsAt,
          'expires_at': expiresAt,
          'usage_limit': usageLimit,
          'usage_limit_per_user': usageLimitPerUser,
          'is_active': isActive,
        }),
      );

      log('COUPON CREATE URL::: ${response.request?.url}');
      log('COUPON CREATE BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}');
      log('COUPON CREATE RESPONSE::: ${response.body}');

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Failed to create coupon'));
        return null;
      }

      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : {'data': data};
    } catch (e) {
      _showApiError('Error creating coupon: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> validateCoupon({
    required String code,
    required double orderAmount,
    int? storeId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/coupons/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'code': code,
          'order_amount': orderAmount,
          if (storeId != null) 'store_id': storeId,
        }),
      );

      log('COUPON VALIDATE URL::: ${response.request?.url}');
      log('COUPON VALIDATE BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}');
      log('COUPON VALIDATE RESPONSE::: ${response.body}');

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Invalid / expired coupon'));
        return null;
      }

      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : {'data': data};
    } catch (e) {
      _showApiError('Error validating coupon: $e');
      return null;
    }
  }
}