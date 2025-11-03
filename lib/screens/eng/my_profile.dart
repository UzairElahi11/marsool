import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/widgets/space_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    await authController.getProfile();

    final profile = authController.userProfile;
    if (profile.isNotEmpty) {
      nameController.text = profile['user']['name'] ?? '';
      emailController.text = profile['user']['email'] ?? '';
      phoneController.text = profile['user']['phone'] ?? '';
    }
  }

  // 🟢 Call updateProfile API
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await authController.updateProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Update Profile",
          style: ConstantManager.kfont.copyWith(color: Colors.white),
        ),
        backgroundColor: ConstantManager.primaryColor,
      ),
      body: Obx(() {
        if (authController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (authController.userProfile.isNotEmpty) {
          final profile = authController.userProfile;
          nameController.text = profile['user']['name'] ?? '';
          emailController.text = profile['user']['email'] ?? '';
          phoneController.text = profile['user']['phone'] ?? '';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Name"),
                const Spacebar('h', space: 1),
                _buildTextField(
                  controller: nameController,
                  hint: "Enter your name",
                  validator: (v) => v!.isEmpty ? "Name cannot be empty" : null,
                ),
                const Spacebar('h', space: 2),
                _buildLabel("Email"),
                const Spacebar('h', space: 1),
                _buildTextField(
                  controller: emailController,
                  hint: "Enter your email",
                  enable: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email required";
                    if (!GetUtils.isEmail(v)) return "Invalid email";
                    return null;
                  },
                ),
                const Spacebar('h', space: 2),
                _buildLabel("Phone"),
                const Spacebar('h', space: 1),
                _buildTextField(
                  controller: phoneController,
                  hint: "Enter your phone",
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Phone required" : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ConstantManager.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: ConstantManager.kfont
            .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
      );

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
      bool? enable = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enable,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        hintStyle: ConstantManager.kfont,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: ConstantManager.primaryColor, width: 2),
        ),
      ),
    );
  }
}
