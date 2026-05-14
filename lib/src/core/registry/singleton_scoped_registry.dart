/// Scoped registry key: moduleId + model type + collection + optional scope.
/// Prevents cross-module singleton collisions that the old Type-only keys caused.
class CrossModuleSingletonKey {
  final String moduleId;
  final String modelType;
  final String collection;
  final String scopeId;

  const CrossModuleSingletonKey({
    required this.moduleId,
    required this.modelType,
    required this.collection,
    this.scopeId = 'default',
  });

  String get value => '$moduleId/$modelType/$collection/$scopeId';
}

/// Generic scoped registry — stores instances keyed by [CrossModuleSingletonKey].
/// Each module gets isolated instances: no cross-module leakage.
///
/// Usage: create one static instance per adapter class:
/// ```dart
/// static final _registry = SingletonScopedRegistry<MyService>();
/// ```
class SingletonScopedRegistry<T> {
  SingletonScopedRegistry();

  final Map<CrossModuleSingletonKey, T> _store = {};

  /// Register or overwrite a [value] for [key].
  void register(CrossModuleSingletonKey key, T value) {
    _store[key] = value;
  }

  /// Retrieve an existing instance, or create and register one via [factory].
  T getOrCreate(CrossModuleSingletonKey key, T Function() factory) {
    return _store.putIfAbsent(key, factory);
  }

  /// Retrieve an existing instance or return null.
  T? get(CrossModuleSingletonKey key) => _store[key];

  /// Remove an instance (used during plugin dispose lifecycle).
  void unregister(CrossModuleSingletonKey key) {
    _store.remove(key);
  }

  /// Remove all instances for a given moduleId.
  void unregisterModule(String moduleId) {
    _store.removeWhere((key, _) => key.moduleId == moduleId);
  }

  bool contains(CrossModuleSingletonKey key) => _store.containsKey(key);

  int get size => _store.length;
}
