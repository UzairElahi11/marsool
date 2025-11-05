import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/product_list_screen.dart';
import 'package:petshow/screens/eng/store_list_screen.dart';
import 'package:petshow/screens/eng/category_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // State moved to class scope
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  List categories = [];
  List searchResults = [];
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

      log("URL::: ${response.request?.url}");
      log(" CATEGORIES BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}");
      log("RESPONSE CATEGORIES::: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          categories = jsonResponse['data'] ?? [];
          searchResults = [];
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

  void _onSearchChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = _query.trim().toLowerCase();
      setState(() {
        if (q.isEmpty) {
          searchResults = [];
        } else {
          searchResults = categories.where((c) {
            final title = (c['title'] ?? '').toString().toLowerCase();
            return title.contains(q);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    // local search moved to CategoriesScreen; no local resources to dispose
    super.dispose();


  _debounce?.cancel();
  _searchController.dispose();
  super.dispose();
  }

  // Helper widgets added to fix "method isn't defined" errors
  Widget bannerCard(String imageUrl) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: Icon(Icons.image, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget categoryCard(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: Icon(Icons.image, color: Colors.grey.shade600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget storeCard(String name, String logoUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 160,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                logoUrl,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: Icon(Icons.store, color: Colors.grey.shade700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xffe7712b);
    const Color secondaryColor = Color(0xff282f5a);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search entry (navigates to CategoriesScreen)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoriesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search categories and stores',
                          style: GoogleFonts.ubuntu(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable content below fixed search bar
            Expanded(
              child: isLoading
                  ? _buildLoadingShimmers()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        // Search results above normal UI
                        if (_query.trim().isNotEmpty) ...[
                          Text(
                            'Search Results',
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: searchResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final category = searchResults[index];
                              final imgUrl =
                                  'https://hcodecraft.com/felwa/storage/${category['image']}';
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                        child: Icon(Icons.image,
                                            color: Colors.grey.shade700),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    category['title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
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
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Original UI below
                        SizedBox(
                          height: 160,
                          child: PageView(
                            children: [
                              bannerCard(
                                'https://static.vecteezy.com/system/resources/previews/006/532/742/large_2x/flash-sale-banner-illustration-template-design-of-special-offer-discount-for-media-promotion-and-social-media-post-free-vector.jpg',
                              ),
                              bannerCard(
                                'https://static.vecteezy.com/system/resources/previews/006/532/742/large_2x/flash-sale-banner-illustration-template-design-of-special-offer-discount-for-media-promotion-and-social-media-post-free-vector.jpg',
                              ),
                              bannerCard(
                                'https://static.vecteezy.com/system/resources/previews/006/532/742/large_2x/flash-sale-banner-illustration-template-design-of-special-offer-discount-for-media-promotion-and-social-media-post-free-vector.jpg',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

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
                          height: 120,
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
                                child: categoryCard(
                                  category['title'],
                                  'https://hcodecraft.com/felwa/storage/${category['image']}',
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        for (var category in categories) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  category['title'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
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
                                    child: storeCard(
                                        store['name'], store['logo_url']),
                                  );
                                },
                              ),
                            )
                          else
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
          ],
        ),
      ),
    );
  }
}

// Lightweight shimmer widget without external deps
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.period = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // Move gradient across X axis
        final shift = (_controller.value * 2) - 1; // -1..1
        final gradient = LinearGradient(
          colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1.0 - shift, -0.3),
          end: Alignment(1.0 + shift, 0.3),
        );

        return ShaderMask(
          shaderCallback: (rect) => gradient.createShader(rect),
          blendMode: BlendMode.srcATop,
          child: child!,
        );
      },
    );
  }
}

// Skeleton helpers
Widget _lineShimmer(
    {double width = 120, double height = 16, BorderRadius? radius}) {
  return Shimmer(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: radius ?? BorderRadius.circular(8),
      ),
    ),
  );
}

Widget _shimmerBannerCard() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    clipBehavior: Clip.antiAlias,
    child: Shimmer(
      child: Container(color: Colors.grey.shade300),
    ),
  );
}

Widget _shimmerCategoryItem() {
  return Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
      ],
    ),
  );
}

Widget _shimmerStoreCard() {
  return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
          width: 160,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Shimmer(
                  child: Container(
                    height: 120,
                    color: Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _lineShimmer(
                      width: 120, height: 12, radius: BorderRadius.circular(6)),
                ),
              ],
            ),
          )));
}

Widget _buildLoadingShimmers() {
  return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
// Banners
    SizedBox(
      height: 160,
      child: PageView(
        children: [
          _shimmerBannerCard(),
          _shimmerBannerCard(),
          _shimmerBannerCard(),
        ],
      ),
    ),
    const SizedBox(height: 20),

// "Categories" header bar
    _lineShimmer(width: 140, height: 20),
    const SizedBox(height: 10),

// Horizontal categories skeletons
    SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (_, __) => _shimmerCategoryItem(),
      ),
    ),
    const SizedBox(height: 20),

// Two placeholder store sections
    for (int i = 0; i < 2; i++) ...[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _lineShimmer(width: double.infinity, height: 20)),
          const SizedBox(width: 12),
          _lineShimmer(width: 72, height: 16),
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) => _shimmerStoreCard(),
        ),
      ),
      const SizedBox(height: 20),
    ],
  ]);
}
