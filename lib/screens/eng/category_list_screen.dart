import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/product_list_screen.dart';
import 'package:petshow/screens/eng/store_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final String apiUrl = "https://hcodecraft.com/felwa/api/categories";
  List categories = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchCategoriesWithStores();
  }

  Future<void> fetchCategoriesWithStores() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('https://hcodecraft.com/felwa/api/categories-with-stores'),
        headers: {'Authorization': 'Bearer $token'},
      );
      log("URL::: ${response.request?.url}");
      log(" CATEGORIES BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}");
      log("RESPONSE CATEGORIES::: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = data['data'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load categories")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => isLoading = false);
  }

  void _onSearchChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = _query.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          searchResults = [];
        } else {
          final List combined = [];
          for (final c in categories) {
            final cTitle = (c['title'] ?? '').toString();
            final cImage = c['image'];
            final cId = c['id'];
            if (cTitle.toLowerCase().contains(q)) {
              combined.add({
                'type': 'category',
                'id': cId,
                'title': cTitle,
                'image': cImage,
              });
            }
            final stores = (c['stores'] as List?) ?? [];
            for (final s in stores) {
              final sName = (s['name'] ?? '').toString();
              if (sName.toLowerCase().contains(q)) {
                combined.add({
                  'type': 'store',
                  'id': s['id'],
                  'title': sName,
                  'image': s['logo_url'],
                  'categoryId': cId,
                  'categoryTitle': cTitle,
                });
              }
            }
          }
          searchResults = combined;
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Categories",
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w600,
            color: const Color(0xffe7712b),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xffe7712b)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffe7712b)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search categories and stores',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      style: GoogleFonts.ubuntu(),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchCategoriesWithStores,
                    color: const Color(0xffe7712b),
                    child: _query.trim().isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: searchResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = searchResults[index];
                              final isCategory = item['type'] == 'category';
                              final imgUrl = isCategory
                                  ? 'https://hcodecraft.com/felwa/storage/${item['image']}'
                                  : (item['image'] ?? '');
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imgUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey.shade300,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          isCategory
                                              ? Icons.image
                                              : Icons.store,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item['title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    if (isCategory) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StoreListScreen(
                                            categoryId: item['id'],
                                            categoryTitle: item['title'],
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductListScreen(
                                            storeId: item['id'],
                                            storeName: item['title'],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return _buildCategoryCard(category);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(Map category) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to category details or subcategories
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon or placeholder circle
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffe7712b).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category,
                    color: Color(0xffe7712b), size: 28),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'] ?? 'Untitled',
                      style: GoogleFonts.ubuntu(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffe7712b),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category['description'] ?? 'No description available.',
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
