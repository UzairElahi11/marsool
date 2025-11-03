import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/product_list_screen.dart';
import 'package:petshow/screens/eng/store_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final Color primaryColor = const Color(0xffe7712b);
  final Color secondaryColor = const Color(0xff282f5a);

  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoriesWithStores();
  }

  Future<void> fetchCategoriesWithStores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('http://hcodecraft.com/felwa/api/categories-with-stores'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          categories = jsonResponse['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 BANNERS
            SizedBox(
              height: 160,
              child: PageView(
                children: [
                  bannerCard(
                      'https://static.vecteezy.com/system/resources/previews/006/532/742/large_2x/flash-sale-banner-illustration-template-design-of-special-offer-discount-for-media-promotion-and-social-media-post-free-vector.jpg'),
                  bannerCard(
                      'https://static.vecteezy.com/system/resources/previews/006/532/742/large_2x/flash-sale-banner-illustration-template-design-of-special-offer-discount-for-media-promotion-and-social-media-post-free-vector.jpg'),
                  bannerCard(
                      'https://static.vecteezy.com/system/resources/previews/006/532/742/large_2x/flash-sale-banner-illustration-template-design-of-special-offer-discount-for-media-promotion-and-social-media-post-free-vector.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔸 CATEGORIES
            Text(
              'Categories',
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreListScreen(
                            categoryId: category['id'],
                            categoryTitle: category['title'],
                          ),
                        ),
                      );
                    },
                    child: categoryCard(category['title'], 'https://hcodecraft.com/felwa/storage/${category['image']}'),
                  );
                  ;
                },
              ),
            ),
            const SizedBox(height: 20),

            // 🔸 CATEGORY SECTIONS WITH STORES
            for (var category in categories) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category['title'] ?? '',
                    style: GoogleFonts.ubuntu(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreListScreen(
                            categoryId: category['id'],
                            categoryTitle: category['title'],
                          ),
                        ),
                      );
                    },

                    child: Text(
                      'View All',
                      style: GoogleFonts.ubuntu(
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (category['stores'] != null &&
                  (category['stores'] as List).isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category['stores'].length,
                    itemBuilder: (context, sIndex) {
                      final store = category['stores'][sIndex];
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
                        child: storeCard(store['name'], store['logo_url']),
                      );
                      ;
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No stores found.',
                    style: GoogleFonts.ubuntu(color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // 🔹 UI Widgets

  Widget bannerCard(String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget categoryCard(String name, String imgUrl) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(imgUrl), radius: 25),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget storeCard(String name, String imgUrl) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imgUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
