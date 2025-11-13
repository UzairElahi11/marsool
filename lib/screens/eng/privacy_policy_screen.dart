import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:petshow/services/settings_service.dart';
import 'package:petshow/utils/constants.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final SettingsService _service = SettingsService();
  bool _loading = true;
  String? _title;
  String? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.fetchCms('privacy-policy');
    setState(() {
      _loading = false;
      _title = data?['title']?.toString();
      _content = _sanitizeHtml(data?['content']?.toString());
    });
  }

  String? _sanitizeHtml(String? input) {
    if (input == null) return null;
    var s = input;
    s = s.replaceAllMapped(RegExp(r'<p(?=[^>\s])'), (m) => '<p>');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantManager.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text((_title ?? 'settings.privacy'.tr),
            style: ConstantManager.kfont.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _content == null
              ? Center(
                  child:
                      Text('No content available', style: ConstantManager.kfont),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Html(data: _content),
                ),
    );
  }
}