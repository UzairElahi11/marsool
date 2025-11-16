import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/cart_screen.dart';
import 'package:petshow/screens/eng/delivery_page.dart';
import 'package:petshow/screens/eng/profile_tab.dart';
import 'package:petshow/widgets/bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'eng/store_tab.dart';

class PetShopApp extends StatelessWidget {
  const PetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StorePage(),
    const DeliveryPage(),
    const OrdersPage(),
    const CartScreen(),
    const ProfileTab(),
  ];

  // Space to reserve so body ends above the floating bar
  double _reservedBottomSpace(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const barHeight = 72.0;
    const lift = 10.0;
    return barHeight + lift + safeBottom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _reservedBottomSpace(context)),
            child: _pages[_currentIndex],
          ),

          // Floating custom bottom bar (unchanged)
          Positioned(
            left: 12,
            right: 12,
            bottom: -10,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 10),
              child: BottomBar(
                currentIndex: _currentIndex,
                onItemSelected: (i) => setState(() => _currentIndex = i),
                isRTL: (Get.locale?.languageCode == 'ar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ------------------- STORE PAGE -------------------
//

// ------------------- ORDERS PAGE -------------------
//
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final String _ordersUrl = 'http://hcodecraft.com/felwa/api/orders';
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
        Uri.parse(_ordersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse JSON robustly like OrderHistoryScreen
        List<dynamic> items = [];
        try {
          final data = jsonDecode(response.body);
          if (data is List) {
            items = data;
          } else if (data is Map) {
            final inner = data['data'];
            if (inner is Map && inner['items'] is List) {
              items = List<dynamic>.from(inner['items']);
            } else if (inner is List) {
              items = List<dynamic>.from(inner);
            }
          }
        } catch (_) {
          items = const [];
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(child: _errorView(context, _error!))
            else if (_orders.isEmpty)
              const Expanded(
                child: Center(child: Text('No orders found')),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: ListView.separated(
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const Divider(),
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

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow.shade100,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text('Order #$id'),
                        subtitle: Text(
                          'Date: $createdAt\nStatus: $status',
                        ),
                        trailing: (total != null)
                            ? Text(
                                '${total.toString()} ${currency.toString()}',
                                style:
                                    const TextStyle(color: Colors.orange),
                              )
                            : null,
                        isThreeLine: true,
                        onTap: () {
                          // TODO: navigate to order detail
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
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
            Icon(Icons.error_outline, color: Colors.redAccent.shade200, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
//
// //
// // ------------------- NOTIFICATIONS PAGE -------------------
// //
// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final notifications = [
//       {'title': 'Order Shipped', 'desc': 'Your Cat Toy has been shipped!'},
//       {'title': 'New Offer!', 'desc': 'Get 20% off on Dog Food this week!'},
//       {'title': 'Delivery Completed', 'desc': 'Your Bird Cage was delivered successfully.'},
//     ];
//
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Notifications',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: notifications.length,
//                 separatorBuilder: (_, __) => const Divider(),
//                 itemBuilder: (context, index) {
//                   final note = notifications[index];
//                   return ListTile(
//                     leading: const Icon(Icons.notifications_active, color: Colors.orange),
//                     title: Text(note['title']!),
//                     subtitle: Text(note['desc']!),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
