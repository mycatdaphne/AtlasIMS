import 'package:atlas_ims/data/auth_service.dart';
import 'package:atlas_ims/views/entry.dart';
import 'package:atlas_ims/views/home.dart';
import 'package:atlas_ims/views/sett_sub_p/sett_gen.dart';
import 'package:atlas_ims/views/sett_sub_p/sett_locations.dart';
import 'package:atlas_ims/views/sett_sub_p/sett_tags.dart';
import 'package:atlas_ims/views/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/firebase_options.dart';
import 'package:atlas_ims/data/firestore_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AtlasIMS(authService: AuthService()));
}

class AtlasIMS extends StatelessWidget {
  const AtlasIMS({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return MaterialApp(
            title: 'Atlas IMS',
            theme: _theme(),
            home: AtlasSignIn(authService: authService),
          );
        }
        return _AuthenticatedAtlas(
          key: ValueKey(user.uid),
          authService: authService,
        );
      },
    );
  }
}

class _AuthenticatedAtlas extends StatefulWidget {
  const _AuthenticatedAtlas({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<_AuthenticatedAtlas> createState() => _AuthenticatedAtlasState();
}

class _AuthenticatedAtlasState extends State<_AuthenticatedAtlas> {
  late final FirestoreStorage _storage;
  late final Future<void> _initStorage;

  @override
  void initState() {
    super.initState();
    _storage = FirestoreStorage();
    _initStorage = _storage.init();
  }

  @override
  void dispose() {
    _storage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initStorage,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load inventory: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MaterialApp.router(
          title: 'Atlas IMS',
          theme: _theme(),
          routerConfig: _buildRouter(_storage, widget.authService),
        );
      },
    );
  }
}

GoRouter _buildRouter(FirestoreStorage storage, AuthService authService) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => AtlasHome(
          title: 'Atlas Home',
          storage: storage,
          authService: authService,
        ),
        routes: [
          GoRoute(
            path: 'settings/general',
            builder: (context, state) => const AtlasSettGen(title: 'General'),
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
}

ThemeData _theme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
  );
}
