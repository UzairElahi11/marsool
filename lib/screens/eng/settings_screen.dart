// Top imports section
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/screens/eng/change_password_screen.dart';
import 'package:petshow/screens/eng/privacy_policy_screen.dart';
import 'package:petshow/screens/eng/terms_screen.dart';
import 'package:petshow/services/translation_service.dart';
import 'package:petshow/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantManager.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('settings.title'.tr,
            style: ConstantManager.kfont.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _tile(Icons.lock_outline, 'profile.changePassword'.tr, () {
            Get.to(() => const ChangePasswordScreen());
          }),
          _tile(Icons.language, 'settings.language'.tr, () {
            _showLanguageDialog();
          }),
          _tile(Icons.description_outlined, 'settings.terms'.tr, () {
            Get.to(() => const TermsScreen());
          }),
          _tile(Icons.privacy_tip_outlined, 'settings.privacy'.tr, () {
            Get.to(() => const PrivacyPolicyScreen());
          }),
          _tile(Icons.star_rate_outlined, 'settings.rateApp'.tr, () {
            _rateApp();
          }),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text('settings.deleteAccount'.tr,
                style: ConstantManager.kfont.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.redAccent)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: ConstantManager.primaryColor),
      title: Text(title,
          style: ConstantManager.kfont.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSelected = _selectedLanguage;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('profile.language'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('profile.language.english'.tr),
                  value: 'en',
                  groupValue: tempSelected,
                  onChanged: (v) {
                    setStateDialog(() {
                      tempSelected = v ?? 'en';
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('profile.language.arabic'.tr),
                  value: 'ar',
                  groupValue: tempSelected,
                  onChanged: (v) {
                    setStateDialog(() {
                      tempSelected = v ?? 'ar';
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
                  if (mounted) Navigator.of(context).pop();
                },
                child: Text('common.confirm'.tr),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _rateApp() async {
    const androidId = 'com.app.petshow';
    const marketUrl = 'market://details?id=$androidId';
    const webUrl = 'https://play.google.com/store/apps/details?id=$androidId';
    try {
      final uri = Uri.parse(marketUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}
    final uriWeb = Uri.parse(webUrl);
    if (await canLaunchUrl(uriWeb)) {
      await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
    }
  }
}
