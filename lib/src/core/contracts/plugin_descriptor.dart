import 'package:flutter/material.dart';
import 'package:web_ui_plugins/src/core/contracts/data_model.dart';
import 'package:web_ui_plugins/src/core/contracts/permission_contract.dart';

/// Declares which optional framework capabilities a plugin uses.
class PluginFeatureFlags {
  final bool supportsCrud;
  final bool supportsRealtime;
  final bool supportsUpload;

  const PluginFeatureFlags({
    this.supportsCrud = true,
    this.supportsRealtime = true,
    this.supportsUpload = false,
  });
}

/// Describes a single route a plugin contributes to the app shell.
class PluginRouteDescriptor {
  final String path;
  final WidgetBuilder builder;
  final PermissionPolicy? accessPolicy;

  const PluginRouteDescriptor({
    required this.path,
    required this.builder,
    this.accessPolicy,
  });
}

/// Data binding information for a plugin's model and Firestore collection.
class PluginDataBinding<T extends DataModel> {
  final String collectionName;
  final T Function(Map<String, dynamic> json) fromJson;
  final T Function() createEmpty;

  const PluginDataBinding({
    required this.collectionName,
    required this.fromJson,
    required this.createEmpty,
  });
}

/// The top-level descriptor a developer provides to register a plugin.
/// This is the entire surface area a module author fills in.
class PluginDescriptor<T extends DataModel> {
  /// Stable unique identifier for this plugin (e.g. 'staff', 'clients').
  final String moduleId;

  /// Display metadata shown in sidebar and headers.
  final String title;
  final IconData icon;
  final Color color;
  final int order;

  /// Which feature groups this plugin uses.
  final PluginFeatureFlags features;

  /// Routes this plugin contributes.
  final List<PluginRouteDescriptor> routes;

  /// Data binding: collection, serializer, empty factory.
  final PluginDataBinding<T> dataBinding;

  /// Visibility policy: is this plugin shown to current user?
  final PermissionPolicy? visibilityPolicy;

  /// Optional lifecycle hooks.
  final Future<void> Function()? onRegister;
  final Future<void> Function()? onDispose;

  const PluginDescriptor({
    required this.moduleId,
    required this.title,
    required this.icon,
    required this.color,
    required this.dataBinding,
    this.order = 0,
    this.features = const PluginFeatureFlags(),
    this.routes = const [],
    this.visibilityPolicy,
    this.onRegister,
    this.onDispose,
  });
}
