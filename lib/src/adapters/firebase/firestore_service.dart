import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:web_ui_plugins/src/core/contracts/data_model.dart';
import 'package:web_ui_plugins/src/core/contracts/form_service_mixin.dart';
import 'package:web_ui_plugins/src/core/registry/scoped_registry.dart';

typedef ModelFromJson<T> = T Function(Map<String, dynamic>);

/// Firebase Firestore implementation of [FormServiceMixin].
///
/// Key change from old SectionService:
/// - Instances are keyed by [ScopedKey] (moduleId + modelType + collection)
///   instead of the old global "collection-Type" string, preventing
///   cross-module singleton collisions.
class FirestoreService<T extends DataModel> with FormServiceMixin<T> {
  static final ScopedRegistry<FirestoreService> _registry =
      ScopedRegistry<FirestoreService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName;
  final ModelFromJson<T> _fromJson;
  final String moduleId;

  /// Exposed so ScopedRepo can derive the registry key without reflection.
  String get collectionName => _collectionName;

  FirestoreService._internal({
    required this.moduleId,
    required String collectionName,
    required ModelFromJson<T> fromJson,
  })  : _collectionName = collectionName,
        _fromJson = fromJson {
    _firestore.collection(_collectionName).snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final items = snapshot.docs.map((doc) => _fromJson(doc.data())).toList();
        emitData(items);
      },
    );
  }

  /// Scoped factory: one instance per (moduleId, T, collectionName) triple.
  factory FirestoreService({
    required String moduleId,
    required String collectionName,
    required ModelFromJson<T> fromJson,
  }) {
    final key = ScopedKey(
      moduleId: moduleId,
      modelType: T.toString(),
      collection: collectionName,
    );
    return _registry.getOrCreate(
      key,
      () => FirestoreService<T>._internal(
        moduleId: moduleId,
        collectionName: collectionName,
        fromJson: fromJson,
      ),
    ) as FirestoreService<T>;
  }

  @override
  Future<String> create(T newItem) async {
    try {
      final data = newItem.toJson();
      final nextId = await _getNextId(_collectionName);
      data['id'] = nextId.toString();
      await _firestore.collection(_collectionName).add(data);
      return data['id'] as String;
    } catch (error) {
      throw Exception('Failed to create item: $error');
    }
  }

  @override
  Future<List<T>> readAll() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) => _fromJson(doc.data())).toList();
    } catch (error) {
      throw Exception('Failed to read items: $error');
    }
  }

  @override
  Future<T> update(T updateItem) async {
    try {
      final id = (updateItem as dynamic).id as String?;
      if (id == null || id.isEmpty) {
        throw Exception("Item id can't be null for Update");
      }
      final query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isEmpty) throw Exception('No item found with id $id');
      await _firestore
          .collection(_collectionName)
          .doc(query.docs.first.id)
          .update(updateItem.toJson());
      return updateItem;
    } catch (error) {
      throw Exception('Failed to update item: $error');
    }
  }

  @override
  Future<T> delete(T item) async {
    try {
      final id = (item as dynamic).id as String?;
      if (id == null || id.isEmpty) {
        throw Exception("Item id can't be null for Delete");
      }
      final query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isEmpty) throw Exception('No item found with id $id');
      await _firestore
          .collection(_collectionName)
          .doc(query.docs.first.id)
          .delete();
      return item;
    } catch (error) {
      throw Exception('Failed to delete item: $error');
    }
  }

  /// Cloud Function-based sequential ID. Preserves original business behavior.
  Future<int> _getNextId(String category) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getNextCategoryId')
          .call(<String, dynamic>{'category': category});
      return result.data['nextId'] as int;
    } on Exception catch (error) {
      throw Exception('Failed to fetch next ID: $error');
    }
  }
}
