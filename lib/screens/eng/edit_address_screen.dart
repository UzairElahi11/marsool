import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressScreen extends StatefulWidget {
  final Map address;
  const EditAddressScreen({super.key, required this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final String baseUrl = "http://hcodecraft.com/felwa/api";

  final _formKey = GlobalKey<FormState>();
  late TextEditingController labelController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController postcodeController;
  late TextEditingController countryController;
  bool isDefault = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.address['label']);
    addressController = TextEditingController(text: widget.address['line1']);
    cityController = TextEditingController(text: widget.address['city']);
    stateController = TextEditingController(text: widget.address['state']);
    postcodeController = TextEditingController(text: widget.address['postcode']);
    countryController = TextEditingController(text: widget.address['country']);
    isDefault = widget.address['is_default'] == 1 || widget.address['is_default'] == true;
  }

  Future<void> updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = widget.address['id'];

    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Missing auth token. Please log in again.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      setState(() => isLoading = false);
      return;
    }

    try {
      final url = Uri.parse("$baseUrl/addresses/$id");
      // Debug logs
      debugPrint("PUT: $url");
      final body = jsonEncode({
        "label": labelController.text,
        "line1": addressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "postcode": postcodeController.text,
        "country": countryController.text,
        "is_default": isDefault,
        "lat": "34.0151",
        "lng": "71.5249",
      });
      debugPrint("Body: $body");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar("Success", "Address updated successfully",
            backgroundColor: const Color(0xffe7712b), colorText: Colors.white);
        // Use Navigator to return true to the previous screen (which may be using Navigator.push)
        Navigator.pop(context, true);
      } else {
        Get.snackbar("Error", "Failed to update address",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Edit Address", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Label"),
              _buildTextField(labelController, "Home / Office"),
              const SizedBox(height: 12),
              _buildSectionTitle("Address Details"),
              _buildTextField(addressController, "Address"),
              _buildTextField(cityController, "City"),
              _buildTextField(stateController, "State"),
              _buildTextField(postcodeController, "Postcode", keyboard: TextInputType.number),
              _buildTextField(countryController, "Country"),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: Text(
                    "Set as Default",
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                  ),
                  value: isDefault,
                  onChanged: (val) => setState(() => isDefault = val),
                  activeColor: const Color(0xffe7712b),
                ),
              ),
              const SizedBox(height: 25),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isLoading ? null : () => updateAddress(),
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xffe7712b), Color(0xffffa65c)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffe7712b).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Update Address",
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title,
        style: GoogleFonts.ubuntu(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xffe7712b),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: GoogleFonts.ubuntu(),
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.ubuntu(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
