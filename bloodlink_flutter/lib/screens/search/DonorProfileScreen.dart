import 'package:flutter/material.dart';
import '../../models/User.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/RequestBloodForm.dart';

class DonorProfileScreen extends StatelessWidget {
  final UserProfile donor;
  final String bloodGroup;

  const DonorProfileScreen({super.key, required this.donor, required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final imageUrl = donor.fullImageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Donor Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    backgroundImage: imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
                    child: imageUrl == null ? Icon(Icons.person, size: 70, color: primaryColor) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    donor.fullName ?? 'Donor',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      donor.bloodGroup ?? bloodGroup,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Information', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                  const SizedBox(height: 20),
                  _infoCard(Icons.email_outlined, 'Email', donor.email ?? 'Not Available'),
                  _infoCard(Icons.phone_outlined, 'Phone', donor.phoneNumber ?? 'Not Available'),
                  _infoCard(Icons.location_city, 'City', donor.city ?? 'N/A'),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestBloodForm(donor: donor, bloodGroup: bloodGroup),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send Blood Request', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.red),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
