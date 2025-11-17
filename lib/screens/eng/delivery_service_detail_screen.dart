import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/store_tab.dart' show Shimmer;
import 'package:petshow/screens/eng/location_picker_screen.dart';
import 'package:petshow/services/wallet_service.dart';
import 'package:petshow/services/coupon_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryServiceDetailScreen extends StatefulWidget {
  final int categoryId;
  const DeliveryServiceDetailScreen({super.key, required this.categoryId});

  @override
  State<DeliveryServiceDetailScreen> createState() =>
      _DeliveryServiceDetailScreenState();
}

class _DeliveryServiceDetailScreenState
    extends State<DeliveryServiceDetailScreen> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _service;
  PickedLocation? _pickup;
  PickedLocation? _dropoff;
  String? _pickupAddress;
  String? _dropoffAddress;
  bool _loadingPickupAddress = false;
  bool _loadingDropoffAddress = false;

  // Payment methods
  List<dynamic> _paymentMethods = [];
  Map<String, dynamic>? _selectedPaymentMethod;
  bool _loadingPaymentMethods = false;

  // Wallet
  final WalletService _walletService = WalletService();
  double _walletBalance = 0.0;
  String _walletCurrency = 'SAR';
  bool _payFromWallet = false;
  bool _loadingWallet = false;

  // Coupon
  final CouponService _couponService = CouponService();
  String? _couponCode;
  Map<String, dynamic>? _couponDiscount;

  // Order description
  final TextEditingController _orderDescriptionController =
      TextEditingController();

  // Order placement
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchWalletDetails();
    _fetchPaymentMethods();
  }

  @override
  void dispose() {
    _orderDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
          'https://hcodecraft.com/felwa/api/delivery-services/${widget.categoryId}');
      log('DELIVERY DETAIL URL: $url');
      final res = await http.get(url, headers: {'Accept': 'application/json'});
      if (!mounted) return;
      log('DELIVERY DETAIL STATUS: ${res.statusCode}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        log('DELIVERY DETAIL BODY: ${res.body}');
        final data = jsonDecode(res.body);
        final map = (data is Map && data['data'] is Map)
            ? Map<String, dynamic>.from(data['data'])
            : null;
        setState(() {
          _service = map;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch (${res.statusCode})';
          _loading = false;
        });
        Get.snackbar('Error', _error ?? '',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      log('DELIVERY DETAIL ERROR: $e');
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
      Get.snackbar('Error', _error ?? '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  Future<void> _fetchWalletDetails() async {
    setState(() {
      _loadingWallet = true;
    });
    final wallet = await _walletService.getWalletDetails();
    if (wallet != null && mounted) {
      setState(() {
        _walletBalance = (wallet['balance'] ?? 0.0) is num
            ? (wallet['balance'] as num).toDouble()
            : double.tryParse(wallet['balance']?.toString() ?? '0') ?? 0.0;
        _walletCurrency = wallet['currency']?.toString() ?? 'SAR';
        _loadingWallet = false;
      });
    } else if (mounted) {
      setState(() {
        _loadingWallet = false;
      });
    }
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() {
      _loadingPaymentMethods = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse('https://hcodecraft.com/felwa/api/payment-methods'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
        final decoded = jsonDecode(res.body);
        List<dynamic> items = [];
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          if (data is Map && data['items'] is List) {
            items = List<dynamic>.from(data['items']);
          } else if (data is List) {
            items = List<dynamic>.from(data);
          }
        }
        setState(() {
          _paymentMethods = items;
          _loadingPaymentMethods = false;
        });
      } else if (mounted) {
        setState(() {
          _loadingPaymentMethods = false;
        });
      }
    } catch (e) {
      log('PAYMENT METHODS ERROR: $e');
      if (mounted) {
        setState(() {
          _loadingPaymentMethods = false;
        });
      }
    }
  }

  Future<void> _showPaymentMethodsSheet() async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Payment Method',
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Cash option
                ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.amber.shade300,
                    child: const Icon(Icons.monetization_on_outlined,
                        color: Colors.white),
                  ),
                  title: Text(
                    'Cash',
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                  ),
                  trailing: _selectedPaymentMethod != null &&
                          _selectedPaymentMethod!['type'] == 'cash'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop({'type': 'cash', 'id': null});
                  },
                ),
                const Divider(height: 1),
                // Payment methods from API
                if (_loadingPaymentMethods)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!_loadingPaymentMethods)
                  ..._paymentMethods.map((pm) {
                    final map =
                        pm is Map<String, dynamic> ? pm : <String, dynamic>{};
                    final brand = map['brand'] ?? map['type'] ?? 'Card';
                    final cardNumberStr = map['card_number']?.toString() ?? '';
                    final last4 = map['last4'] ??
                        (cardNumberStr.length >= 4
                            ? cardNumberStr.substring(cardNumberStr.length - 4)
                            : '****');
                    final name = map['cardholder_name'] ?? map['name'] ?? '';
                    final idRaw = map['id'];
                    final int? id = idRaw is int
                        ? idRaw
                        : (idRaw is String ? int.tryParse(idRaw) : null);
                    final isSelected = _selectedPaymentMethod != null &&
                        _selectedPaymentMethod!['id'] == id;
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.credit_card,
                              color: Colors.black54, size: 28),
                          title: Text(
                            '$brand •••• $last4',
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: name.isNotEmpty
                              ? Text(name, style: GoogleFonts.ubuntu())
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            Navigator.of(ctx).pop({
                              'id': id,
                              'type': brand,
                              'last4': last4,
                              'name': name,
                            });
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  }),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedPaymentMethod = selected;
      });
    }
  }

  Future<void> _showCouponBottomSheet() async {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController storeController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            final bool valid = codeController.text.trim().isNotEmpty &&
                double.tryParse(amountController.text.trim().isEmpty
                        ? '0'
                        : amountController.text.trim()) !=
                    null;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Apply Coupon',
                          style: GoogleFonts.ubuntu(
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
                      style: GoogleFonts.ubuntu(
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
                          hintText: 'Coupon Code',
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: valid
                          ? () async {
                              final double amount = double.tryParse(
                                    amountController.text.trim().isEmpty
                                        ? '0'
                                        : amountController.text.trim(),
                                  ) ??
                                  0.0;
                              final int? storeId = storeController.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : int.tryParse(storeController.text.trim());
                              final result =
                                  await _couponService.validateCoupon(
                                code: codeController.text.trim(),
                                orderAmount: amount,
                                storeId: storeId,
                              );

                              if (result != null && mounted) {
                                Navigator.of(ctx).pop();
                                setState(() {
                                  _couponCode = codeController.text.trim();
                                  _couponDiscount = result;
                                });
                                Get.snackbar(
                                  'Success',
                                  (result['message'] ?? 'Coupon validated')
                                      .toString(),
                                  backgroundColor: Colors.green.shade100,
                                  colorText: Colors.black,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
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
              ),
            );
          },
        );
      },
    );
  }

  // Calculate distance between two coordinates in kilometers
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
  }

  // Reverse geocoding to get address from coordinates
  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json');
      final res =
          await http.get(uri, headers: {'User-Agent': 'MarsoolApp/1.0'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) {
          return data['display_name']?.toString() ??
              data['address']?['display_name']?.toString();
        }
      }
    } catch (e) {
      log('REVERSE GEOCODING ERROR: $e');
    }
    return null;
  }

  Future<void> _placeOrder() async {
    // Validation
    if (_pickup == null) {
      Get.snackbar(
        'Error',
        'Please select pickup location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (_dropoff == null) {
      Get.snackbar(
        'Error',
        'Please select dropoff location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _placingOrder = true;
    });

    try {
      // Use stored addresses or fetch if not available
      String? pickupAddress = _pickupAddress;
      String? dropoffAddress = _dropoffAddress;

      pickupAddress ??=
          await _getAddressFromCoordinates(_pickup!.lat, _pickup!.lng);
      dropoffAddress ??=
          await _getAddressFromCoordinates(_dropoff!.lat, _dropoff!.lng);

      // Calculate distance
      final distance = _calculateDistance(
        _pickup!.lat,
        _pickup!.lng,
        _dropoff!.lat,
        _dropoff!.lng,
      );

      // Get payment method ID (null for cash)
      final paymentMethodId = _selectedPaymentMethod!['id'] as int?;

      // Get service name and short description
      final serviceName = (_service?['name'] ?? '').toString();
      final serviceShortDescription =
          (_service?['short_description'] ?? '').toString();

      // Prepare request body
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final body = {
        'delivery_service_id': widget.categoryId,
        'title': serviceName.isNotEmpty ? serviceName : 'Delivery Order',
        'description': serviceShortDescription.isNotEmpty
            ? serviceShortDescription
            : 'Delivery service order',
        'order_image': null,
        'pickup_address_text':
            pickupAddress ?? '${_pickup!.lat}, ${_pickup!.lng}',
        'pickup_lat': _pickup!.lat,
        'pickup_lng': _pickup!.lng,
        'dropoff_address_text':
            dropoffAddress ?? '${_dropoff!.lat}, ${_dropoff!.lng}',
        'dropoff_lat': _dropoff!.lat,
        'dropoff_lng': _dropoff!.lng,
        'estimated_distance_km': (distance * 10).round() / 10.0,
        'estimated_cost':
            0, // This might need to be calculated based on distance/service
        'payment_method_id': paymentMethodId,
        'pay_from_wallet': _payFromWallet,
        'coupon_code': _couponCode,
      };

      log('PLACE ORDER URL: https://hcodecraft.com/felwa/api/delivery-orders');
      log('PLACE ORDER BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('https://hcodecraft.com/felwa/api/delivery-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      log('PLACE ORDER STATUS: ${response.statusCode}');
      log('PLACE ORDER RESPONSE: ${response.body}');

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final message =
            data['message']?.toString() ?? 'Order placed successfully';

        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ??
            errorData['error']?.toString() ??
            'Failed to place order';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('PLACE ORDER ERROR: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to place order: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _placingOrder = false;
        });
      }
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
    final bannerUrl = imagePath.isNotEmpty
        ? 'https://hcodecraft.com/felwa/storage/$imagePath'
        : '';

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
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey.shade700),
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
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(24)),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   right: 8,
                      //   top: 8,
                      //   child: InkWell(
                      //     onTap: () {},
                      //     borderRadius: BorderRadius.circular(24),
                      //     child: Container(
                      //       padding: const EdgeInsets.all(8),
                      //       decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(24)),
                      //       child: const Icon(Icons.ios_share, color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Icon(Icons.location_on,
                                color: Colors.green.shade600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: GoogleFonts.ubuntu(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(short,
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.black54)),
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
                        Text(rating.toStringAsFixed(1),
                            style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Text(_formatReviews(reviews),
                            style: GoogleFonts.ubuntu(color: Colors.black54)),
                      ]),
                      const Spacer(),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Open',
                                style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w600)),
                            Text(statusText,
                                style:
                                    GoogleFonts.ubuntu(color: Colors.black54)),
                          ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Text('Write your order',
                  //     style: GoogleFonts.ubuntu(
                  //         fontSize: 16, fontWeight: FontWeight.w600)),
                  // const SizedBox(height: 8),
                  // Stack(children: [
                  //   TextField(
                  //     controller: _orderDescriptionController,
                  //     maxLines: 4,
                  //     decoration: InputDecoration(
                  //       hintText: 'Write here the details of your order,',
                  //       filled: true,
                  //       fillColor: Colors.grey.shade100,
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(12),
                  //           borderSide: BorderSide.none),
                  //       contentPadding: const EdgeInsets.all(12),
                  //     ),
                  //   ),
                  // ]),
                  const SizedBox(height: 16),
                  Text('Pick Up Location',
                      style: GoogleFonts.ubuntu(color: Colors.black54)),
                  const SizedBox(height: 8),
                  _locationTile(
                    'Select your Location',
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationPickerScreen(
                              title: 'Pick Up Location'),
                        ),
                      );
                      if (res is PickedLocation) {
                        setState(() {
                          _pickup = res;
                          _pickupAddress = null;
                          _loadingPickupAddress = true;
                        });
                        // Fetch address for pickup location
                        final address =
                            await _getAddressFromCoordinates(res.lat, res.lng);
                        if (mounted) {
                          setState(() {
                            _pickupAddress = address;
                            _loadingPickupAddress = false;
                          });
                        }
                      }
                    },
                    subtitle: _pickup != null
                        ? (_loadingPickupAddress
                            ? 'Loading address...'
                            : (_pickupAddress ??
                                '${_pickup!.lat.toStringAsFixed(6)}, ${_pickup!.lng.toStringAsFixed(6)}'))
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Drop Off Location',
                      style: GoogleFonts.ubuntu(color: Colors.black54)),
                  const SizedBox(height: 8),
                  _locationTile(
                    'Select your Location',
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationPickerScreen(
                              title: 'Drop Off Location'),
                        ),
                      );
                      if (res is PickedLocation) {
                        setState(() {
                          _dropoff = res;
                          _dropoffAddress = null;
                          _loadingDropoffAddress = true;
                        });
                        // Fetch address for dropoff location
                        final address =
                            await _getAddressFromCoordinates(res.lat, res.lng);
                        if (mounted) {
                          setState(() {
                            _dropoffAddress = address;
                            _loadingDropoffAddress = false;
                          });
                        }
                      }
                    },
                    subtitle: _dropoff != null
                        ? (_loadingDropoffAddress
                            ? 'Loading address...'
                            : (_dropoffAddress ??
                                '${_dropoff!.lat.toStringAsFixed(6)}, ${_dropoff!.lng.toStringAsFixed(6)}'))
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _walletTile()),
                  ]),
                  const SizedBox(height: 12),
                  _paymentTile(_selectedPaymentMethod == null
                      ? 'Select payment method'
                      : _selectedPaymentMethod!['type'] == 'cash'
                          ? 'Cash'
                          : '${_selectedPaymentMethod!['type']} •••• ${_selectedPaymentMethod!['last4']}'),
                  const SizedBox(height: 12),
                  _couponTile(),
                  // const SizedBox(height: 16),
                  // _costCard(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _placingOrder ? null : _placeOrder,
                      child: _placingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('Place order',
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Shimmer(
              child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          Shimmer(
              child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Shimmer(
                    child: Container(height: 20, color: Colors.grey.shade300))),
            const SizedBox(width: 12),
            Shimmer(
                child: Container(
                    height: 20, width: 80, color: Colors.grey.shade300))
          ]),
          const SizedBox(height: 16),
          Shimmer(
              child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          Shimmer(
              child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          Shimmer(
              child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          Shimmer(
              child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          Shimmer(
              child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          Shimmer(
              child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(24)))),
        ]);
  }

  Widget _locationTile(String text, {VoidCallback? onTap, String? subtitle}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.place, color: Colors.grey),
        title: Text(text, style: GoogleFonts.ubuntu(color: Colors.green)),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.ubuntu(color: Colors.black54))
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _walletTile() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
              child: _loadingWallet
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '$_walletCurrency ${_walletBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.ubuntu(color: Colors.black54))),
          Switch(
              value: _payFromWallet,
              onChanged: (value) {
                setState(() {
                  _payFromWallet = value;
                });
              }),
        ]),
      ),
    );
  }

  Widget _paymentTile(String text) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.grey),
        title: Text(text, style: GoogleFonts.ubuntu(color: Colors.green)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showPaymentMethodsSheet,
      ),
    );
  }

  Widget _couponTile() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.local_offer, color: Colors.grey),
        title: Text(
            _couponCode != null ? 'Coupon: $_couponCode' : 'Apply Coupon',
            style: GoogleFonts.ubuntu(
                color: _couponCode != null ? Colors.green : Colors.grey)),
        trailing: _couponCode != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: Colors.green),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _couponCode = null;
                        _couponDiscount = null;
                      });
                    },
                  ),
                ],
              )
            : const Icon(Icons.chevron_right),
        onTap: _showCouponBottomSheet,
      ),
    );
  }

  // Widget _costCard() {
  //   return Container(
  //     decoration: BoxDecoration(
  //         color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
  //     padding: const EdgeInsets.all(12),
  //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //       Row(children: [
  //         Expanded(
  //             child: Text('Delivery Cost',
  //                 style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600))),
  //         Text('${'common.currency'.tr} --,--',
  //             style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
  //       ]),
  //       const SizedBox(height: 8),
  //       Text(
  //         'Estimated delivery cost depends on couriers offers as well as the distance between the pickup and the drop-off locations.',
  //         style: GoogleFonts.ubuntu(color: Colors.black54),
  //       )
  //     ]),
  //   );
  // }

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
