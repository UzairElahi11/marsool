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

  @override
  Widget build(BuildContext context) {
    final isRTL = (Get.locale?.languageCode == 'ar');

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.storefront), label: 'bottom.store'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_bag_outlined),
                label: 'bottom.orders'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_cart), label: 'bottom.cart'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: 'bottom.profile'.tr),
          ],
        ),
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
