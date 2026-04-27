import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/src/core/contracts/data_model.dart';
import 'package:web_ui_plugins/src/core/contracts/permission_contract.dart';
import 'package:web_ui_plugins/src/core/contracts/plugin_descriptor.dart';
import 'package:web_ui_plugins/src/core/contracts/upload_contract.dart';
import 'package:web_ui_plugins/src/core/registry/plugin_registry.dart';
import 'package:web_ui_plugins/src/adapters/firebase/scoped_repo.dart';
import 'package:web_ui_plugins/src/adapters/firebase/firestore_service.dart';
import 'package:web_ui_plugins/src/core/form/cubit/form_cubit.dart';

/// Configuration passed to [AppBootstrap.initialize].
class BootstrapConfig {
  /// Firebase adapter initialization callback.
  /// Typically: Firebase.initializeApp(options: ...) plus emulator setup.
  final Future<void> Function() initializeFirebase;

  /// Default permission policy when a plugin doesn't declare its own.
  final PermissionPolicy defaultPermissionPolicy;

  /// Optional upload capability implementation.
  final UploadCapability? uploadCapability;

  const BootstrapConfig({
    required this.initializeFirebase,
    this.defaultPermissionPolicy = const OpenPermissionPolicy(),
    this.uploadCapability,
  });
}

/// One-call bootstrap for the entire web_ui_plugins app shell.
///
/// Usage:
/// ```dart
/// await AppBootstrap.initialize(config: BootstrapConfig(...));
/// await AppBootstrap.registerPlugins([staffPlugin, clientPlugin]);
/// runApp(AppBootstrap.buildApp(shell: ShaloonShell()));
/// ```
class AppBootstrap {
  AppBootstrap._();

  static BootstrapConfig? _config;
  static bool _initialized = false;

  static BootstrapConfig get config {
    assert(_config != null, 'Call AppBootstrap.initialize() first.');
    return _config!;
  }

  /// Step 1: Initialize Firebase and framework config.
  static Future<void> initialize({required BootstrapConfig config}) async {
    if (_initialized) return;
    _config = config;
    await config.initializeFirebase();
    _initialized = true;
  }

  /// Step 2: Register all plugins.
  /// Each plugin's service and repo are created inside scoped registry —
  /// no manual provider wiring needed.
  static Future<void> registerPlugins(
    List<PluginDescriptor> plugins,
  ) async {
    for (final plugin in plugins) {
      await PluginRegistry.instance.register(plugin);
    }
  }

  /// Step 3: Build the root widget with all repository providers injected
  /// automatically from the plugin registry.
  static Widget buildApp({
    required Widget shell,
    ThemeData? theme,
    String title = '',
  }) {
    final providers = _buildProviders();
    return MultiRepositoryProvider(
      providers: providers,
      child: Builder(
        builder: (context) {
          final cubits = _buildCubits(context);
          return MultiBlocProvider(
            providers: cubits,
            child: MaterialApp(
              title: title,
              theme: theme,
              home: shell,
            ),
          );
        },
      ),
    );
  }

  static List<RepositoryProvider> _buildProviders() {
    return PluginRegistry.instance.all.map((entry) {
      final desc = entry.descriptor;
      return RepositoryProvider(
        key: ValueKey('repo_${desc.moduleId}'),
        create: (_) => ScopedRepo(
          moduleId: desc.moduleId,
          service: FirestoreService(
            moduleId: desc.moduleId,
            collectionName: desc.dataBinding.collectionName,
            fromJson: desc.dataBinding.fromJson,
          ),
        ),
        lazy: false,
      );
    }).toList();
  }

  static List<BlocProvider> _buildCubits(BuildContext context) {
    return PluginRegistry.instance.all.map((entry) {
      final desc = entry.descriptor;
      return BlocProvider(
        key: ValueKey('cubit_${desc.moduleId}'),
        create: (_) => FormCubit(
          repo: RepositoryProvider.of<ScopedRepo>(context),
        ),
      );
    }).toList();
  }

  /// Reset for testing.
  static void reset() {
    _initialized = false;
    _config = null;
    PluginRegistry.instance.reset();
  }
}
