import 'package:flutter/material.dart';
import 'package:vet_application/home/vet_application.dart';

import 'package:web_ui_plugins/web_ui_plugins.dart';

import 'app/vet_application_bootstrap.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Paste your new Firebase project values here.
  // Keep empty to use the generated DefaultFirebaseOptions.
  const customFirebaseConfig = VetFirebaseApiConfig(
    apiKey: 'AIzaSyD0J_5aqolfSn9uDnkcVfVvyrQjZc2gaBg',
    appId: '1:593360566365:web:ed338bacd98cdb509075b4',
    messagingSenderId: '593360566365',
    projectId: 'chat-app-44a75',
    authDomain: 'chat-app-44a75.firebaseapp.com',
    storageBucket: 'chat-app-44a75.firebasestorage.app',
    measurementId: 'G-RK7YFJGJJC',
  );

  final firebaseConfig = customFirebaseConfig.isComplete
      ? customFirebaseConfig
      : null;

  try {
    //initializes Firebase, sets up the user, and registers plugins.
    await VetApplicationBootstrap.run(
      useEmulators: true,
      firebaseConfig: firebaseConfig,
    );

    runApp(
      AppBootstrap.buildRouterApp(
        title: 'Vet Client App',
        theme: AppTheme.light.copyWith(
          colorScheme: AppTheme.light.colorScheme.copyWith(
            primary: AppColors.primary,
          ),
        ),
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        shellBuilder: (context, child) => VetApplication(child: child),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization failed: $e'))),
      ),
    );
  }
}
