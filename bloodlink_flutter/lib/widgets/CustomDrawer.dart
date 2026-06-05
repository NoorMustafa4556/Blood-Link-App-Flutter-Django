import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/AuthProvider.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onChangePasswordPressed;

  const CustomDrawer({super.key, this.onChangePasswordPressed});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final imageUrl = auth.user?.profile?.fullImageUrl;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              auth.user?.firstName ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(auth.user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Request History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              if (onChangePasswordPressed != null) {
                onChangePasswordPressed!();
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).primaryColor),
            title: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
