import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCardScreen extends StatefulWidget {
  final int id;
  final String? brand;
  final String? last4;
  final String? cardholderName;
  final bool isDefault;
  final int? expMonth;
  final int? expYear;

  const EditCardScreen({
    super.key,
    required this.id,
    this.brand,
    this.last4,
    this.cardholderName,
    required this.isDefault,
    this.expMonth,
    this.expYear,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final String _endpoint = 'http://hcodecraft.com/felwa/api/payment-methods';
  late final TextEditingController _nameController;
  late final TextEditingController _expiryMonthController;
  late final TextEditingController _expiryYearController;
  late bool _isDefault;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cardholderName ?? '');
    _expiryMonthController = TextEditingController(
      text: widget.expMonth != null
          ? widget.expMonth!.toString().padLeft(2, '0')
          : '',
    );
    _expiryYearController = TextEditingController(
      text: widget.expYear != null ? widget.expYear!.toString() : '',
    );
    _isDefault = widget.isDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    try {
      // Basic validation
      final mmStr = _expiryMonthController.text.trim();
      final yyStr = _expiryYearController.text.trim();
      final mm = int.tryParse(mmStr);
      final yy = int.tryParse(yyStr);
      if (mm == null || mm < 1 || mm > 12) {
        Get.snackbar('Invalid month', 'Enter a valid month (01-12)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        setState(() => _submitting = false);
        return;
      }
      if (yy == null || yyStr.length != 4) {
        Get.snackbar('Invalid year', 'Enter a 4-digit year',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        setState(() => _submitting = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uri = Uri.parse('$_endpoint/${widget.id}');
      final payload = {
        'cardholder_name': _nameController.text.trim(),
        'is_default': _isDefault,
        'exp_month': mm,
        'exp_year': yy,
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
        Get.snackbar(
          'Success',
          'Card updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        String msg = 'Failed to update card';
        try {
          final data = jsonDecode(res.body);
          if (data is Map && data['message'] is String) {
            msg = data['message'];
          }
        } catch (_) {}
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
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = (widget.brand ?? 'Card').toString();
    final last4 = (widget.last4 ?? '****').toString();
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
          'Edit Card',
          style: ConstantManager.kfont.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.black54, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$brand',
                        style: ConstantManager.kfont.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '•••• $last4',
                        style: ConstantManager.kfont,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Cardholder Name',
              style:
                  ConstantManager.kfont.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Your name on the card',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expiry Month',
                        style: ConstantManager.kfont.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expiryMonthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 2,
                      decoration: InputDecoration(
                        hintText: 'MM',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expiry Year',
                        style: ConstantManager.kfont.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expiryYearController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 4,
                      decoration: InputDecoration(
                        hintText: 'YYYY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Set as default', style: ConstantManager.kfont),
              const Spacer(),
              Switch(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ),
      ),
    );
  }
}