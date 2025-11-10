import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String label = 'Home';
  bool isDefault = false;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  final String apiUrl = "https://hcodecraft.com/felwa/api/addresses";
  final Color primaryColor = const Color(0xffe7712b);

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final token = await getToken();
    if (token == null) {
      setState(() => isLoading = false);
      Get.snackbar("Error", "Authentication token not found!",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "label": label,
          "line1": addressController.text.trim(),
          "city": cityController.text.trim(),
          "state": stateController.text.trim(),
          "postcode": postcodeController.text.trim(),
          "country": countryController.text.trim(),
          "is_default": isDefault,
          "lat": "34.0151",
          "lng": "71.5249",
        }),
      );
      //Print URL
      log("URL::: ${response.request?.url}");
      //Print Response
      log("RESPONSE ADDRESS::: ${response.body}");

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Get.snackbar(
          "Success",
          data['message'] ?? "Address added successfully!",
          backgroundColor: primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        addressController.clear();
        cityController.clear();
        stateController.clear();
        postcodeController.clear();
        countryController.clear();
        setState(() {
          isDefault = false;
          label = 'Home';
        });

        Navigator.pop(context, true);
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to add address.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('New Address',
            style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Label",
                  style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      checkmarkColor: Colors.white,
                      label: Text('Home',
                          style: GoogleFonts.ubuntu(
                              color: label == 'Home'
                                  ? Colors.white
                                  : Colors.black)),
                      selected: label == 'Home',
                      onSelected: (_) => setState(() => label = 'Home'),
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      elevation: 2,
                      pressElevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Office',
                          style: GoogleFonts.ubuntu(
                              color: label == 'Office'
                                  ? Colors.white
                                  : Colors.black)),
                      selected: label == 'Office',
                      onSelected: (_) => setState(() => label = 'Office'),
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      elevation: 2,
                      pressElevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Address Inputs
              buildTextField("Address", addressController),
              buildTextField("City", cityController),
              buildTextField("State", stateController),
              buildTextField("Postcode", postcodeController,
                  keyboard: TextInputType.number),
              buildTextField("Country", countryController),

              const SizedBox(height: 10),
              SwitchListTile(
                title: Text("Set as Default Address",
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500, fontSize: 15)),
                activeColor: primaryColor,
                value: isDefault,
                onChanged: (val) => setState(() => isDefault = val),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                tileColor: Colors.white,
              ),

              const SizedBox(height: 35),
              GestureDetector(
                onTap: isLoading ? null : _saveAddress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Save Address",
                      style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) =>
        value == null || value.isEmpty ? "Enter $label" : null,
        style: GoogleFonts.ubuntu(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.ubuntu(
              color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1.4),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
