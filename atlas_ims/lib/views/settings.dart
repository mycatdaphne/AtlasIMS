import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AtlasSettings extends StatefulWidget {
  const AtlasSettings({super.key, required this.title});

  final String title;

  @override
  State<AtlasSettings> createState() => _AtlasSettingsState();

}

class _AtlasSettingsState extends State<AtlasSettings> {
  final List<({String label, String route})> options = [
    (label: 'General', route: '/settings/general'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(options[index].label),
            onTap: () {
              context.push(options[index].route);
            },
          );
        },
      ),
    );
  }
}
