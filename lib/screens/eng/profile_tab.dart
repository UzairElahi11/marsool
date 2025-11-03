import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/screens/eng/address_list_screen.dart';
import 'package:petshow/screens/eng/my_profile.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/utils/size_config.dart';
import 'package:petshow/widgets/space_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1568605114967-8130f3a36994'),
          ),
          const Spacebar('h', space: 1.0),
          Center(
              child: Text('Ammar',
                  style: ConstantManager.kfont
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold))),
          const Spacebar('h', space: 3.5),
          profileOption(Icons.person, "My Profile", () {
            Get.to(()=>ProfileScreen());
          }),
          profileOption(Icons.maps_home_work_outlined, "Address", () {
            Get.to(()=>AddressListScreen());
          }),
          profileOption(Icons.account_balance_wallet, "Wallet", () {}),
          profileOption(Icons.history, "Order History", () {}),
          profileOption(Icons.payment, "Payment Methods", () {}),
          profileOption(Icons.help_outline, "Help & Support", () {}),
          profileOption(Icons.logout, "Logout", () {}),
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
}
