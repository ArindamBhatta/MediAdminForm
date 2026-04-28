import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

///Service convert JSON → generic model
typedef ModelFromJson<T> = T Function(Map<String, dynamic>);

/// T can be anything… BUT it MUST be a DataModel
class SectionService<T extends DataModel> with FormServiceMixin<T> {
  /// cache all instance
  static final Map<String, SectionService> _instances = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName;
  final ModelFromJson<T> _fromJson;

  ///Name Constructor, private constructor for singleton pattern, listens to Firestore collection changes and emits data through the stream.
  SectionService._internal(this._collectionName, this._fromJson) {
    _firestore.collection(_collectionName).snapshots().listen((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      // Convert Firestore documents to T using _fromJson.
      final List<T> items = snapshot.docs.map((doc) {
        final data = doc.data();
        return _fromJson(data);
      }).toList();
      // emitData function called the list of T through the stream.
      emitData(items);
    });
  }

  //It is a Multiton (key-based singleton)
  factory SectionService(String collectionName, ModelFromJson<T> formJson) {
    // uniquely identify a service instance. SectionService<Product>('users')  → key = "users-Product"
    final String key =
        '$collectionName-${T.toString()}'; //petOwners-PetOwnerModel

    // If an instance with the same key doesn't exist, create a new one. Otherwise, return the existing instance.
    if (!_instances.containsKey(key)) {
      _instances[key] = SectionService<T>._internal(collectionName, formJson);
    }

    return _instances[key] as SectionService<T>;
  }

  /// T follows your contract T has toJson(). T has uid (used in repo).
  @override
  Future<String> create(T newItem) async {
    try {
      final Map<String, dynamic> data = newItem.toJson();

      int nextId = await getNextCategoryId(_collectionName);
      data['id'] = nextId.toString();
      await _firestore.collection(_collectionName).add(data);
      return data['id'] as String;
    } catch (error) {
      throw Exception('Failed to create item: $error');
    }
  }

  //read all items from Firestore collection, convert them to T using _fromJson, and return the list of T.
  @override
  Future<List<T>> readAll() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();

      final item = snapshot.docs.map((doc) => _fromJson(doc.data())).toList();
      return item;
    } catch (error) {
      throw Exception('Failed to read items: $error');
    }
  }

  @override
  Future<T> update(T updateItem) async {
    try {
      final id = (updateItem as dynamic).id;
      if (id == null || id.isEmpty) {
        throw Exception("Item id can't be null for Update operation");
      }

      final query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw Exception("No item found with id $id");
      }
      final fireStoreDocId = query.docs.first.id;
      final data = updateItem.toJson();
      await _firestore
          .collection(_collectionName)
          .doc(fireStoreDocId)
          .update(data);
      return updateItem;
    } catch (error) {
      throw Exception('Failed to update item: $error');
    }
  }

  @override
  Future<T> delete(T item) async {
    try {
      final id = (item as dynamic).id;
      if (id == null || id.isEmpty) {
        throw Exception("Item id can't be null for Delete operation");
      }
      final query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw Exception("No item found with id $id");
      }
      final fireStoreDocId = query.docs.first.id;
      await _firestore.collection(_collectionName).doc(fireStoreDocId).delete();
      return item;
    } catch (error) {
      throw Exception('Failed to delete item: $error');
    }
  }

  //custom ID increment system through a Cloud Function.
  Future<int> getNextCategoryId(String category) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'getNextCategoryId',
      );

      final result = await callable.call(<String, dynamic>{
        'category': category,
      });
      return result.data['nextId'] as int;
    } on Exception catch (error) {
      throw Exception('Failed to fetch next category ID: $error');
    }
  }
}
