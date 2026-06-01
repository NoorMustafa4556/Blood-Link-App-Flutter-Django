import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../providers/AuthProvider.dart';
import '../../providers/BloodProvider.dart';
import '../../utils/Constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedCity;
  bool _isSaving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String _completePhoneNumber = '';
  String _initialCountry = 'PK';
  String _initialPhone = '';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _fullNameController.text = user.firstName;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _selectedCity = user.profile?.city;
      
      final rawPhone = user.profile?.phoneNumber ?? '';
      _completePhoneNumber = rawPhone;
      
      if (rawPhone.startsWith('+92')) {
        _initialPhone = rawPhone.substring(3);
        _initialCountry = 'PK';
      } else if (rawPhone.startsWith('92')) {
        _initialPhone = rawPhone.substring(2);
        _initialCountry = 'PK';
      } else if (rawPhone.startsWith('+1')) {
        _initialPhone = rawPhone.substring(2);
        _initialCountry = 'US';
      } else if (rawPhone.startsWith('+44')) {
        _initialPhone = rawPhone.substring(3);
        _initialCountry = 'GB';
      } else {
        if (rawPhone.startsWith('0') && rawPhone.length > 1) {
          _initialPhone = rawPhone.substring(1);
        } else {
          _initialPhone = rawPhone;
        }
        _initialCountry = 'PK';
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _selectedImage = File(img.path));
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.updateProfile({
      'full_name': _fullNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _completePhoneNumber.trim(),
      'city': _selectedCity,
    }, imagePath: _selectedImage?.path);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final blood = Provider.of<BloodProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;
    final imageUrl = user?.profile?.fullImageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (imageUrl != null ? NetworkImage(imageUrl) : null),
                    child: (_selectedImage == null && imageUrl == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your full name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                enabled: false,
                decoration: _inputDecoration('Username', Icons.alternate_email).copyWith(
                  fillColor: Colors.grey[100],
                ),
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: _inputDecoration('Email Address', Icons.email_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email address';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              IntlPhoneField(
                decoration: _inputDecoration('Phone Number', Icons.phone_android_outlined),
                initialCountryCode: _initialCountry,
                initialValue: _initialPhone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onChanged: (phone) => _completePhoneNumber = phone.completeNumber,
                validator: (phone) {
                  if (phone == null || phone.number.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  try {
                    if (!phone.isValidNumber()) {
                      return 'Please enter a valid phone number';
                    }
                  } catch (_) {
                    if (phone.number.length < 9) {
                      return 'Phone number is too short';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: _inputDecoration('Select City', Icons.location_city),
                items: blood.cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedCity = v),
                validator: (v) => v == null ? 'Please select your city' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE CHANGES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5)),
    );
  }
}
