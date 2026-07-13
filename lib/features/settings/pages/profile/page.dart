import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sections/image_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = '/settings/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('profile_name') ?? '';
      emailController.text = prefs.getString('profile_email') ?? '';
      phoneController.text = prefs.getString('profile_phone') ?? '';
      _imagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', nameController.text);
    await prefs.setString('profile_email', emailController.text);
    await prefs.setString('profile_phone', phoneController.text);
    if (_imagePath != null) {
      await prefs.setString('profile_image', _imagePath!);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi usaha berhasil disimpan')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Usaha')),
      body: ListView(
        padding: const EdgeInsets.all(Dimens.dp16),
        children: [
          _ImageSection(
            imagePath: _imagePath,
            onTap: _pickImage,
          ),
          const Divider(),
          RegularTextInput(
            controller: nameController,
            label: 'Nama Bisnis',
            hintText: 'Kasir SUPER',
          ),
          Dimens.dp24.height,
          RegularTextInput(
            controller: emailController,
            label: 'Email',
            hintText: 'kasirsuper@gmail.com',
            keyboardType: TextInputType.emailAddress,
          ),
          Dimens.dp24.height,
          RegularTextInput(
            controller: phoneController,
            label: 'Phone Number',
            hintText: '08123456789',
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.dp16),
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: context.theme.colorScheme.primary,
              foregroundColor: context.theme.colorScheme.onPrimary,
            ),
            child: const Text('Simpan'),
          ),
        ),
      ),
    );
  }
}
