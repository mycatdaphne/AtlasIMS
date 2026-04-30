import 'package:atlas_ims/views/sett_sub_p/sett_gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';
import 'package:atlas_ims/data/sqlstorage.dart'; // adjust path
import 'views/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = Sqlstorage();
  await db.open('atlas_ims.db');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AtlasIMS(storage: db));
}

class AtlasIMS extends StatelessWidget {
  final Sqlstorage storage;

  const AtlasIMS({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              AtlasHome(title: 'Atlas IMS', storage: storage),
          routes: [
            GoRoute(
              path: 'settings/general',
              builder: (context, state) =>
                  const AtlasSettGen(title: 'General'),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Atlas IMS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      routerConfig: router,
    );
  }
}