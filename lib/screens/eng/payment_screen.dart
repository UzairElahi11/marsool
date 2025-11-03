import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool _isValidCardNumber(String input) {
    final sanitized = input.replaceAll(RegExp(r'\s+'), '');
    if (sanitized.isEmpty || !RegExp(r'^\d+$').hasMatch(sanitized))
      return false;

    int sum = 0;
    bool alternate = false;

    for (int i = sanitized.length - 1; i >= 0; i--) {
      int digit = int.parse(sanitized[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Processing payment of ${widget.totalAmount} ${widget.currency}...',
            style: GoogleFonts.ubuntu(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Payment',
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
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Cardholder name: no leading space, only letters and spaces
                      TextFormField(
                        controller: _nameController,
                        inputFormatters: [
                          LeadingSpaceTrimmer(),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z ]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Name on Card',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          final value = v ?? '';
                          if (value.trim().isEmpty)
                            return 'Enter cardholder name';
                          if (value.startsWith(' ')) return 'No leading space';
                          if (!RegExp(r'^[A-Za-z ]+$').hasMatch(value))
                            return 'Only alphabets allowed';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Card number: digits only
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LeadingSpaceTrimmer(),
                          CardNumberInputFormatter(),
                        ],
                        maxLength: 19,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: 'Enter digits only',
                          counterText: '',
                          prefixIcon: const Icon(Icons.credit_card),
                          suffixIcon: Icon(_brandIcon(_cardBrand),
                              color: secondaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) =>
                            setState(() => _cardBrand = _detectCardBrand(v)),
                        validator: (v) {
                          final value = (v ?? '').replaceAll(' ', '');
                          if (value.isEmpty) return 'Enter card number';
                          if (!RegExp(r'^\d+$').hasMatch(value))
                            return 'Digits only';
                          if (value.length < 13 || value.length > 19)
                            return 'Invalid card length';
                          if (!_isValidCardNumber(value))
                            return 'Invalid card number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Expiry month: allow 2 digits only
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryMonthController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LeadingSpaceTrimmer(),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 2,
                              decoration: InputDecoration(
                                labelText: 'Expiry Month',
                                hintText: 'MM',
                                counterText: '',
                                prefixIcon:
                                    const Icon(Icons.calendar_today_outlined),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) {
                                final value = (v ?? '');
                                if (!RegExp(r'^\d{2}$').hasMatch(value))
                                  return 'Enter 2 digits (MM)';
                                final month = int.tryParse(value);
                                if (month == null || month < 1 || month > 12)
                                  return 'Invalid month';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Expiry year: max 4 digit numbers
                          Expanded(
                            child: TextFormField(
                              controller: _expiryYearController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LeadingSpaceTrimmer(),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: 'Expiry Year',
                                hintText: 'YYYY',
                                counterText: '',
                                prefixIcon: const Icon(Icons.event),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) {
                                final value = (v ?? '');
                                if (!RegExp(r'^\d{1,4}$').hasMatch(value))
                                  return 'Up to 4 digits';
                                if (value.length != 4)
                                  return 'Enter 4 digits (YYYY)';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // CVV: allow 3 max
                      TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LeadingSpaceTrimmer(),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 3,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '3 digits',
                          counterText: '',
                          prefixIcon: const Icon(Icons.shield_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          final len = (v ?? '').length;
                          if (len == 0) return 'Enter CVV';
                          if (len > 3) return 'Max 3 digits';
                          if (len != 3) return 'Enter 3 digits';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: _saveCard,
                        onChanged: (val) => setState(() => _saveCard = val),
                        title: Text('Save this card for future payments',
                            style: GoogleFonts.ubuntu()),
                        activeThumbColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitPayment,
                          icon: const Icon(Icons.lock),
                          label: Text('Pay Securely',
                              style: GoogleFonts.ubuntu(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _saveCard = false;
  String _cardBrand = '';
  IconData _brandIcon(String brand) {
    switch (brand) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      case 'discover':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _detectCardBrand(String number) {
    final n = number.replaceAll(' ', '');
    if (RegExp(r'^4').hasMatch(n)) return 'visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(n)) return 'mastercard';
    if (RegExp(r'^3[47]').hasMatch(n)) return 'amex';
    if (RegExp(r'^6(?:011|5)').hasMatch(n)) return 'discover';
    return '';
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final groups = <String>[];
    for (var i = 0; i < digitsOnly.length; i += 4) {
      groups.add(digitsOnly.substring(
          i, i + 4 > digitsOnly.length ? digitsOnly.length : i + 4));
    }
    final formatted = groups.join(' ');
    final cursorPosition = formatted.length;
    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: cursorPosition));
  }
}

class LeadingSpaceTrimmer extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    // Remove any leading spaces
    final trimmed = text.replaceFirst(RegExp(r'^\s+'), '');
    final diff = text.length - trimmed.length;
    final newOffset =
        (newValue.selection.baseOffset - diff).clamp(0, trimmed.length);
    return TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
