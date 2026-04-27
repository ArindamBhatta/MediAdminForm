/// Scoped registry key: module + model type + collection + optional scope.
/// Prevents cross-module singleton collisions that the old Type-only keys caused.
class ScopedKey {
  final String moduleId;
  final String modelType;
  final String collection;
  final String scopeId;

  const ScopedKey({
    required this.moduleId,
    required this.modelType,
    required this.collection,
    this.scopeId = 'default',
  });

  String get value => '$moduleId/$modelType/$collection/$scopeId';

  @override
  bool operator ==(Object other) =>
      other is ScopedKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ScopedKey($value)';
}

/// Generic scoped registry — stores instances keyed by [ScopedKey].
/// Each module gets isolated instances: no cross-module leakage.
///
/// Usage: create one static instance per adapter class:
/// ```dart
/// static final _registry = ScopedRegistry<MyService>();
/// ```
class ScopedRegistry<T> {
  ScopedRegistry();

  final Map<ScopedKey, T> _store = {};

  /// Register or overwrite a [value] for [key].
  void register(ScopedKey key, T value) {
    _store[key] = value;
  }

  /// Retrieve an existing instance, or create and register one via [factory].
  T getOrCreate(ScopedKey key, T Function() factory) {
    return _store.putIfAbsent(key, factory);
  }

  /// Retrieve an existing instance or return null.
  T? get(ScopedKey key) => _store[key];

  /// Remove an instance (used during plugin dispose lifecycle).
  void unregister(ScopedKey key) {
    _store.remove(key);
  }

  /// Remove all instances for a given moduleId.
  void unregisterModule(String moduleId) {
    _store.removeWhere((key, _) => key.moduleId == moduleId);
  }

  bool contains(ScopedKey key) => _store.containsKey(key);

  int get size => _store.length;
}
