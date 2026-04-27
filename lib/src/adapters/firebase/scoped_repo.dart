import 'package:web_ui_plugins/src/core/contracts/data_model.dart';
import 'package:web_ui_plugins/src/core/contracts/form_service_mixin.dart';
import 'package:web_ui_plugins/src/core/form/repo/form_repo_mixin.dart';
import 'package:web_ui_plugins/src/core/registry/scoped_registry.dart';

/// Scoped repository: replaces old SectionRepo with a registry keyed by
/// (moduleId + modelType + collection) instead of just (Type).
///
/// This prevents cross-module collisions when two plugins use the same model
/// type but different collections.
class ScopedRepo<T extends DataModel> with FormRepoMixin<T> {
  static final ScopedRegistry<ScopedRepo> _registry =
      ScopedRegistry<ScopedRepo>();

  final String moduleId;

  ScopedRepo._internal({
    required this.moduleId,
    required FormServiceMixin<T> service,
  }) {
    initService(service);
  }

  /// Scoped factory: one repo per (moduleId, T, collectionName) triple.
  factory ScopedRepo({
    required String moduleId,
    required FormServiceMixin<T> service,
  }) {
    // Derive collection name from the service if it's a FirestoreService.
    final collectionName =
        (service as dynamic).collectionName as String? ?? T.toString();

    final key = ScopedKey(
      moduleId: moduleId,
      modelType: T.toString(),
      collection: collectionName,
    );
    return _registry.getOrCreate(
      key,
      () => ScopedRepo<T>._internal(moduleId: moduleId, service: service),
    ) as ScopedRepo<T>;
  }

  /// Convenience lookup: find an item by its uid in the local cache.
  T? getById(String id) {
    try {
      return items.firstWhere((item) => item.uid == id);
    } catch (_) {
      return null;
    }
  }
}
