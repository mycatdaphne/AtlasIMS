import 'package:atlas_ims/data/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AtlasSettings extends StatefulWidget {
  const AtlasSettings({
    super.key,
    required this.title,
    required this.authService,
  });

  final String title;
  final AuthService authService;

  @override
  State<AtlasSettings> createState() => _AtlasSettingsState();
}

class _AtlasSettingsState extends State<AtlasSettings> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return ListView(
      children: [
        if (user != null) ...[
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.photoURL == null ? null : NetworkImage(user.photoURL!),
              child: user.photoURL == null
                  ? Text(_initialFor(user))
                  : null,
            ),
            title: Text(user.displayName ?? 'Signed in'),
            subtitle: Text(user.email ?? user.uid),
          ),
          const Divider(),
        ],
        ListTile(
          title: const Text('Manage Tags'),
          onTap: () => context.push('/settings/tags'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Manage Locations'),
          onTap: () => context.push('/settings/locations'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Log Out'),
          onTap: () => _confirmSignOut(context),
        ),
      ],
    );
  }

  String _initialFor(User user) {
    final label = user.displayName ?? user.email ?? 'A';
    return label.trim().isEmpty ? 'A' : label.trim()[0].toUpperCase();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access Atlas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.authService.signOut();
    }
  }
}
