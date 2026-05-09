import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/src/adapters/firebase/section_repo.dart';
import 'package:web_ui_plugins/src/core/contracts/permission_contract.dart';
import 'package:web_ui_plugins/src/core/contracts/plugin_descriptor.dart';
import 'package:web_ui_plugins/src/core/contracts/upload_contract.dart';
import 'package:web_ui_plugins/src/core/permissions/permission_middleware.dart';
import 'package:web_ui_plugins/src/core/registry/plugin_registry.dart';
import 'package:web_ui_plugins/src/adapters/firebase/firestore_service.dart';
import 'package:web_ui_plugins/src/core/form/cubit/form_cubit.dart';

/// Setup and configuration for the app shell, including Firebase initialization and plugin registration.
class BootstrapConfig {
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

class AppBootstrap {
  AppBootstrap._();

  static const String forbiddenPath = '/forbidden';
  static const String noPluginsPath = '/no-plugins';

  ///initialize firebase private property can't access outside.
  static BootstrapConfig? _config;

  /// Expose the config for internal use by plugins and services.
  static BootstrapConfig get config {
    if (_config == null) {
      throw StateError(
        'AppBootstrap not initialized. Call AppBootstrap.initialize() first.',
      );
    }
    return _config!;
  }

  /// make singleton and enforce initialization before access to config.
  static bool _instance = false;

  /// Step 1: UI call Initialize Firebase package config.
  static Future<void> initialize({required BootstrapConfig config}) async {
    if (_instance) return;
    _config = config;
    await config.initializeFirebase();
    _instance = true;
  }

  /// Step 2: Register all plugins. repository, cubit, and routes are automatically setup from the plugin descriptors.
  /// which plugins should appear in the sidebar
  static Future<void> registerPlugins(List<PluginDescriptor> plugins) async {
    for (final plugin in plugins) {
      await PluginRegistry.instance.register(plugin);
    }
  }

  static Widget buildRouterApp({
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
    String? title,
    String? initialLocation,
    WidgetBuilder? forbiddenBuilder,
    WidgetBuilder? noPluginsBuilder,
    required Widget Function(BuildContext context, Widget child) shellBuilder,
  }) {
    final providers = _buildProviders();
    return MultiRepositoryProvider(
      providers: providers,
      child: Builder(
        builder: (context) {
          final cubits = _buildCubits(context);
          final router = createRouter(
            shellBuilder: shellBuilder,
            initialLocation: initialLocation,
            forbiddenBuilder: forbiddenBuilder,
            noPluginsBuilder: noPluginsBuilder,
          );
          return MultiBlocProvider(
            providers: cubits,
            child: MaterialApp.router(
              title: title,
              theme: theme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }

  static GoRouter createRouter({
    required Widget Function(BuildContext context, Widget child) shellBuilder,
    String? initialLocation,
    WidgetBuilder? forbiddenBuilder,
    WidgetBuilder? noPluginsBuilder,
  }) {
    final pluginRoutes = _buildPluginRoutes();
    return GoRouter(
      initialLocation: initialLocation ?? '/',
      routes: [
        GoRoute(path: '/', redirect: (_, __) => _defaultLocation()),
        GoRoute(
          path: forbiddenPath,
          builder: (context, _) =>
              forbiddenBuilder?.call(context) ??
              const _PluginStatusView(
                title: 'Access denied',
                message: 'Your current persona cannot open this plugin route.',
              ),
        ),
        GoRoute(
          path: noPluginsPath,
          builder: (context, _) =>
              noPluginsBuilder?.call(context) ??
              const _PluginStatusView(
                title: 'No plugins available',
                message:
                    'No registered plugin is visible to the active persona.',
              ),
        ),
        ShellRoute(
          builder: (context, _, child) => shellBuilder(context, child),
          routes: pluginRoutes,
        ),
      ],
    );
  }

  static List<RepositoryProvider> _buildProviders() {
    return PluginRegistry.instance.all.map((entry) {
      final desc = entry.descriptor;
      return RepositoryProvider(
        key: ValueKey('repo_${desc.moduleId}'),
        create: (_) => SectionRepo(
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
        create: (_) =>
            FormCubit(repo: RepositoryProvider.of<SectionRepo>(context)),
      );
    }).toList();
  }

  static List<RouteBase> _buildPluginRoutes() {
    final routes = <RouteBase>[];

    for (final plugin in PluginRegistry.instance.all) {
      final descriptor = plugin.descriptor;
      for (var index = 0; index < descriptor.routes.length; index++) {
        final route = descriptor.routes[index];
        routes.add(
          GoRoute(
            path: route.path,
            redirect: (_, state) {
              final canAccess = PermissionMiddleware.instance.canAccessRoute(
                descriptor.moduleId,
                route.path,
              );
              if (canAccess) {
                return null;
              }

              if (state.uri.path == forbiddenPath) {
                return null;
              }
              return forbiddenPath;
            },
            builder: route.builder,
          ),
        );
      }
    }

    return routes;
  }

  static String _defaultLocation() {
    for (final plugin in PluginRegistry.instance.all) {
      if (!PermissionMiddleware.instance.isPluginVisible(
        plugin.descriptor.moduleId,
      )) {
        continue;
      }

      for (final route in plugin.descriptor.routes) {
        if (PermissionMiddleware.instance.canAccessRoute(
          plugin.descriptor.moduleId,
          route.path,
        )) {
          return route.path;
        }
      }
    }

    return noPluginsPath;
  }

  /// Reset for testing.
  static void reset() {
    _instance = false;
    _config = null;
    PluginRegistry.instance.reset();
  }
}

class _PluginStatusView extends StatelessWidget {
  final String title;
  final String message;

  const _PluginStatusView({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
