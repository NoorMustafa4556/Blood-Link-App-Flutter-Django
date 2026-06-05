import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/BloodRequest.dart';
import '../../providers/BloodProvider.dart';
import '../../providers/AuthProvider.dart';
import '../../services/ApiService.dart';

class RequestDetailScreen extends StatefulWidget {
  final BloodRequest request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _messageController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkAcknowledge();
  }

  void _checkAcknowledge() {
    final status = widget.request.status;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if ((status == 'Accepted' || status == 'Rejected') && !widget.request.senderAcknowledged) {
      ApiService().acknowledgeRequest(widget.request.id).then((_) {
        if (mounted) {
          final role = auth.isDonorMode ? 'receiver' : 'sender';
          Provider.of<BloodProvider>(context, listen: false).fetchMyRequests(role, silent: true);
        }
      }).catchError((e) {
        debugPrint('Acknowledge Request Error: $e');
      });
    }
  }

  void _updateStatus(String status) async {
    setState(() => _isProcessing = true);
    final blood = Provider.of<BloodProvider>(context, listen: false);
    await blood.updateRequestStatus(
      widget.request.id, 
      status, 
      message: _messageController.text
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status Successfully'), backgroundColor: status == 'Accepted' ? Colors.green : Colors.red),
      );
    }
  }

  void _recipientAction(String action) async {
    setState(() => _isProcessing = true);
    final blood = Provider.of<BloodProvider>(context, listen: false);
    await blood.recipientRequestAction(widget.request.id, action);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'Completed' ? 'Thanks for confirming!' : 'Donor reported.'), backgroundColor: action == 'Completed' ? Colors.green : Colors.orange),
      );
    }
  }

  Future<void> _makeCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication); // fallback attempt
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  String? _extractPhoneNumber(String text) {
    final RegExp regExp = RegExp(r'\+?[0-9]{9,15}');
    final match = regExp.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final auth = Provider.of<AuthProvider>(context);
    final blood = Provider.of<BloodProvider>(context);
    
    // Get latest request status from the provider if available
    final request = blood.myRequests.firstWhere(
      (r) => r.id == widget.request.id,
      orElse: () => widget.request,
    );

    final bool isDonorView = auth.isDonorMode;
    final minutesLeft = request.minutesLeft;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Request Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ['Accepted', 'Completed'].contains(request.status) ? Colors.green[50] : (request.status == 'Pending' ? Colors.orange[50] : Colors.red[50]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ['Accepted', 'Completed'].contains(request.status) ? Colors.green[100]! : (request.status == 'Pending' ? Colors.orange[100]! : Colors.red[100]!)),
              ),
              child: Column(
                children: [
                  Text(
                    request.status,
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: ['Accepted', 'Completed'].contains(request.status) ? Colors.green : (request.status == 'Pending' ? Colors.orange : Colors.red)
                    ),
                  ),
                  if (request.status == 'Pending' && minutesLeft > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text('$minutesLeft mins remaining', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Patient & Hospital Info
            _sectionTitle('Blood Requirement'),
            _infoTile(Icons.bloodtype, 'Blood Group', request.bloodGroup),
            _infoTile(Icons.person_outline, 'Patient Name', request.patientName),
            _infoTile(Icons.local_hospital_outlined, 'Hospital', request.hospitalName),
            _infoTile(Icons.location_city_outlined, 'City', request.city),
            
            const SizedBox(height: 24),
            _sectionTitle(isDonorView ? 'Recipient Details' : 'Donor Details'),
            _infoTile(Icons.account_circle_outlined, 'Name', isDonorView ? request.senderName : request.receiverName),
            
            if (isDonorView) ...[
              _infoTile(Icons.phone_outlined, 'Phone (Tap to Call)', request.senderPhone ?? 'N/A', onTap: () => _makeCall(request.senderPhone)),
              _infoTile(Icons.email_outlined, 'Email', request.senderEmail ?? 'N/A'),
              _infoTile(Icons.location_city_outlined, 'City', request.senderCity ?? 'N/A'),
            ] else if (request.status == 'Accepted') ...[
              _infoTile(Icons.phone_outlined, 'Contact', 'Shared in response (See below)'),
            ],

            const SizedBox(height: 24),
            _sectionTitle('Request Message'),
            Text(request.message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            
            if (request.donorResponse != null && request.donorResponse!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionTitle('Donor Response'),
              (() {
                final phone = _extractPhoneNumber(request.donorResponse!);
                return InkWell(
                  onTap: phone != null ? () => _makeCall(phone) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50], 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            request.donorResponse!, 
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
                          ),
                        ),
                        if (phone != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.call, color: Colors.green),
                        ],
                      ],
                    ),
                  ),
                );
              })(),
            ],

            const SizedBox(height: 40),

            // Donor Actions
            if (isDonorView && request.status == 'Pending' && minutesLeft > 0) ...[
              const Text('Your Response (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'e.g. I am coming in 20 minutes...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus('Rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus('Accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
            ],

            if (!isDonorView && request.status == 'Accepted') ...[
              const SizedBox(height: 24),
              const Text('Donor Arrival Confirmation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _recipientAction('Reported'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('DID NOT ARRIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _recipientAction('Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('DONATED BLOOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: onTap != null ? Colors.blue : Colors.red[400]),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onTap != null ? Colors.blue : Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
