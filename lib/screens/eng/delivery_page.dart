import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petshow/screens/eng/store_tab.dart' show Shimmer;
import 'package:petshow/screens/eng/delivery_service_detail_screen.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _loading = true;
  String? _error;

  List<_DeliveryItem> _items = const [];
  late List<_DeliveryItem> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_items);
    _searchController.addListener(_onSearchChanged);
    _fetchServices();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _searchController.text.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          _filtered = List.from(_items);
        } else {
          _filtered = _items.where((it) {
            final t = it.name.toLowerCase();
            return t.contains(q);
          }).toList();
        }
      });
      log('DELIVERY SEARCH QUERY: "$q" results=${_filtered.length}');
    });
  }

  Future<void> _fetchServices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uri = Uri.parse('https://hcodecraft.com/felwa/api/delivery-services?page=1');
      log('DELIVERY SERVICES URL: $uri');
      log('DELIVERY TOKEN PRESENT: ${token.isNotEmpty}');
      final response = await http.get(uri, headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        log('DELIVERY RESPONSE STATUS: ${response.statusCode}');
        log('DELIVERY RESPONSE BODY: ${response.body}');
        final data = jsonDecode(response.body);
        final list = (data is Map && data['data'] is Map && data['data']['data'] is List)
            ? List<Map<String, dynamic>>.from(data['data']['data'])
            : <Map<String, dynamic>>[];
        final items = list.map((e) {
          final imagePath = (e['image'] ?? '').toString();
          final ratingStr = (e['rating'] ?? '0').toString();
          final rating = double.tryParse(ratingStr) ?? 0.0;
          return _DeliveryItem(
            id: e['id'] as int?,
            categoryId: e['delivery_service_category_id'] as int?,
            name: (e['name'] ?? '').toString(),
            imageUrl: 'https://hcodecraft.com/felwa/storage/$imagePath',
            icon: Icons.place,
            rating: rating,
            ratingCount: (e['rating_count'] ?? 0) as int,
            statusText: (e['status_text'] ?? '').toString(),
          );
        }).toList();
        log('DELIVERY PARSED ITEMS: ${items.length}');

        setState(() {
          _items = items;
          _filtered = List.from(items);
          _loading = false;
        });
      } else {
        log('DELIVERY RESPONSE STATUS: ${response.statusCode}');
        log('DELIVERY RESPONSE BODY: ${response.body}');
        setState(() {
          _error = 'Failed to fetch delivery services (${response.statusCode})';
          _loading = false;
        });
        Get.snackbar('Error', _error ?? '', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      log('DELIVERY FETCH ERROR: $e');
      setState(() {
        _error = 'Error fetching delivery services: $e';
        _loading = false;
      });
      Get.snackbar('Error', _error ?? '', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'delivery.searchHint'.tr,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.ubuntu(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? _buildLoadingSkeleton()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return _card(_filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(_DeliveryItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (item.categoryId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeliveryServiceDetailScreen(categoryId: item.categoryId!),
                ),
              );
            }
          },
          child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: Icon(Icons.image_not_supported, color: Colors.grey.shade700),
            ),
          ),
        ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (item.categoryId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeliveryServiceDetailScreen(categoryId: item.categoryId!),
                ),
              );
            }
          },
          child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, color: Colors.green.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(item.rating.toStringAsFixed(1)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DeliveryItem {
  final int? id;
  final int? categoryId;
  final String name;
  final String imageUrl;
  final IconData icon;
  final double rating;
  final int ratingCount;
  final String statusText;

  const _DeliveryItem({
    this.id,
    this.categoryId,
    required this.name,
    required this.imageUrl,
    required this.icon,
    required this.rating,
    required this.ratingCount,
    required this.statusText,
  });
}

Widget _buildLoadingSkeleton() {
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    itemCount: 3,
    itemBuilder: (context, index) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Shimmer(
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Shimmer(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Shimmer(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Shimmer(
                    child: Container(
                      width: 56,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    },
  );
}