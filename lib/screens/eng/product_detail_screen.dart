import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String storeName;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.storeName,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final Color primaryColor = const Color(0xffe7712b);
  final Color secondaryColor = const Color(0xff282f5a);

  bool isLoading = true;
  Map<String, dynamic>? product;
  int quantity = 1;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(
            'https://hcodecraft.com/felwa/api/products/${widget.productId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("RESPONSE PRODUCT DETAILS::: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          product = jsonResponse;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Failed to fetch product details: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching product details: $e');
    }
  }

  Future<void> addToCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('https://hcodecraft.com/felwa/api/add-to-cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'product_id': widget.productId.toString(),
          'quantity': quantity.toString(),
        },
      );

      log("RESPONSE ADD TO CART::: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                jsonResponse['message'] ?? 'Added to cart successfully!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add to cart'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.storeName,
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Get.to(() => const CartScreen());
              // Navigate to cart screen
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? Center(
                  child: Text(
                    'Product not found',
                    style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Banner with Carousel
                      _buildImageBanner(),
                      
                      // Product Details Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Title
                            Text(
                              product!['title'] ?? 'Product Name',
                              style: GoogleFonts.ubuntu(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Price and Stock
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${product!['price']} ${product!['currency'] ?? 'PKR'}',
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Stock Badge
                                if (product!['stock_qty'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (product!['stock_qty'] as int) > 0
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (product!['stock_qty'] as int) > 0
                                            ? Colors.green
                                            : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          (product!['stock_qty'] as int) > 0
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 16,
                                          color: (product!['stock_qty'] as int) > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (product!['stock_qty'] as int) > 0
                                              ? 'In Stock (${product!['stock_qty']})'
                                              : 'Out of Stock',
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: (product!['stock_qty'] as int) > 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Categories
                            if (product!['categories'] != null &&
                                (product!['categories'] as List).isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Categories',
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (product!['categories'] as List)
                                        .map((category) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: secondaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: secondaryColor.withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                category['title'] ?? '',
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: secondaryColor,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            
                            // Divider
                            Divider(color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            
                            // Description Section
                            Text(
                              'Description',
                              style: GoogleFonts.ubuntu(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product!['description'] ?? 'No description available',
                              style: GoogleFonts.ubuntu(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Store Information
                            if (product!['store'] != null) ...[
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Store Information',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStoreInfo(),
                              const SizedBox(height: 16),
                            ],
                            
                            // Quantity Selector
                            Text(
                              'Quantity',
                              style: GoogleFonts.ubuntu(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuantitySelector(),
                            const SizedBox(height: 100), // Space for bottom button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: product != null
          ? _buildAddToCartButton()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildImageBanner() {
    final images = product!['images'] as List?;
    final imageList = images != null && images.isNotEmpty
        ? images
            .map((img) => 'https://hcodecraft.com/felwa/storage/${img['path']}')
            .toList()
        : ['https://via.placeholder.com/400'];

    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            itemCount: imageList.length,
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                imageList[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey.shade600,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryColor,
                    ),
                  );
                },
              );
            },
          ),
          
          // Image Indicators
          if (imageList.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imageList.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentImageIndex == index
                          ? primaryColor
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove_circle,
              color: quantity > 1 ? primaryColor : Colors.grey.shade400,
              size: 32,
            ),
            onPressed: () {
              if (quantity > 1) {
                setState(() => quantity--);
              }
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              quantity.toString(),
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: primaryColor,
              size: 32,
            ),
            onPressed: () {
              setState(() => quantity++);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    final store = product!['store'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Store Logo
              if (store['logo_url'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    store['logo_url'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.store, color: primaryColor),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              // Store Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['name'] ?? '',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        store['status'] ?? 'active',
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Store Details
          if (store['about'] != null) ...[
            Text(
              store['about'],
              style: GoogleFonts.ubuntu(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Phone
          if (store['phone'] != null)
            _buildInfoRow(
              Icons.phone,
              'Phone',
              store['phone'],
            ),
          // Address
          if (store['address'] != null)
            _buildInfoRow(
              Icons.location_on,
              'Address',
              store['address'],
            ),
          // Delivery Info
          if (store['delivery_radius_km'] != null)
            _buildInfoRow(
              Icons.delivery_dining,
              'Delivery',
              'Within ${store['delivery_radius_km']} km - ${store['delivery_fee']} ${store['currency'] ?? 'PKR'}',
            ),
          // Open Hours
          if (store['open_hours_json'] != null)
            _buildInfoRow(
              Icons.access_time,
              'Hours',
              _parseOpenHours(store['open_hours_json']),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.ubuntu(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.ubuntu(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _parseOpenHours(dynamic openHoursJson) {
    try {
      if (openHoursJson is String) {
        final decoded = json.decode(openHoursJson);
        if (decoded is Map) {
          return decoded.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ');
        }
      }
      return openHoursJson.toString();
    } catch (e) {
      return openHoursJson.toString();
    }
  }

  Widget _buildAddToCartButton() {
    final stockQty = product!['stock_qty'] as int? ?? 0;
    final isOutOfStock = stockQty <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: isOutOfStock ? null : addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutOfStock ? Colors.grey : primaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          icon: Icon(
            isOutOfStock ? Icons.remove_shopping_cart : Icons.shopping_cart,
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            isOutOfStock ? 'Out of Stock' : 'Add to Cart',
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}






