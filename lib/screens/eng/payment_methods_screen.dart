import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/screens/eng/add_card_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _cards = [];

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
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.credit_card, color: Colors.black54, size: 28),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
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
                  trailing:
                      isDefault ? const Icon(Icons.check, color: Colors.green) : null,
                ),
                const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}