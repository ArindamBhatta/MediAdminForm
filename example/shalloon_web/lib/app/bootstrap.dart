import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:web_ui_plugins/firebase_options.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../view/client_plugin.dart';
import '../view/staff_plugin.dart';

/// All app wiring in one place.
/// main.dart calls [ShalloonBootstrap.run].
class ShalloonBootstrap {
  ShalloonBootstrap._();

  /// Local setup for development — initializes Firebase, sets a dev user, and registers plugins.
  static Future<void> run({bool useEmulators = false}) async {
    // Step 1: Initialize framework + Firebase
    await AppBootstrap.initialize(
      config: BootstrapConfig(
        initializeFirebase: () async {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          if (useEmulators) {
            FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
            FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

            // Firestore rules require request.auth != null.
            // For local dev with emulators, ensure a signed-in Firebase user.
            if (FirebaseAuth.instance.currentUser == null) {
              await FirebaseAuth.instance.signInAnonymously();
            }
          }
        },
        defaultPermissionPolicy: const OpenPermissionPolicy(),
      ),
    );

    // Step 2: Set active user (replace with real auth state listener)
    PermissionMiddleware.instance.setUser(
      const UserIdentity(
        userId: 'dev-user',
        persona: 'admin', // ShalloonPersona.admin.label
        email: 'dev@shalloon.app',
      ),
    );

    // Step 3: Register plugins — this is the entire app configuration
    await AppBootstrap.registerPlugins([staffPlugin, clientPlugin]);
  }
}
