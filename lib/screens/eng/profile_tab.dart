import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/screens/eng/address_list_screen.dart';
import 'package:petshow/screens/eng/my_profile.dart';
import 'package:petshow/services/translation_service.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/utils/size_config.dart';
import 'package:petshow/widgets/space_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthController authController = Get.put(AuthController());
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    TranslationService.getSavedLanguage().then((lang) {
      setState(() {
        _selectedLanguage = lang;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() {
            final user = authController.userProfile['user'] as Map<String, dynamic>?;
            final avatarUrl = user?['avatar_url']?.toString();
            return CircleAvatar(
              radius: 40,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? const Icon(Icons.person, size: 40)
                  : null,
            );
          }),
          const Spacebar('h', space: 1.0),
          Obx(() {
            final user = authController.userProfile['user'] as Map<String, dynamic>?;
            final name = user?['name']?.toString() ?? 'Guest';
            return Center(
              child: Text(
                name,
                style: ConstantManager.kfont
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }),
          const Spacebar('h', space: 3.5),
          profileOption(Icons.person, "profile.myProfile".tr, () {
            Get.to(() => const ProfileScreen());
          }),
          profileOption(Icons.maps_home_work_outlined, "profile.address".tr,
              () {
            Get.to(() => const AddressListScreen());
          }),
          profileOption(
              Icons.account_balance_wallet, "profile.wallet".tr, () {}),
          profileOption(Icons.history, "profile.orderHistory".tr, () {}),
          profileOption(Icons.payment, "profile.paymentMethods".tr, () {}),
          profileOption(Icons.help_outline, "profile.helpSupport".tr, () {}),
          profileOption(Icons.language, "profile.language".tr, () {
            _showLanguageDialog();
          }),
          profileOption(Icons.logout, "profile.logout".tr, () {
            _showLogoutDialog();
          }),
        ],
      ),
    );
  }

  Widget profileOption(IconData icon, String text, ontap) {
    return ListTile(
      leading: Icon(icon, color: ConstantManager.primaryColor),
      title: Text(text,
          style: ConstantManager.kfont.copyWith(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: SizeConfig.blockSizeHorizontal! * 3.5),
      onTap: ontap,
    );
  }

  Widget _languageDropdownTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: ConstantManager.primaryColor),
      title: Text(
        'profile.language'.tr,
        style: ConstantManager.kfont.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text('profile.language.english'.tr),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: Text('profile.language.arabic'.tr),
          ),
        ],
        onChanged: (val) async {
          if (val == null) return;
          setState(() {
            _selectedLanguage = val;
          });
          await TranslationService.changeLanguage(val);
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'logout.title'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('logout.message'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('common.logout'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSelected = _selectedLanguage;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('profile.language'.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('profile.language.english'.tr),
                    value: 'en',
                    groupValue: tempSelected,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempSelected = val ?? 'en';
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('profile.language.arabic'.tr),
                    value: 'ar',
                    groupValue: tempSelected,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempSelected = val ?? 'ar';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('common.cancel'.tr),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _selectedLanguage = tempSelected;
                    });
                    await TranslationService.changeLanguage(_selectedLanguage);
                    Navigator.of(context).pop();
                  },
                  child: Text('common.confirm'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
