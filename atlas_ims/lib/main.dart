import 'package:atlas_ims/views/sett_sub_p/sett_gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/home.dart';

void main() {
  runApp(const AtlasIMS());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AtlasHome(title: 'Atlas IMS'),
      routes: [
        GoRoute(
          path: 'settings/general',
          builder: (context, state) => const AtlasSettGen(title: 'General'),
        )
      ]
    ),
  ],
);

class AtlasIMS extends StatelessWidget {
  const AtlasIMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Atlas IMS',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightBlue)),
      routerConfig: _router,
    );
  }
}
