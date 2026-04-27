import 'package:flutter/material.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import 'app/bootstrap.dart';
import 'home/shell_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ShaloonBootstrap.run(useEmulators: true);

    runApp(
      AppBootstrap.buildApp(
        title: 'Shaloon',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        shell: const ShaloonShell(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Initialization failed: $e')),
        ),
      ),
    );
  }
}
