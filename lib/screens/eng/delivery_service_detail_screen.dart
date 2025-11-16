import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/store_tab.dart' show Shimmer; 
import 'package:petshow/screens/eng/location_picker_screen.dart';

class DeliveryServiceDetailScreen extends StatefulWidget {
  final int categoryId;
  const DeliveryServiceDetailScreen({super.key, required this.categoryId});

  @override
  State<DeliveryServiceDetailScreen> createState() => _DeliveryServiceDetailScreenState();
}

class _DeliveryServiceDetailScreenState extends State<DeliveryServiceDetailScreen> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _service;
  PickedLocation? _pickup;
  PickedLocation? _dropoff;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('https://hcodecraft.com/felwa/api/delivery-services/${widget.categoryId}');
      log('DELIVERY DETAIL URL: $url');
      final res = await http.get(url, headers: {'Accept': 'application/json'});
      if (!mounted) return;
      log('DELIVERY DETAIL STATUS: ${res.statusCode}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        log('DELIVERY DETAIL BODY: ${res.body}');
        final data = jsonDecode(res.body);
        final map = (data is Map && data['data'] is Map) ? Map<String, dynamic>.from(data['data']) : null;
        setState(() {
          _service = map;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch (${res.statusCode})';
          _loading = false;
        });
        Get.snackbar('Error', _error ?? '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      log('DELIVERY DETAIL ERROR: $e');
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
      Get.snackbar('Error', _error ?? '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (_service?['name'] ?? '').toString();
    final short = (_service?['short_description'] ?? '').toString();
    final imagePath = (_service?['image'] ?? '').toString();
    final ratingStr = (_service?['rating'] ?? '0').toString();
    final rating = double.tryParse(ratingStr) ?? 0.0;
    final reviews = (_service?['rating_count'] ?? 0) as int;
    final statusText = (_service?['status_text'] ?? '').toString();
    final bannerUrl = imagePath.isNotEmpty ? 'https://hcodecraft.com/felwa/storage/$imagePath' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? _buildSkeleton()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          bannerUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: Icon(Icons.image_not_supported, color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(24)),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(24)),
                            child: const Icon(Icons.ios_share, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Icon(Icons.location_on, color: Colors.green.shade600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(short, style: GoogleFonts.ubuntu(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(rating.toStringAsFixed(1), style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Text(_formatReviews(reviews), style: GoogleFonts.ubuntu(color: Colors.black54)),
                      ]),
                      const Spacer(),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Open', style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
                        Text(statusText, style: GoogleFonts.ubuntu(color: Colors.black54)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Write your order', style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Stack(children: [
                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Write here the details of your order,',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text('Pick Up Location', style: GoogleFonts.ubuntu(color: Colors.black54)),
                  const SizedBox(height: 8),
                  _locationTile('Select your Location', onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LocationPickerScreen(title: 'Pick Up Location'),
                      ),
                    );
                    if (res is PickedLocation) {
                      setState(() {
                        _pickup = res;
                      });
                    }
                  }, subtitle: _pickup != null ? '${_pickup!.lat.toStringAsFixed(6)}, ${_pickup!.lng.toStringAsFixed(6)}' : null),
                  const SizedBox(height: 12),
                  Text('Drop Off Location', style: GoogleFonts.ubuntu(color: Colors.black54)),
                  const SizedBox(height: 8),
                  _locationTile('Select your Location', onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LocationPickerScreen(title: 'Drop Off Location'),
                      ),
                    );
                    if (res is PickedLocation) {
                      setState(() {
                        _dropoff = res;
                      });
                    }
                  }, subtitle: _dropoff != null ? '${_dropoff!.lat.toStringAsFixed(6)}, ${_dropoff!.lng.toStringAsFixed(6)}' : null),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _walletTile()),
                  ]),
                  const SizedBox(height: 12),
                  _paymentTile('Select payment method'),
                  const SizedBox(height: 16),
                  _costCard(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {},
                      child: Text('Place order', style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
      Shimmer(child: Container(height: 200, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 12),
      Shimmer(child: Container(height: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: Shimmer(child: Container(height: 20, color: Colors.grey.shade300))), const SizedBox(width: 12), Shimmer(child: Container(height: 20, width: 80, color: Colors.grey.shade300))]),
      const SizedBox(height: 16),
      Shimmer(child: Container(height: 120, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 16),
      Shimmer(child: Container(height: 48, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 12),
      Shimmer(child: Container(height: 48, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 12),
      Shimmer(child: Container(height: 72, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 16),
      Shimmer(child: Container(height: 100, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 16),
      Shimmer(child: Container(height: 48, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(24)))),
    ]);
  }

  Widget _locationTile(String text, {VoidCallback? onTap, String? subtitle}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.place, color: Colors.grey),
        title: Text(text, style: GoogleFonts.ubuntu(color: Colors.green)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.ubuntu(color: Colors.black54)) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _walletTile() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text('${'common.currency'.tr} 0', style: GoogleFonts.ubuntu(color: Colors.black54))),
          Switch(value: false, onChanged: (_) {}),
        ]),
      ),
    );
  }

  Widget _paymentTile(String text) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.grey),
        title: Text(text, style: GoogleFonts.ubuntu(color: Colors.green)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _costCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Delivery Cost', style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600))),
          Text('${'common.currency'.tr} --,--', style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Text(
          'Estimated delivery cost depends on couriers offers as well as the distance between the pickup and the drop-off locations.',
          style: GoogleFonts.ubuntu(color: Colors.black54),
        )
      ]),
    );
  }

  String _formatReviews(int count) {
    if (count >= 1000000) {
      final m = count / 1000000.0;
      return '${m.toStringAsFixed(2)}M Reviews';
    }
    if (count >= 1000) {
      final k = count / 1000.0;
      return '${k.toStringAsFixed(1)}k Reviews';
    }
    return '$count Reviews';
  }
}