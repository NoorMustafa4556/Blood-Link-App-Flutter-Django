import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../providers/AuthProvider.dart';
import '../../providers/BloodProvider.dart';
import '../../utils/Constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _phoneNumber = '';
  bool _obscurePassword = true;
  
  String _role = 'recipient';
  String _gender = 'Male';
  String? _city;
  String? _bloodGroup;
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BloodProvider>(context, listen: false).fetchCitiesAndBloodGroups();
    });
  }

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _selectedImage = File(img.path));
  }

  Future<void> _register(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneNumber.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid phone number')));
       return;
    }

    Map<String, dynamic> data = {
      'full_name': _fullNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneNumber,
      'password': _passwordController.text,
      'role': _role,
      'gender': _gender,
      'city': _city,
    };
    
    if (_role == 'donor') {
      data['blood_group'] = _bloodGroup;
    }

    String? error = await auth.register(data);
    
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.'), backgroundColor: Colors.green));
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final blood = Provider.of<BloodProvider>(context);
    final primaryColor = const Color(0xFFC62828);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(child: _roleButton('recipient', 'Recipient')),
                    Expanded(child: _roleButton('donor', 'Donor')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildField(_fullNameController, 'Full Name', Icons.person_outline, (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your full name';
                return null;
              }),
              const SizedBox(height: 16),
              _buildField(_usernameController, 'Username', Icons.alternate_email, (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your username';
                if (v.trim().length < 3) return 'Username must be at least 3 characters';
                return null;
              }),
              const SizedBox(height: 16),
              _buildField(_emailController, 'Email', Icons.email_outlined, (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v.trim())) return 'Please enter a valid email address';
                return null;
              }, type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              IntlPhoneField(
                decoration: _inputDecoration('Phone Number', Icons.phone_android_outlined),
                initialCountryCode: 'PK',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onChanged: (phone) => _phoneNumber = phone.completeNumber,
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
              _buildDropdown('Gender', Icons.wc, _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v!), validator: (v) => v == null ? 'Please select your gender' : null),
              const SizedBox(height: 16),
              _buildDropdown('Select your city', Icons.location_city, _city, blood.cities, (v) => setState(() => _city = v), validator: (v) => v == null ? 'Please select your city' : null),
              const SizedBox(height: 16),
              if (_role == 'donor') ...[
                _buildDropdown('Select blood group', Icons.bloodtype_outlined, _bloodGroup, blood.bloodGroups, (v) => setState(() => _bloodGroup = v), validator: (v) => v == null ? 'Please select your blood group' : null),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter a password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
                onFieldSubmitted: (_) => _register(auth),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : () => _register(auth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('REGISTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?", style: TextStyle(color: Colors.grey, fontSize: 15)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Login', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, String? Function(String?) validator, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? value, List<String> items, Function(String?) onChanged, {String? Function(String?)? validator}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label, icon),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: validator ?? (v) => v == null ? 'Required' : null,
    );
  }

  Widget _roleButton(String role, String label) {
    bool isSelected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC62828) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
