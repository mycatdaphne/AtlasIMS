import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AtlasSettings extends StatefulWidget {
  const AtlasSettings({super.key, required this.title});

  final String title;

  @override
  State<AtlasSettings> createState() => _AtlasSettingsState();
}

class _AtlasSettingsState extends State<AtlasSettings> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('General'),
          onTap: () => context.push('/settings/general'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Account'),
          onTap: () => context.push('/settings/account'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Log Out'),
          onTap: () {},
        ),
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
      ],
    );
  }
}
