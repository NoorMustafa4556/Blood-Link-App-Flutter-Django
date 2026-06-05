import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/AuthProvider.dart';
import '../../utils/Config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final profile = user?.profile;
    final primaryColor = Theme.of(context).primaryColor;

    final imageUrl = profile?.fullImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
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
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
                    child: imageUrl == null ? Icon(Icons.person, size: 60, color: primaryColor) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.firstName ?? 'User',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _profileItem(Icons.person_outline, 'Username', user?.username ?? ''),
                  _profileItem(Icons.email_outlined, 'Email Address', user?.email ?? ''),
                  _profileItem(
                    Icons.phone_android_outlined,
                    'Phone',
                    profile?.phoneNumber != null
                        ? '${_getFlagEmoji(profile!.phoneNumber)}  ${profile.phoneNumber}'
                        : 'N/A',
                  ),
                  _profileItem(Icons.location_city, 'City', profile?.city ?? 'N/A'),
                  _profileItem(Icons.wc, 'Gender', profile?.gender ?? 'N/A'),
                  if (profile?.isDonor == true)
                    _profileItem(Icons.bloodtype_outlined, 'Blood Group', profile?.bloodGroup ?? 'N/A'),
                  const SizedBox(height: 30),
                  _profileItem(Icons.verified_user_outlined, 'Status', profile?.isDonor == true ? 'Donor' : 'Recipient'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFlagEmoji(String? phoneNumber) {
    if (phoneNumber == null) return '🇵🇰';
    final clean = phoneNumber.trim().replaceAll(' ', '');
    if (clean.startsWith('+92') || clean.startsWith('92')) {
      return '🇵🇰';
    } else if (clean.startsWith('+1') || clean.startsWith('1')) {
      return '🇺🇸';
    } else if (clean.startsWith('+44') || clean.startsWith('44')) {
      return '🇬🇧';
    }
    return '🇵🇰';
  }

  Widget _profileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC62828)),
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
