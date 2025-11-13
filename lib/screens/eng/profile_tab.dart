import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:petshow/screens/eng/change_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/screens/eng/address_list_screen.dart';
import 'package:petshow/screens/eng/coupons_screen.dart';
import 'package:petshow/screens/eng/my_profile.dart';
import 'package:petshow/screens/eng/order_history_screen.dart';
import 'package:petshow/screens/eng/payment_methods_screen.dart';
import 'package:petshow/screens/eng/add_card_screen.dart';
import 'package:petshow/screens/eng/settings_screen.dart';
import 'package:petshow/services/translation_service.dart';
import 'package:petshow/services/wallet_service.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/utils/size_config.dart';
import 'package:petshow/widgets/space_bar.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthController authController = Get.put(AuthController());
  final WalletService _walletService = WalletService();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    TranslationService.getSavedLanguage().then((lang) {
      setState(() {
        _selectedLanguage = lang;
      });
    });
    _fetchWalletDetails();
  }

  Future<void> _fetchWalletDetails() async {
    final wallet = await _walletService.getWalletDetails();
    if (wallet != null) {
      final user =
          (authController.userProfile['user'] as Map<String, dynamic>?) ?? {};
      // Update balance and currency on the user map to reuse existing UI bindings
      user['wallet_balance'] = wallet['balance'];
      user['currency'] = wallet['currency'];
      authController.userProfile['user'] = user;
      authController.userProfile.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() {
            final user =
                authController.userProfile['user'] as Map<String, dynamic>?;
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
            final user =
                authController.userProfile['user'] as Map<String, dynamic>?;
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
          _walletListTile(),
          _couponsListTile(),
          profileOption(Icons.history, "profile.orderHistory".tr, () {
            Get.to(() => const OrderHistoryScreen());
          }),
          profileOption(Icons.payment, "profile.paymentMethods".tr, () {
            Get.to(() => const PaymentMethodsScreen());
          }),
          profileOption(Icons.settings, "settings.title".tr, () {
            Get.to(() => const SettingsScreen());
          }),
          profileOption(Icons.lock_outline, "profile.changePassword".tr, () {
            Get.to(() => const ChangePasswordScreen());
          }),
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

  void _showWalletBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final TextEditingController amountController = TextEditingController();
        String selectedMethod = 'Add New Card';
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setStateBottom) {
              double parsedAmount =
                  double.tryParse(amountController.text) ?? 0.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Balance',
                          style: ConstantManager.kfont.copyWith(
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
                  Text(
                    'Payment Method',
                    style: ConstantManager.kfont.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedMethod,
                          style: ConstantManager.kfont.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await _showPaymentMethodsSheet(
                              ctx, selectedMethod);
                          if (result != null) {
                            selectedMethod = result;
                            setStateBottom(() {});
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Change'),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter amount to be added to your balance',
                    style: ConstantManager.kfont,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) => setStateBottom(() {}),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: parsedAmount > 5
                          ? () async {
                              final result = await _walletService.topupWallet(
                                amount: parsedAmount,
                                paymentMethodId: 1,
                              );
                              if (result != null) {
                                final user = (authController.userProfile['user']
                                        as Map<String, dynamic>?) ??
                                    {};
                                if (result['balance'] != null) {
                                  user['wallet_balance'] = result['balance'];
                                }
                                if (result['currency'] != null) {
                                  user['currency'] = result['currency'];
                                }
                                authController.userProfile['user'] = user;
                                authController.userProfile.refresh();

                                Get.snackbar(
                                  'Success',
                                  'Wallet topped up successfully',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                Navigator.of(ctx).pop();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantManager.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Pay'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _walletListTile() {
    return ListTile(
      leading: const Icon(Icons.account_balance_wallet,
          color: ConstantManager.primaryColor),
      title: Text(
        "profile.wallet".tr,
        style: ConstantManager.kfont.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final user =
                authController.userProfile['user'] as Map<String, dynamic>?;
            final dynamic balanceVal =
                user?['wallet_balance'] ?? user?['balance'];
            final String currency = user?['currency']?.toString() ?? 'SAR';
            final String balanceStr = (balanceVal == null)
                ? '0.0'
                : (balanceVal is num
                    ? balanceVal.toStringAsFixed(1)
                    : balanceVal.toString());
            return Text(
              '$currency $balanceStr',
              style: ConstantManager.kfont.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          }),
          const SizedBox(width: 10),
          InkWell(
            onTap: _showWalletBottomSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.black, size: 18),
                  const SizedBox(width: 6),
                  Text('Add',
                      style: ConstantManager.kfont.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      onTap: _showWalletBottomSheet,
    );
  }

  Widget _couponsListTile() {
    return ListTile(
      leading: const Icon(Icons.local_offer_outlined,
          color: ConstantManager.primaryColor),
      title: Text(
        'Coupons',
        style: ConstantManager.kfont.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: OutlinedButton(
        onPressed: () => Get.to(() => const CouponsScreen()),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.green, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(0, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '+ ADD COUPON',
          style: ConstantManager.kfont.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () => Get.to(() => const CouponsScreen()),
    );
  }

  String _last4(dynamic number) {
    final s = number?.toString() ?? '';
    return s.length >= 4 ? s.substring(s.length - 4) : '****';
  }

  Future<List<dynamic>> _fetchPaymentMethodsForSheet() async {
    const endpoint = 'http://hcodecraft.com/felwa/api/payment-methods';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    log('PROFILE SHEET PAYMENT METHODS URL::: ${res.request?.url}');
    log('PROFILE SHEET PAYMENT METHODS STATUS::: ${res.statusCode}');
    log('PROFILE SHEET PAYMENT METHODS RESPONSE::: ${res.body}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        final data = decoded['data'];
        if (data is Map && data['items'] is List) {
          return List<dynamic>.from(data['items']);
        }
        if (data is List) return List<dynamic>.from(data);
      }
      return [];
    }
    // On error, just return empty list; caller will show message
    return [];
  }

  Future<String?> _showPaymentMethodsSheet(
      BuildContext ctx, String current) async {
    return showModalBottomSheet<String>(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Payment Method',
                        style: ConstantManager.kfont.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              FutureBuilder<List<dynamic>>(
                future: _fetchPaymentMethodsForSheet(),
                builder: (ctx2, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final methods = snap.data ?? [];
                  if (methods.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('No saved cards found',
                              style: ConstantManager.kfont),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.green,
                              child: Icon(Icons.add,
                                  size: 12, color: Colors.white),
                            ),
                            title: Text('Add New Card',
                                style: ConstantManager.kfont.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                            onTap: () async {
                              final result = await Get.to<Map<String, dynamic>>(
                                () => const AddCardScreen(),
                              );
                              if (result != null) {
                                final brand = result['brand'] ?? 'Card';
                                final last4 = result['last4'] ?? '****';
                                Navigator.pop(context, '$brand •••• $last4');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.add, size: 12, color: Colors.white),
                        ),
                        title: Text('Add New Card',
                            style: ConstantManager.kfont.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        onTap: () async {
                          final result = await Get.to<Map<String, dynamic>>(
                            () => const AddCardScreen(),
                          );
                          if (result != null) {
                            final brand = result['brand'] ?? 'Card';
                            final last4 = result['last4'] ?? '****';
                            Navigator.pop(context, '$brand •••• $last4');
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ...methods.map((pm) {
                        final map = pm is Map<String, dynamic>
                            ? pm
                            : <String, dynamic>{};
                        final brand = map['brand'] ?? map['type'] ?? 'Card';
                        final last4 =
                            map['last4'] ?? _last4(map['card_number']);
                        final name =
                            map['cardholder_name'] ?? map['name'] ?? '';
                        final isDefault = (map['is_default'] == true) ||
                            (map['default'] == true);
                        final label = '$brand •••• $last4';
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.credit_card,
                                  color: Colors.black54, size: 28),
                              title: Text(
                                label,
                                style: ConstantManager.kfont.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: name.isNotEmpty
                                  ? Text(name, style: ConstantManager.kfont)
                                  : null,
                              trailing: (label == current && isDefault)
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () => Navigator.pop(context, label),
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
