import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/AuthProvider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _userRole = 'recipient'; 

  Future<void> _login(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    String? error = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text,
      _userRole,
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final primaryColor = const Color(0xFFC62828);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.water_drop, size: 80, color: Color(0xFFC62828)),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Back,',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Username', Icons.person_outline),
                      validator: (v) => v!.isEmpty ? 'Enter username' : null,
                    ),
                    const SizedBox(height: 20),
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
                      validator: (v) => v!.isEmpty ? 'Enter password' : null,
                      onFieldSubmitted: (_) => _login(auth),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : () => _login(auth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('New User? ', style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(String role, String label) {
    bool isSelected = _userRole == role;
    return GestureDetector(
      onTap: () => setState(() => _userRole = role),
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
