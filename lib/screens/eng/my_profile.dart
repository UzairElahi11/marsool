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

  // Builds initials from the user's name for the avatar
  String _initials(String name) {
    final parts = name.trim().split(' ');
    final first = parts.isNotEmpty ? parts[0] : '';
    final second = parts.length > 1 ? parts[1] : '';
    final i1 = first.isNotEmpty ? first[0].toUpperCase() : '';
    final i2 = second.isNotEmpty ? second[0].toUpperCase() : '';
    return '$i1$i2';
  }

  // Modern header with gradient, avatar, name, and email
  Widget _buildHeader() {
    final profile = authController.userProfile;
    final name = profile.isNotEmpty ? (profile['user']['name'] ?? '') : '';
    final email = profile.isNotEmpty ? (profile['user']['email'] ?? '') : '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ConstantManager.primaryColor,
            ConstantManager.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              _initials(name),
              style: ConstantManager.kfont.copyWith(
                color: ConstantManager.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'profileEdit.title'.tr : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ConstantManager.kfont.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ConstantManager.kfont.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = (Get.locale?.languageCode == 'ar');

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            'profileEdit.title'.tr,
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

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('profileEdit.name'.tr),
                            const Spacebar('h', space: 1),
                            _buildTextField(
                              controller: nameController,
                              hint: 'profileEdit.hint.name'.tr,
                              icon: Icons.person,
                              validator: (v) => v!.isEmpty
                                  ? 'profileEdit.validation.nameEmpty'.tr
                                  : null,
                            ),
                            const Spacebar('h', space: 2),
                            _buildLabel('profileEdit.email'.tr),
                            const Spacebar('h', space: 1),
                            _buildTextField(
                              controller: emailController,
                              hint: 'profileEdit.hint.email'.tr,
                              enable: false,
                              keyboardType: TextInputType.emailAddress,
                              icon: Icons.email,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'profileEdit.validation.emailRequired'
                                      .tr;
                                }
                                if (!GetUtils.isEmail(v)) {
                                  return 'profileEdit.validation.emailInvalid'
                                      .tr;
                                }
                                return null;
                              },
                            ),
                            const Spacebar('h', space: 2),
                            _buildLabel('profileEdit.phone'.tr),
                            const Spacebar('h', space: 1),
                            _buildTextField(
                              controller: phoneController,
                              hint: 'profileEdit.hint.phone'.tr,
                              keyboardType: TextInputType.phone,
                              icon: Icons.phone,
                              validator: (v) => v!.isEmpty
                                  ? 'profileEdit.validation.phoneRequired'.tr
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ConstantManager.primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.check,
                                    color: Colors.white),
                                label: Text(
                                  'profileEdit.save'.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: ConstantManager.kfont
            .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool? enable = true,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enable,
      style: ConstantManager.kfont,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ConstantManager.kfont,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: icon != null
            ? Icon(icon, color: ConstantManager.primaryColor)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ConstantManager.primaryColor, width: 2),
        ),
      ),
    );
  }
}
