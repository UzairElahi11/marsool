import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_list_screen.dart';

class StoreListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const StoreListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final Color primaryColor = const Color(0xffe7712b);
  final Color secondaryColor = const Color(0xff282f5a);

  bool isLoading = true;
  List stores = [];
  List filteredStores = [];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    fetchStoresForCategory();
  }

  void _onSearchChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = _query.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          filteredStores = List.from(stores);
        } else {
          filteredStores = stores.where((s) {
            final name = (s['name'] ?? '').toString().toLowerCase();
            return name.contains(q);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStoresForCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('https://hcodecraft.com/felwa/api/categories-with-stores'),
        headers: {'Authorization': 'Bearer $token'},
      );
      log("URL::: ${response.request?.url}");
      log("RESPONSE STORES::: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> raw = (jsonResponse['data'] as List?) ?? [];
        final List<Map<String, dynamic>> data =
            raw.cast<Map<String, dynamic>>();

        final Map<String, dynamic> selectedCategory = data.firstWhere(
          (c) => c['id'] == widget.categoryId,
          orElse: () => <String, dynamic>{},
        );

        final List loaded = (selectedCategory['stores'] as List?) ?? [];

        setState(() {
          stores = loaded;
          filteredStores = List.from(stores);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.categoryTitle,
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffe7712b)))
          : Column(
              children: [
                // Modern search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search stores',
                              border: InputBorder.none,
                              isDense: true,
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    ),
                            ),
                            style: GoogleFonts.ubuntu(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: filteredStores.isEmpty
                      ? Center(
                          child: Text(
                            'No stores found for this category.',
                            style: GoogleFonts.ubuntu(
                                color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          color: primaryColor,
                          onRefresh: fetchStoresForCategory,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredStores.length,
                            itemBuilder: (context, index) {
                              final store = filteredStores[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductListScreen(
                                        storeId: store['id'],
                                        storeName: store['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                          left: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          store['logo_url'] ??
                                              'https://via.placeholder.com/100',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            height: 90,
                                            width: 90,
                                            color: Colors.grey.shade300,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.storefront,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          store['name'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: secondaryColor,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right,
                                          color: Colors.grey),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
