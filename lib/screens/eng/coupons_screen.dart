import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/utils/constants.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final List<String> _coupons = [];

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
          'Coupons',
          style: ConstantManager.kfont.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _addCouponCard(),
            const SizedBox(height: 24),
            ..._coupons.map((c) => _couponItem(c)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _addCouponCard() {
    return InkWell(
      onTap: _openAddCouponBottomSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          painter: _DashedRectPainter(
            color: Colors.green.shade400,
            strokeWidth: 1.6,
            dashLength: 8,
            dashGap: 5,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline,
                    color: Colors.green.shade700, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Add Coupon',
                  style: ConstantManager.kfont.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _couponItem(String code) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              code,
              style: ConstantManager.kfont.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Verified',
            style: ConstantManager.kfont.copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddCouponBottomSheet() async {
    final String? coupon = await _showAddCouponBottomSheet();
    if (coupon != null && coupon.trim().isNotEmpty) {
      setState(() {
        _coupons.add(coupon.trim());
      });
      Get.snackbar('Coupon added', coupon.trim(),
          backgroundColor: Colors.green.shade100,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<String?> _showAddCouponBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final TextEditingController codeController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setStateBottom) {
              final bool valid = codeController.text.trim().isNotEmpty;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Coupon',
                          style: ConstantManager.kfont.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Enter coupon number',
                      style: ConstantManager.kfont.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 320,
                      child: TextField(
                        controller: codeController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (_) => setStateBottom(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: ConstantManager.kfont.copyWith(
                            color: Colors.black87),
                        children: [
                          const TextSpan(
                              text:
                                  'Want to get latest coupons? follow us on '),
                          TextSpan(
                            text: 'X',
                            style: ConstantManager.kfont.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ', '),
                          TextSpan(
                            text: 'Instgram',
                            style: ConstantManager.kfont.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ', and '),
                          TextSpan(
                            text: 'Facebook',
                            style: ConstantManager.kfont.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: valid
                          ? () => Navigator.of(ctx)
                              .pop(codeController.text.trim())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Verify'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DashedRectPainter({
    this.color = Colors.green,
    this.strokeWidth = 1.0,
    this.dashLength = 6.0,
    this.dashGap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, paint, const Offset(0, 0), Offset(size.width, 0));
    _drawDashedLine(
        canvas, paint, Offset(size.width, 0), Offset(size.width, size.height));
    _drawDashedLine(canvas, paint, Offset(size.width, size.height),
        Offset(0, size.height));
    _drawDashedLine(canvas, paint, Offset(0, size.height), const Offset(0, 0));
  }

  void _drawDashedLine(
      Canvas canvas, Paint paint, Offset start, Offset end) {
    final double totalLength = (end - start).distance;
    final Offset direction = (end - start) / totalLength;

    double current = 0;
    while (current < totalLength) {
      final double next = current + dashLength;
      final double segment = next > totalLength ? totalLength - current : dashLength;
      final Offset p1 = start + direction * current;
      final Offset p2 = start + direction * (current + segment);
      canvas.drawLine(p1, p2, paint);
      current += dashLength + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}