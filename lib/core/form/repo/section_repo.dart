import 'package:web_ui_plugins/core/form/repo/form_repo_mixin.dart';
import 'package:web_ui_plugins/core/service/form_service_mixin.dart';
import 'package:web_ui_plugins/models/interface/data_model.dart';

class SectionRepo<T extends DataModel> with FormRepoMixin<T> {
  //SectionRepo uses a Type key to uniquely identify instances based only on the type.
  static final Map<Type, SectionRepo> _instances = {};

  SectionRepo._internal(FormServiceMixin<T> service) {
    initService(service);
  }

  factory SectionRepo(FormServiceMixin<T> service) {
    final Type type = T; // Get the type of T at runtime

    // If an instance for this type doesn't exist, create a new one. Otherwise, return the existing instance.
    if (!_instances.containsKey(type)) {
      _instances[type] = SectionRepo<T>._internal(service);
    }

    return _instances[type] as SectionRepo<T>;
  }

  T? getById(String id) {
    try {
      return items.firstWhere((item) => item.uid == id);
    } catch (_) {
      return null;
    }
  }
}
