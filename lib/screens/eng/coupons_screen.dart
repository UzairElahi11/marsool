import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/services/coupon_service.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final CouponService _couponService = CouponService();
  List<dynamic> _coupons = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final data = await _couponService.getCoupons();
    setState(() {
      _coupons = data;
      _loading = false;
      if (data.isEmpty) {
        _error = null; // empty state rather than error
      }
    });
  }

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
            if (_loading)
              const Center(child: CircularProgressIndicator()),
            if (!_loading && _coupons.isEmpty)
              Center(
                child: Text(
                  'No coupons found',
                  style: ConstantManager.kfont,
                ),
              ),
            if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: ConstantManager.kfont.copyWith(color: Colors.red),
                ),
              ),
            if (!_loading && _coupons.isNotEmpty)
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

  Widget _couponItem(dynamic coupon) {
    final String code = _extractCode(coupon);
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

  String _extractCode(dynamic coupon) {
    if (coupon is String) return coupon;
    if (coupon is Map) {
      return (coupon['code'] ?? coupon['coupon_code'] ?? '').toString();
    }
    return coupon?.toString() ?? '';
  }

  Future<void> _openAddCouponBottomSheet() async {
    final _ValidateInput? input = await _showAddCouponBottomSheet();
    if (input == null) return;

    final result = await _couponService.validateCoupon(
      code: input.code,
      orderAmount: input.orderAmount,
      storeId: input.storeId,
    );

    if (result != null) {
      final msg = (result['message'] ?? 'Coupon validated').toString();
      Get.snackbar(
        'Success',
        msg,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Optionally add to visible list if not already present
      final code = input.code.trim();
      if (_coupons.where((c) => _extractCode(c) == code).isEmpty) {
        setState(() {
          _coupons.insert(0, {'code': code});
        });
      }
    }
  }

  Future<_ValidateInput?> _showAddCouponBottomSheet() {
    return showModalBottomSheet<_ValidateInput?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final TextEditingController codeController = TextEditingController();
        final TextEditingController amountController = TextEditingController();
        final TextEditingController storeController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setStateBottom) {
              final bool valid = codeController.text.trim().isNotEmpty &&
                  double.tryParse(amountController.text.trim().isEmpty
                          ? '0'
                          : amountController.text.trim()) !=
                      null;
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
                      'Enter coupon code',
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
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 320,
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Order amount (e.g., 1000.00)',
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
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 320,
                      child: TextField(
                        controller: storeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Store ID (optional)',
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
                          ? () {
                              final double amount = double.tryParse(
                                    amountController.text.trim().isEmpty
                                        ? '0'
                                        : amountController.text.trim(),
                                  ) ??
                                  0.0;
                              final int? storeId = storeController.text.trim().isEmpty
                                  ? null
                                  : int.tryParse(storeController.text.trim());
                              Navigator.of(ctx).pop(
                                _ValidateInput(
                                  codeController.text.trim(),
                                  amount,
                                  storeId,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Validate'),
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

class _ValidateInput {
  final String code;
  final double orderAmount;
  final int? storeId;
  _ValidateInput(this.code, this.orderAmount, this.storeId);
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