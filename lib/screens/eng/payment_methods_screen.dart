import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/add_card_screen.dart';
import 'package:petshow/screens/eng/edit_card_screen.dart';
import 'package:petshow/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _cards = [];
  final String _endpoint = 'http://hcodecraft.com/felwa/api/payment-methods';
  bool _loading = false;
  String? _error;
  List<dynamic> _serverMethods = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('PAYMENT METHODS URL::: ${res.request?.url}');
      log('PAYMENT METHODS STATUS::: ${res.statusCode}');
      log('PAYMENT METHODS RESPONSE::: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        List<dynamic> items = [];
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          if (data is Map && data['items'] is List) {
            items = List<dynamic>.from(data['items']);
          } else if (data is List) {
            items = List<dynamic>.from(data);
          }
        }
        setState(() {
          _serverMethods = items;
          _loading = false;
        });
      } else {
        final msg = _extractMessage(
            res, 'Failed to fetch payment methods (${res.statusCode})');
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
      final msg = 'Error fetching payment methods: $e';
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

  String _last4(dynamic number) {
    final s = number?.toString() ?? '';
    return s.length >= 4 ? s.substring(s.length - 4) : '****';
  }

  Future<void> _removePaymentMethod(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('$_endpoint/$id/default');
      final res = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('REMOVE CARD URL::: ${res.request?.url}');
      log('REMOVE CARD STATUS::: ${res.statusCode}');
      log('REMOVE CARD RESPONSE::: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          _serverMethods = _serverMethods.where((pm) {
            final m = pm is Map<String, dynamic> ? pm : <String, dynamic>{};
            final pmId = m['id'];
            return pmId != id;
          }).toList();
        });
        Get.snackbar(
          'Success',
          'Card removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final msg = _extractMessage(res, 'Failed to remove card');
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error removing card: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _editPaymentMethod(
    int id, {
    String? cardholderName,
    bool? isDefault,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uri = Uri.parse('$_endpoint/$id');
      final payload = <String, dynamic>{
        if (cardholderName != null) 'cardholder_name': cardholderName,
        if (isDefault != null) 'is_default': isDefault,
      };

      final res = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      log('EDIT CARD URL::: ${res.request?.url}');
      log('EDIT CARD STATUS::: ${res.statusCode}');
      log('EDIT CARD RESPONSE::: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Refresh list to reflect changes
        await _fetchPaymentMethods();
        Get.snackbar(
          'Success',
          'Card updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final msg = _extractMessage(res, 'Failed to update card');
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error updating card: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> map) async {
    final idRaw = map['id'];
    final int? id =
        idRaw is int ? idRaw : (idRaw is String ? int.tryParse(idRaw) : null);
    if (id == null) {
      Get.snackbar('Error', 'Missing card id',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    final nameController = TextEditingController(
      text: (map['cardholder_name'] ?? map['name'] ?? '').toString(),
    );
    bool isDefault = (map['is_default'] == true) || (map['default'] == true);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Card'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Cardholder Name',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Set as default'),
                    const Spacer(),
                    Switch(
                      value: isDefault,
                      onChanged: (v) => setState(() => isDefault = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _editPaymentMethod(
                  id,
                  cardholderName: nameController.text.trim(),
                  isDefault: isDefault,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRemove(int id) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Card'),
        content: const Text('Are you sure you want to remove this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _removePaymentMethod(id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: ConstantManager.kfont.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _fetchPaymentMethods,
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantManager.primaryColor,
            ),
            child: Text(
              'Retry',
              style: ConstantManager.kfont.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Payment Methods',
          style: ConstantManager.kfont.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.amber.shade300,
              child: const Icon(Icons.monetization_on_outlined,
                  color: Colors.white),
            ),
            title: Text(
              'Cash',
              style: ConstantManager.kfont.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.credit_card, color: Colors.black54, size: 28),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            title: Text(
              'Add New Card',
              style: ConstantManager.kfont.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final result = await Get.to<Map<String, dynamic>>(
                () => const AddCardScreen(),
              );
              if (result != null) {
                setState(() {
                  _cards.add(result);
                });
              }
            },
          ),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null) _errorView(context, _error!),
          if (!_loading && _error == null)
            ..._serverMethods.map((pm) {
              final map = pm is Map<String, dynamic> ? pm : <String, dynamic>{};
              final brand = map['brand'] ?? map['type'] ?? 'Card';
              final last4 = map['last4'] ?? _last4(map['card_number']);
              final name = map['cardholder_name'] ?? map['name'] ?? '';
              final isDefault =
                  (map['is_default'] == true) || (map['default'] == true);
              final idRaw = map['id'];
              final int? id = idRaw is int
                  ? idRaw
                  : (idRaw is String ? int.tryParse(idRaw) : null);
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.credit_card,
                        color: Colors.black54, size: 28),
                    title: Text(
                      '$brand •••• $last4',
                      style: ConstantManager.kfont.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: name.isNotEmpty
                        ? Text(name, style: ConstantManager.kfont)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDefault)
                          const Icon(Icons.check, color: Colors.green),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.blueGrey),
                          onPressed: id == null
                              ? null
                              : () async {
                                  // Try to derive expiry values from server map
                                  final emRaw = map['exp_month'] ??
                                      map['expiry_month'] ??
                                      map['month'];
                                  final eyRaw = map['exp_year'] ??
                                      map['expiry_year'] ??
                                      map['year'];
                                  int? expMonth;
                                  int? expYear;
                                  if (emRaw is int) {
                                    expMonth = emRaw;
                                  } else if (emRaw is String) {
                                    expMonth = int.tryParse(emRaw);
                                  }
                                  if (eyRaw is int) {
                                    expYear = eyRaw;
                                  } else if (eyRaw is String) {
                                    expYear = int.tryParse(eyRaw);
                                  }

                                  final updated = await Get.to<bool>(
                                    () => EditCardScreen(
                                      id: id,
                                      brand: brand?.toString(),
                                      last4: last4?.toString(),
                                      cardholderName: name.isNotEmpty
                                          ? name.toString()
                                          : null,
                                      isDefault: isDefault,
                                      expMonth: expMonth,
                                      expYear: expYear,
                                    ),
                                  );
                                  if (updated == true) {
                                    await _fetchPaymentMethods();
                                  }
                                },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed:
                              id == null ? null : () => _confirmRemove(id),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: set default or navigate to details if needed
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
          // Locally added cards (from AddCardScreen)
          ..._cards.map((card) {
            final String brand = card['brand'] ?? 'Card';
            final String last4 = card['last4'] ?? '****';
            final String name = card['name'] ?? '';
            final bool isDefault = card['default'] == true;
            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.credit_card,
                      color: Colors.black54, size: 28),
                  title: Text(
                    '$brand •••• $last4',
                    style: ConstantManager.kfont.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: name.isNotEmpty
                      ? Text(name, style: ConstantManager.kfont)
                      : null,
                  trailing: isDefault
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
