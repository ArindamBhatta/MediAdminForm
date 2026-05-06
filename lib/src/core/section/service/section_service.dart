// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
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
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] ??= doc.id;
        return _fromJson(data);
      }).toList();
      // emitData function called the list of T through the stream.
      emitData(items);
    });
  }

  //It is (key-based singleton)
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
      // Use Firestore's auto-generated doc ID instead of manual sequential IDs
      final docRef = _firestore.collection(_collectionName).doc();
      data['id'] ??= docRef.id;
      await docRef.set(data);
      return docRef.id;
    } catch (error) {
      throw Exception('Failed to create item: $error');
    }
  }

  //read all items from Firestore collection, convert them to T using _fromJson, and return the list of T.
  @override
  Future<List<T>> readAll() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();

      final item = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] ??= doc.id;
        return _fromJson(data);
      }).toList();
      return item;
    } catch (error) {
      throw Exception('Failed to read items: $error');
    }
  }

  @override
  Future<T> update(T updateItem) async {
    try {
      final dynamic item = updateItem;
      final id = item.id ?? item.uid;
      if (id == null || id.isEmpty) {
        throw Exception("Item id can't be null for Update operation");
      }

      // Use Firestore doc ID directly instead of searching by 'id' field
      final data = updateItem.toJson();
      await _firestore.collection(_collectionName).doc(id).update(data);
      return updateItem;
    } catch (error) {
      print('Update error for $_collectionName: $error');
      throw Exception('Failed to update item: $error');
    }
  }

  @override
  Future<T> delete(T item) async {
    try {
      final dynamic deletableItem = item;
      final id = deletableItem.id ?? deletableItem.uid;
      if (id == null || id.isEmpty) {
        throw Exception("Item id can't be null for Delete operation");
      }

      // Use Firestore doc ID directly instead of searching by 'id' field
      await _firestore.collection(_collectionName).doc(id).delete();
      return item;
    } catch (error) {
      print('Delete error for $_collectionName: $error');
      throw Exception('Failed to delete item: $error');
    }
  }
}
