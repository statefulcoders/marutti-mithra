import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/utils/settings/comlate_settings_memory.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_sub_admin_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_user_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_users_helper.dart';

import '../../comlate/widgets/comlate_root_container.dart';
import '../../comlate/widgets/comlate_text_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ComlateSettingsMemory.currentThemeMode;

  final _imageLimitController = TextEditingController();
  final _emailController = TextEditingController();
  final _mwController = TextEditingController();
  final _vcController = TextEditingController();
  final _maController = TextEditingController();
  final _hpController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();

  bool showSupportDetails = false;
  Map<String, dynamic>? adminData;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    adminData = await FirebaseUserHelper.getAdminInformation();
    if (adminData == null || adminData?[FirebaseSubAdminHelper.permAccessSupportSettings] == true) {
      fetchSupportDetails();
    } else {
      showSupportDetails = false;
    }

    setState(() {});
  }

  Future<void> fetchSupportDetails() async {
    showSupportDetails = true;
    final doc = await FirebaseFirestore.instance.collection('extras').doc('support').get();
    final data = doc.data() as Map<String, dynamic>;
    _emailController.text = data['email'] ?? '';
    _mwController.text = data['contacts']['MWholesales'] ?? '';
    _vcController.text = data['contacts']['Vinlam_Concepts'] ?? '';
    _maController.text = data['contacts']['Marutti_Aluminiums'] ?? '';
    _hpController.text = data['contacts']['Hardware_Palace'] ?? '';
    _locationController.text = data['location'] ?? '';
    _timeController.text = data['time'] ?? '';
    _imageLimitController.text = (int.tryParse((data['image_limit'] ?? 0).toString()) ?? 0).toString();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mwController.dispose();
    _vcController.dispose();
    _maController.dispose();
    _hpController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _imageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return ComlateRootContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              Text("Theme Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: textColor.withAlpha(100)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeMode>(
                    value: _themeMode,
                    key: UniqueKey(),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor,
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                      DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                        ComlateSettingsMemory.setThemeMode(mode);
                        setState(() {
                          _themeMode = mode;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (showSupportDetails) ...[
                Text("Support Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: 12),
                ComlateTextField(controller: _imageLimitController, hint: "Daily Image Limit", innerHint: true, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d+'))], fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 12),
                ComlateTextField(controller: _emailController, hint: "Email", innerHint: true, fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 12),
                ComlateTextField(controller: _mwController, hint: "MWholesales Contact Phone", innerHint: true, fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 12),
                ComlateTextField(controller: _hpController, hint: "Hardware Palace Contact Phone", innerHint: true, fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 12),
                ComlateTextField(controller: _vcController, hint: "Vinlam Concepts Contact Phone", innerHint: true, fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 12),
                ComlateTextField(controller: _maController, hint: "Marutti Aluminiums Contact Phone", fillColor: Get.isDarkMode ? null : Colors.white, innerHint: true),
                SizedBox(height: 12),
                ComlateTextField(controller: _locationController, hint: "Location", innerHint: true, fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 12),
                ComlateTextField(controller: _timeController, hint: "Support Hours", innerHint: true, fillColor: Get.isDarkMode ? null : Colors.white),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance.collection('extras').doc('support').set({
                        'email': _emailController.text,
                        'contacts': {
                          'Hardware_Palace': _hpController.text.trim(),
                          'Marutti_Aluminiums': _maController.text.trim(),
                          'Vinlam_Concepts': _vcController.text.trim(),
                          'MWholesales': _mwController.text.trim(),
                        },
                        'location': _locationController.text,
                        'time': _timeController.text,
                        'image_limit': int.tryParse(_imageLimitController.text.trim()) ?? 1,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated!')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Update"),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

}
