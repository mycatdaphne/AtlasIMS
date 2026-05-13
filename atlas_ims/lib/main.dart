import 'package:atlas_ims/views/sett_sub_p/sett_gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/firebase_options.dart';
import 'package:atlas_ims/data/firestore_storage.dart';
import 'views/home.dart';
import 'package:atlas_ims/views/entry.dart';
import 'package:atlas_ims/views/sett_sub_p/sett_locations.dart';
import 'package:atlas_ims/views/sett_sub_p/sett_tags.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  final storage = FirestoreStorage();
  await storage.init();

  runApp(AtlasIMS(storage: storage));
}

class AtlasIMS extends StatelessWidget {
  final FirestoreStorage storage;

  const AtlasIMS({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              AtlasHome(title: 'Atlas Home', storage: storage),
          routes: [
            GoRoute(
              path: 'settings/general',
              builder: (context, state) =>
                  const AtlasSettGen(title: 'General'),
            ),
            GoRoute(
              path: 'settings/tags',
              builder: (context, state) => AtlasSettTags(db: storage),
            ),
            GoRoute(
              path: 'settings/locations',
              builder: (context, state) => AtlasSettLocations(db: storage),
            ),
            GoRoute(
              path: 'entries/:id',
              builder: (context, state) => AtlasEntryDetail(
                db: storage,
                entryId: state.pathParameters['id']!,
              ),
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
