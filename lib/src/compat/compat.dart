/// Compatibility layer for code still using the old SectionRepo / SectionService API.
///
/// Old:
///   `SectionRepo<PetOwnerModel>(SectionService('pets', fromJson))`
/// New (preferred):
///   `ScopedRepo<PetOwnerModel>(moduleId: 'pets', service: FirestoreService(...))`
library;

import 'package:web_ui_plugins/src/core/contracts/data_model.dart';
import 'package:web_ui_plugins/src/adapters/firebase/firestore_service.dart';
import 'package:web_ui_plugins/src/adapters/firebase/scoped_repo.dart';

/// @deprecated Use [FirestoreService] with an explicit [moduleId].
typedef SectionService<T extends DataModel> = FirestoreService<T>;

/// @deprecated Use [ScopedRepo] with an explicit [moduleId].
/// Creates a ScopedRepo under the 'default' moduleId so old call-sites compile.
ScopedRepo<T> createSectionRepo<T extends DataModel>(
  FirestoreService<T> service,
) {
  return ScopedRepo<T>(moduleId: 'default', service: service);
}
