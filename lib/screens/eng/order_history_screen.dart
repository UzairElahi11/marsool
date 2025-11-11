import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petshow/utils/constants.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final String ordersUrl = 'http://hcodecraft.com/felwa/api/orders';

  bool _loading = true;
  String? _error;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(ordersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('ORDERS URL::: ${response.request?.url}');
      log('ORDERS STATUS::: ${response.statusCode}');
      log('ORDERS RESPONSE::: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final parsed = jsonDecode(response.body);

        List<dynamic> items = [];
        if (parsed is List) {
          items = parsed;
        } else if (parsed is Map) {
          final inner = parsed['data'];
          if (inner is Map && inner['items'] is List) {
            items = List<dynamic>.from(inner['items']);
          } else if (inner is List) {
            items = List<dynamic>.from(inner);
          }
        }

        setState(() {
          _orders = items;
          _loading = false;
        });
      } else {
        final msg = _extractMessage(
            response, 'Failed to fetch orders (${response.statusCode})');
        setState(() {
          _error = msg;
          _loading = false;
        });
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      final msg = 'Error fetching orders: $e';
      setState(() {
        _error = msg;
        _loading = false;
      });
      Get.snackbar(
        'Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  String _extractMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] is String) return data['message'];
      if (data is Map && data['error'] is String) return data['error'];
    } catch (_) {}
    return fallback;
  }

  Future<void> _retry() async {
    await _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = 'profile.orderHistory'.tr;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          titleText,
          style: ConstantManager.kfont.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(context, _error!)
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        'No orders found',
                        style: ConstantManager.kfont,
                      ),
                    )
                  : RefreshIndicator(
                      color: ConstantManager.primaryColor,
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final map = order is Map<String, dynamic>
                              ? order
                              : <String, dynamic>{};
                          final id = map['id'] ??
                              map['order_id'] ??
                              map['number'] ??
                              (index + 1);
                          final status = map['status'] ?? map['state'] ?? '';
                          final total = map['total'] ??
                              map['total_amount'] ??
                              map['amount'];
                          final currency = map['currency'] ?? '';
                          final createdAt =
                              map['created_at'] ?? map['date'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blueGrey.shade100,
                                child: const Icon(Icons.receipt_long,
                                    color: Colors.black87),
                              ),
                              title: Text(
                                'Order #$id',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ConstantManager.kfont
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (status.toString().isNotEmpty)
                                    Text(
                                      'Status: $status',
                                      style: ConstantManager.kfont
                                          .copyWith(color: Colors.black54),
                                    ),
                                  if (createdAt.toString().isNotEmpty)
                                    Text(
                                      'Date: $createdAt',
                                      style: ConstantManager.kfont
                                          .copyWith(color: Colors.black54),
                                    ),
                                ],
                              ),
                              trailing: (total != null)
                                  ? Text(
                                      '${total.toString()} ${currency.toString()}',
                                      style: ConstantManager.kfont.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                // TODO: Navigate to order detail if available
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: Colors.redAccent.shade200, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ConstantManager.kfont.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantManager.primaryColor),
              child: Text(
                'Retry',
                style: ConstantManager.kfont.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
