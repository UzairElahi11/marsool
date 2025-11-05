import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/screens/eng/cart_screen.dart';
import 'package:petshow/screens/eng/profile_tab.dart';

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
    const OrdersPage(),
    const CartScreen(),
    const ProfileTab(),
  ];

  // Simple nav item: icon + label, brand color when selected
  Widget _navItem(IconData icon, String labelKey, int index) {
    final selected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Icon(
                icon,
                size: 26,
                color:
                    selected ? const Color(0xffe7712b) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color:
                    selected ? const Color(0xffe7712b) : Colors.grey.shade700,
              ),
              child: Text(labelKey.tr),
            ),
          ],
        ),
      ),
    );
  }

  // Space to reserve so body ends above the floating bar
  double _reservedBottomSpace(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const lift = 10.0;
    return lift + safeBottom;
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = (Get.locale?.languageCode == 'ar');

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
              child: Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.92),
                              Colors.white.withOpacity(0.78),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _navItem(
                                Icons.storefront_rounded,
                                'bottom.store',
                                0,
                              ),
                            ),
                            Expanded(
                              child: _navItem(
                                Icons.receipt_long_rounded,
                                'bottom.orders',
                                1,
                              ),
                            ),
                            Expanded(
                              child: _navItem(
                                Icons.shopping_cart_rounded,
                                'bottom.cart',
                                2,
                              ),
                            ),
                            Expanded(
                              child: _navItem(
                                Icons.person_rounded,
                                'bottom.profile',
                                3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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

//
// ------------------- ORDERS PAGE -------------------
//
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'title': 'Dog Food',
        'date': 'Oct 12, 2025',
        'status': 'Delivered',
        'price': '\$20'
      },
      {
        'title': 'Cat Toy',
        'date': 'Oct 10, 2025',
        'status': 'Shipped',
        'price': '\$10'
      },
      {
        'title': 'Bird Cage',
        'date': 'Oct 8, 2025',
        'status': 'Processing',
        'price': '\$30'
      },
    ];

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
                  color: Colors.orange),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.yellow.shade100,
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.orange),
                    ),
                    title: Text(order['title']!),
                    subtitle: Text(
                        'Date: ${order['date']}\nStatus: ${order['status']}'),
                    trailing: Text(order['price']!,
                        style: const TextStyle(color: Colors.orange)),
                    isThreeLine: true,
                  );
                },
              ),
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
