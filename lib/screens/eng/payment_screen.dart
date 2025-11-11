import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petshow/screens/main_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String currency;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.currency,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color primaryColor = const Color(0xffe7712b);
  final Color secondaryColor = const Color(0xff282f5a);

  final TextEditingController _orderNotesController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();

  List<dynamic> _addresses = [];
  bool _loadingAddresses = false;
  String? _addressError;
  int? _selectedAddressId;
  bool _placingOrder = false;

  final String _baseUrl = 'https://hcodecraft.com/felwa/api';

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  @override
  void dispose() {
    _orderNotesController.dispose();
    _couponCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Delivery Details',
          style: GoogleFonts.ubuntu(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.9),
                    primaryColor.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total',
                            style: GoogleFonts.ubuntu(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.totalAmount} ${widget.currency}',
                          style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Payment form removed. Only delivery details retained below.
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Delivery Details',
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    if (_loadingAddresses)
                      const LinearProgressIndicator()
                    else if (_addressError != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _addressError!,
                              style:
                                  GoogleFonts.ubuntu(color: Colors.redAccent),
                            ),
                          ),
                          TextButton(
                            onPressed: _fetchAddresses,
                            child: Text(
                              'Retry',
                              style: GoogleFonts.ubuntu(color: primaryColor),
                            ),
                          ),
                        ],
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: _selectedAddressId,
                        items: _addresses
                            .map((e) {
                              final m = e is Map ? e : <String, dynamic>{};
                              final id = m['id'];
                              if (id is! int) return null;

                              final label =
                                  m['label'] ?? m['type'] ?? 'Address';
                              final parts = [m['address'], m['area'], m['city']]
                                  .where((p) =>
                                      p != null &&
                                      p.toString().trim().isNotEmpty)
                                  .map((p) => p.toString());
                              final text = parts.isNotEmpty
                                  ? '$label · ${parts.join(', ')}'
                                  : '$label';

                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  text,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ubuntu(),
                                ),
                              );
                            })
                            .whereType<DropdownMenuItem<int>>()
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedAddressId = val),
                        decoration: InputDecoration(
                          labelText: 'Select Address',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _orderNotesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add delivery notes',
                        prefixIcon: const Icon(Icons.note_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _couponCodeController,
                      decoration: InputDecoration(
                        labelText: 'Coupon Code (optional)',
                        prefixIcon: const Icon(Icons.local_offer_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _placingOrder
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Placing Order...',
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      'Place Order',
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _loadingAddresses = true;
      _addressError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse('$_baseUrl/addresses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('ADDRESSES URL::: ${res.request?.url}');
      log('ADDRESSES STATUS::: ${res.statusCode}');
      log('ADDRESSES RESPONSE::: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final data = decoded is Map ? decoded['data'] : null;
        final items = (data is List)
            ? List<dynamic>.from(data)
            : (decoded is List ? decoded : <dynamic>[]);

        int? preselected;
        for (final e in items) {
          if (e is Map && e['id'] is int) {
            preselected = e['id'] as int;
            break;
          }
        }

        setState(() {
          _addresses = items;
          _selectedAddressId = preselected;
          _loadingAddresses = false;
        });
      } else {
        final msg = 'Failed to fetch addresses (${res.statusCode})';
        setState(() {
          _addressError = msg;
          _loadingAddresses = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      final msg = 'Error fetching addresses: $e';
      setState(() {
        _addressError = msg;
        _loadingAddresses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final notes = _orderNotesController.text.trim();
    final coupon = _couponCodeController.text.trim();

    setState(() => _placingOrder = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final payload = <String, dynamic>{
        'address_id': _selectedAddressId,
        'notes': notes,
        if (coupon.isNotEmpty) 'coupon_code': coupon,
      };

      final uri = Uri.parse('$_baseUrl/create-order');
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 20));

      // log the request details
      log('CREATE ORDER URL::: ${res.request?.url}');
      log('TOKEN::: $token');
      log('CREATE ORDER PAYLOAD::: $payload');
      log('CREATE ORDER RESPONSE::: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order placed successfully.',
              style: GoogleFonts.ubuntu(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 600),
          ),
        );
        // Navigate back to Home (MainPage) after short delay so SnackBar shows
        await Future.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      } else {
        final msg = 'Order failed (${res.statusCode}).';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.runtimeType}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }
}
