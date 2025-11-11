import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final bool isRTL;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    this.isRTL = false,
  });

  Widget _navItem(IconData icon, String labelKey, int index) {
    final selected = currentIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
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
                color: selected ? const Color(0xffe7712b) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? const Color(0xffe7712b) : Colors.grey.shade700,
              ),
              child: Text(labelKey.tr),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
                    child: _navItem(Icons.storefront_rounded, 'bottom.store', 0),
                  ),
                  Expanded(
                    child: _navItem(Icons.receipt_long_rounded, 'bottom.orders', 1),
                  ),
                  Expanded(
                    child: _navItem(Icons.shopping_cart_rounded, 'bottom.cart', 2),
                  ),
                  Expanded(
                    child: _navItem(Icons.person_rounded, 'bottom.profile', 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}