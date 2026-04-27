import 'package:web_ui_plugins/src/core/contracts/data_model.dart';
import 'package:web_ui_plugins/src/core/contracts/permission_contract.dart';
import 'package:web_ui_plugins/src/core/contracts/plugin_descriptor.dart';

/// Resolved and active plugin entry, stored after successful registration.
class RegistedPlugin<T extends DataModel> {
  final PluginDescriptor<T> descriptor;
  final DateTime registeredAt;

  RegistedPlugin(this.descriptor) : registeredAt = DateTime.now();
}

/// Central plugin registry.
/// All plugins register here during bootstrap; the app shell reads from here
/// to generate sidebar entries, route tables, and permission checks.
class PluginRegistry {
  PluginRegistry._();
  static final PluginRegistry instance = PluginRegistry._();

  final List<RegistedPlugin> _plugins = [];

  /// Register a plugin. Throws if a plugin with the same [moduleId] is
  /// already registered (guards against double-registration on hot reload).
  Future<void> register<T extends DataModel>(
    PluginDescriptor<T> descriptor,
  ) async {
    final alreadyExists = _plugins.any(
      (p) => p.descriptor.moduleId == descriptor.moduleId,
    );
    if (alreadyExists) return; // idempotent on hot reload

    await descriptor.onRegister?.call();
    _plugins.add(RegistedPlugin<T>(descriptor));
  }

  /// Unregister a plugin by moduleId (used in tests or dynamic plugin removal).
  Future<void> unregister(String moduleId) async {
    final plugin = _plugins.cast<RegistedPlugin?>().firstWhere(
      (p) => p?.descriptor.moduleId == moduleId,
      orElse: () => null,
    );
    if (plugin == null) return;
    await plugin.descriptor.onDispose?.call();
    _plugins.removeWhere((p) => p.descriptor.moduleId == moduleId);
  }

  /// All registered plugins, sorted by [order].
  List<RegistedPlugin> get all {
    final sorted = List<RegistedPlugin>.from(_plugins);
    sorted.sort((a, b) => a.descriptor.order.compareTo(b.descriptor.order));
    return sorted;
  }

  /// Plugins visible to [user] after evaluating each plugin's visibility policy.
  List<RegistedPlugin> visibleTo(UserIdentity user) {
    return all.where((p) {
      final policy = p.descriptor.visibilityPolicy;
      if (policy == null) return true;
      final ctx = PermissionContext(
        user: user,
        moduleId: p.descriptor.moduleId,
      );
      return policy.evaluate(ctx).granted;
    }).toList();
  }

  /// Find a plugin by moduleId.
  RegistedPlugin? findById(String moduleId) {
    return all.cast<RegistedPlugin?>().firstWhere(
      (p) => p?.descriptor.moduleId == moduleId,
      orElse: () => null,
    );
  }

  /// Reset for testing.
  void reset() => _plugins.clear();
}
