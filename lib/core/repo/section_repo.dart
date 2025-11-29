import 'package:form_template/core/repo/form_repo_mixin.dart';
import 'package:form_template/core/service/form_service_mixin.dart';
import 'package:form_template/models/data_model.dart';

class SectionRepo<T extends DataModel> with FormRepoMixin<T> {
  //store all instance which multi repository provider created
  static final Map<Type, SectionRepo> instances = {};

  SectionRepo._internal(FormServiceMixin<T> service) {
    initService(service);
  }

  factory SectionRepo(FormServiceMixin<T> service) {
    final type = T;
    if (!instances.containsKey(type)) {
      instances[type] = SectionRepo._internal(service);
    }
    return instances[type] as SectionRepo<T>;
  }

  T? getById(String id) {
    try {
      return items.firstWhere((item) => item.uid == id);
    } catch (_) {
      return null;
    }
  }
}
