import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petshow/screens/eng/payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryColor = const Color(0xffe7712b);
  final Color secondaryColor = const Color(0xff282f5a);

  bool isLoading = true;
  List cartItems = [];
  double totalAmount = 0;
  String currency = "PKR";

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('http://hcodecraft.com/felwa/api/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );
      //Print URL
      log("URL::: ${response.request?.url}");
      log("RESPONSE CART::: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] ?? [];
        final meta = jsonResponse['meta'] ?? {};

        setState(() {
          cartItems = data;
          totalAmount =
              double.tryParse(meta['total_amount']?.toString() ?? '0') ?? 0;
          currency = meta['currency'] ?? 'PKR';
          isLoading = false;
        });
      } else {
        debugPrint('Failed to fetch cart: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> updateCartItem(int cartId, int newQuantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('http://hcodecraft.com/felwa/api/update-cart/$cartId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'quantity': newQuantity.toString()},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('cart.snackbar.updateSuccess'.tr),
            backgroundColor: Colors.green,
          ),
        );
        await fetchCart();
      } else {
        debugPrint('Update failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update cart'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Error updating cart: $e');
    }
  }

  Future<void> deleteCartItem(int cartId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('http://hcodecraft.com/felwa/api/delete-cart/$cartId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('cart.snackbar.deleteSuccess'.tr),
            backgroundColor: Colors.green,
          ),
        );
        await fetchCart();
      } else {
        debugPrint('Delete failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete item'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = (Get.locale?.languageCode == 'ar');

    return Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(
                'cart.title'.tr,
                style: GoogleFonts.ubuntu(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : cartItems.isEmpty
                    ? Center(
                        child: Text(
                          'cart.empty'.tr,
                          style: GoogleFonts.ubuntu(
                              fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Column(children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              final product = item['product'] ?? {};
                              final store = product['store'] ?? {};

                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['title'] ?? '',
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: secondaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              store['name'] ?? '',
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                // Quantity control
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    int q = item['quantity'];
                                                    if (q > 1)
                                                      updateCartItem(
                                                          item['id'], q - 1);
                                                  },
                                                ),
                                                Text(
                                                  item['quantity'].toString(),
                                                  style: GoogleFonts.ubuntu(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    int q = item['quantity'];
                                                    updateCartItem(
                                                        item['id'], q + 1);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Price and delete button
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${product['price']} ${product['currency'] ?? currency}',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 14,
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.grey),
                                            onPressed: () =>
                                                deleteCartItem(item['id']),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Bottom total bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'cart.total'.tr}: $totalAmount $currency',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentScreen(
                                        totalAmount: totalAmount,
                                        currency: currency,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('cart.checkout'.tr,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ])));
  }
}
