import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/User.dart';
import '../../providers/BloodProvider.dart';

class RequestBloodForm extends StatefulWidget {
  final UserProfile donor;
  final String bloodGroup;
  const RequestBloodForm({
    super.key,
    required this.donor,
    required this.bloodGroup,
  });

  @override
  State<RequestBloodForm> createState() => _RequestBloodFormState();
}

class _RequestBloodFormState extends State<RequestBloodForm> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _messageController = TextEditingController();
  String _duration = '1 Hour';
  int _durationHours = 1;

  final Map<String, int> _durationMap = {
    '1 Hour': 1,
    '2 Hours': 2,
    '5 Hours': 5,
    '10 Hours': 10,
    '24 Hours': 24,
  };

  Future<void> _submit(BloodProvider blood) async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> data = {
      'receiver_id': widget.donor.id,
      'patient_name': _patientNameController.text.trim(),
      'blood_group': widget.bloodGroup,
      'city': widget.donor.city,
      'hospital_name': _hospitalController.text.trim(),
      'message': _messageController.text.trim(),
      'duration': _durationHours,
      'time_duration': _duration,
    };

    String? error = await blood.sendRequest(data);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context); // Go back to Home
    }
  }

  @override
  Widget build(BuildContext context) {
    final blood = Provider.of<BloodProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Blood',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Requesting ${widget.bloodGroup} for Patient',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _patientNameController,
                decoration: _inputDecoration('Patient Name', Icons.person),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hospitalController,
                decoration: _inputDecoration(
                  'Hospital Name',
                  Icons.local_hospital,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _duration,
                decoration: _inputDecoration('Request Duration', Icons.timer),
                items:
                    _durationMap.keys
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged:
                    (v) => setState(() {
                      _duration = v!;
                      _durationHours = _durationMap[v]!;
                    }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'Message (Optional)',
                  Icons.message,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: blood.isLoading ? null : () => _submit(blood),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      blood.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'SEND REQUEST',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
