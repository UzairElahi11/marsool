import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_address_screen.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List addresses = [];
  bool isLoading = true;
  final String baseUrl = "http://hcodecraft.com/felwa/api";
  final Color primaryColor = const Color(0xffe7712b);

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/addresses"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          addresses = data['data'] ?? [];
        });
      } else {
        Get.snackbar("Error", "Failed to fetch addresses");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteAddress(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Address", style: GoogleFonts.ubuntu()),
        content: Text("Are you sure you want to delete this address?",
            style: GoogleFonts.ubuntu()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.ubuntu()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child:
            Text("Delete", style: GoogleFonts.ubuntu(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/addresses/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("Deleted", "Address deleted successfully",
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        await fetchAddresses();
      } else {
        Get.snackbar("Error", "Failed to delete address");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  IconData _getAddressIcon(String? label) {
    if (label == null) return Icons.location_on_rounded;
    final l = label.toLowerCase();
    if (l.contains('home')) return Icons.home_rounded;
    if (l.contains('work') || l.contains('office')) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          "My Address",
          style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w600, letterSpacing: 0.3, fontSize: 20,
          color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          ).then((value) {
            if (value == true) fetchAddresses();
          });
        },
        label: Text("Add Address",
            style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w500, color: Colors.white)),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: primaryColor),
      )
          : addresses.isEmpty
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined,
              color: primaryColor.withOpacity(0.3), size: 80),
          const SizedBox(height: 16),
          Text("No addresses added yet",
              style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to add your first address.",
            style: GoogleFonts.ubuntu(color: Colors.grey.shade500),
          ),
        ],
      )
          : RefreshIndicator(
        color: primaryColor,
        onRefresh: fetchAddresses,
        child: ListView.builder(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                    color: primaryColor.withOpacity(0.15), width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.15),
                  radius: 26,
                  child: Icon(
                    _getAddressIcon(address['label']),
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                title: Text(
                  address['label'] ?? 'No Label',
                  style: GoogleFonts.ubuntu(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(address['line1'] ?? '',
                        style: GoogleFonts.ubuntu(
                            color: Colors.grey.shade800,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                        "${address['city'] ?? ''}, ${address['state'] ?? ''}, ${address['country'] ?? ''}",
                        style: GoogleFonts.ubuntu(
                            color: Colors.grey.shade600,
                            fontSize: 13)),
                    if (address['postcode'] != null)
                      Text("Postcode: ${address['postcode']}",
                          style: GoogleFonts.ubuntu(
                              color: Colors.grey.shade500,
                              fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            primaryColor.withOpacity(0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditAddressScreen(address: address),
                              ),
                            ).then((value) {
                              if (value == true) fetchAddresses();
                            });
                          },
                          icon: Icon(Icons.edit,
                              color: primaryColor, size: 18),
                          label: Text("Edit",
                              style: GoogleFonts.ubuntu(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.redAccent.withOpacity(0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ),
                          onPressed: () =>
                              deleteAddress(address['id']),
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent, size: 18),
                          label: Text("Delete",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
