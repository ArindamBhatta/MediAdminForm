# web_ui_plugins — Architecture

> Last updated: 28 April 2026 — reflects actual codebase state, including known issues backlog.

---

## 1. Goal

Build a plug-and-play plugin framework where an end developer onboards a new domain module with minimal work:

1. Define an entity/model class (extends `DataModel`).
2. Define enums (section, persona, status, etc.).
3. Define a view widget.
4. Register a `PluginDescriptor` in bootstrap.

Everything else — state, repo, service, routing, permissions, sidebar, CRUD, uploads — is wired by the framework.

Targets multi-module SaaS products: clinic, shalloon/salon, medical admin.

---

## 2. Product Principles

1. Core remains backend-agnostic — no Firebase imports in `lib/src/core/`.
2. Firebase is the **default adapter** (ships with the package), replaceable later.
3. One-call bootstrap for app startup.
4. Scoped registries keyed by `moduleId + modelType + collection`, not global singletons.
5. Permission checks at **two levels**: sidebar visibility and route access.
6. Upload is a first-class plugin capability, not an ad-hoc utility.
7. Incremental migration path from the old `SectionRepo`/`SectionService` pattern.

---

## 3. Package Structure (Current State)

```
lib/
├── web_ui_plugins.dart          ← public barrel export (only file consumers import)
└── src/
    ├── core/
    │   ├── contracts/           ← backend-agnostic interfaces + shared config
    │   │   ├── data_model.dart          ← DataModel base class
    │   │   ├── form_service_mixin.dart  ← CRUD interface + broadcast stream
    │   │   ├── plugin_descriptor.dart   ← PluginDescriptor, PluginDataBinding, PluginFeatureFlags
    │   │   ├── permission_contract.dart ← UserIdentity, PermissionPolicy, PersonaPermissionPolicy
    │   │   ├── upload_contract.dart     ← UploadCapability, UploadResult, UploadConfig
    │   │   ├── globals.dart             ← shared UI constants (form sizes, padding)
    │   │   └── section_service.dart     ← ⚠ legacy Firebase service (see §12 backlog #1)
    │   ├── registry/
    │   │   ├── scoped_registry.dart     ← ScopedRegistry<T> + ScopedKey (moduleId/model/collection)
    │   │   └── plugin_registry.dart     ← central plugin list, hot-reload safe
    │   ├── bootstrap/
    │   │   └── app_bootstrap.dart       ← initialize → registerPlugins → buildApp / buildRouterApp
    │   ├── permissions/
    │   │   └── permission_middleware.dart  ← PermissionMiddleware singleton + PluginGate widget
    │   ├── form/
    │   │   ├── cubit/
    │   │   │   ├── form_cubit.dart      ← FormCubit<T> (create/read/update/delete intents)
    │   │   │   └── form_state.dart      ← FormViewState sealed class (Initial/InProgress/Loaded/Success/Failure)
    │   │   ├── repo/
    │   │   │   └── form_repo_mixin.dart ← FormRepoMixin<T> (local cache + broadcast stream)
    │   │   ├── form_page.dart           ← FormPageView + WidgetConfig declarative field API
    │   │   └── widgets/                 ← GeneralFormField, FormDropdown, FormDate, FormTime, FormAge, FormMultiSelect
    │   ├── section/
    │   │   ├── cubit/
    │   │   │   ├── section_cubit.dart   ← SectionCubit<T> (search, status filter, date range, item selection)
    │   │   │   └── section_state.dart   ← SectionState<T> (items, filteredItems, selectedItem, filters)
    │   │   └── widget/
    │   │       ├── section_view.dart    ← two-pane master/detail layout
    │   │       ├── section_widget.dart  ← SectionWidget (wraps cubit + view)
    │   │       ├── sub_section_view.dart
    │   │       ├── custom_list_view.dart
    │   │       ├── custom_list_tile.dart
    │   │       └── no_data_view.dart
    │   ├── navigation/
    │   │   └── plugin_left_navigation.dart  ← sidebar driven by PluginRegistry + PermissionMiddleware
    │   ├── widgets/                     ← shared UI primitives
    │   │   ├── custom_button.dart
    │   │   ├── custom_dialog_box.dart
    │   │   ├── custom_snack_bar.dart
    │   │   ├── custom_textfield.dart
    │   │   ├── customizable_search_bar.dart
    │   │   └── package_enums.dart       ← SnackBarCategory, SuccessStatus, etc.
    │   └── functions/
    │       └── date_time_utils.dart     ← date formatting helpers
    ├── adapters/
    │   └── firebase/                    ← official default adapter
    │       ├── firestore_service.dart   ← FirestoreService<T> (CRUD + realtime listener + Cloud Fn IDs)
    │       └── scoped_repo.dart         ← ScopedRepo<T> (replaces SectionRepo)
    └── compat/
        └── compat.dart                  ← migration shims for old SectionRepo/SectionService code

example/
└── shalloon_web/                  ← reference consumer app
    ├── pubspec.yaml               ← depends on web_ui_plugins via path
    └── lib/
        ├── main.dart              ← 3-step bootstrap entry point
        ├── app/
        │   └── bootstrap.dart     ← ShalloonBootstrap.run()
        ├── domain/
        │   ├── enums/             ← ShalloonSection, ShalloonPersona, AppointmentStatus
        │   └── models/            ← StaffModel, ClientModel (only thing devs write)
        ├── features/
        │   ├── staff/             ← staffPlugin descriptor + StaffDetailView
        │   └── clients/           ← clientPlugin descriptor + ClientDetailView
        └── home/
            └── shell_view.dart    ← ShalloonShell — sidebar generated from registry
```

---

## 4. Developer Experience (What the End Developer Writes)

For a new module, a developer writes only:

```
1. A model class   →  extends DataModel, implements toJson/fromJson
2. Enums           →  section label, icon, color, persona, status
3. A detail view   →  FormPageView with WidgetConfig fields
4. A plugin file   →  PluginDescriptor registered in bootstrap
```

The framework provides everything else automatically:
- Real-time Firestore listener
- CRUD (create via Cloud Function ID, update, delete)
- List pane with search + status filter + date range filter
- Add dialog with form validation and dirty-state tracking
- Mobile/desktop responsive layout
- Sidebar entry and route registration (go_router)
- Permission gating at sidebar and route level
- Upload capability (declared in `PluginFeatureFlags`)

---

## 5. Core Contracts

### 5.1 DataModel
```dart
abstract class DataModel extends Equatable {
  String? get uid;    // ⚠ typed nullable but semantically required (see §12 backlog #2)
  String? get title;
  String? get subTitle;
  Map<String, dynamic> toJson();
}
```

### 5.2 FormServiceMixin
Pure Dart interface for CRUD + a broadcast stream. No Firebase dependency.
```dart
mixin FormServiceMixin<T> {
  Stream<List<T>> get dataStream;
  void emitData(List<T> data);
  Future<String> create(T item);
  Future<List<T>> readAll();
  Future<T> update(T item);
  Future<T> delete(T item);
  void dispose();
}
```

### 5.3 PluginDescriptor
```dart
PluginDescriptor<StaffModel>(
  moduleId: 'staff',
  title: 'Staff',
  icon: Icons.badge_outlined,
  color: Colors.blue,
  order: 0,
  features: PluginFeatureFlags(supportsUpload: true),
  visibilityPolicy: PersonaPermissionPolicy({'admin', 'manager'}),
  dataBinding: PluginDataBinding<StaffModel>(
    collectionName: 'staff',
    fromJson: StaffModel.fromJson,
    createEmpty: StaffModel.empty,
  ),
  routes: [
    PluginRouteDescriptor(path: '/staff', builder: (_, __) => StaffSectionPage()),
  ],
)
```

### 5.4 PermissionPolicy (two-layer)
- **Visibility policy** — is this plugin shown in the sidebar?
- **Route access policy** — can the user navigate to this route?

Built-in implementations:
- `OpenPermissionPolicy` — grants all (development / no-auth apps only)
- `PersonaPermissionPolicy({'admin', 'manager'})` — restrict by string role

`PermissionMiddleware.instance.setUser(user)` must be called after login / on auth state change. `clearUser()` on logout.

### 5.5 UploadCapability
Abstract contract; Firebase Storage implementation to be added in `adapters/firebase/`.
```dart
abstract class UploadCapability {
  Future<UploadResult> upload(UploadConfig config);
  Future<void> delete(String storagePath);
  Future<UploadResult> replace(String oldPath, UploadConfig config);
}
```
Passed to `BootstrapConfig.uploadCapability`. Not yet auto-injected into plugin cubits (see §12 backlog #3).

---

## 6. Registry Design

### Problem with old pattern
- `SectionRepo` keyed only by `Type` → collisions when two modules share a model type.
- `SectionService` keyed by `"collection-Type"` string → global, no module isolation.

### New pattern: ScopedKey
```
ScopedKey = moduleId / modelType / collection / scopeId
```
Examples:
- `staff/StaffModel/staff/default`
- `clients/ClientModel/clients/default`

`ScopedRegistry<T>` stores one instance per `ScopedKey`. Both `FirestoreService` and `ScopedRepo` use it. No cross-module leakage.

---

## 7. Runtime Data Flow

```
User action in View
  └─► FormCubit.createItem / updateItem / deleteItem  (intent layer)
        └─► ScopedRepo.create / update / delete        (cache + stream)
              └─► FirestoreService.create / update / delete  (Firebase adapter)
                    └─► Firestore write

Firestore realtime snapshot
  └─► FirestoreService snapshot listener
        └─► FormServiceMixin.emitData(items)
              └─► FormRepoMixin.dataStream (broadcast)
                    └─► SectionCubit._listenToRepo()
                          └─► _applyFilters(search, status, dateRange)
                                └─► SectionState emitted
                                      └─► SectionWidget / SectionView rebuild
```

Sequential IDs for new records come from the `getNextCategoryId` Cloud Function (not client-generated).

---

## 8. Bootstrap API

```dart
// main.dart — the only file that changes between apps

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Firebase init + framework config
  await AppBootstrap.initialize(
    config: BootstrapConfig(
      initializeFirebase: () async {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      },
      defaultPermissionPolicy: OpenPermissionPolicy(),
    ),
  );

  // Step 2: Register feature plugins
  await AppBootstrap.registerPlugins([staffPlugin, clientPlugin]);

  // Step 3: Build root widget (providers + cubits + router injected automatically)
  runApp(
    AppBootstrap.buildRouterApp(
      title: 'Shalloon',
      shellBuilder: (context, child) => ShalloonShell(child: child),
    ),
  );
}
```

`buildApp` / `buildRouterApp` automatically:
- Creates `RepositoryProvider<ScopedRepo>` for every registered plugin.
- Creates `BlocProvider<FormCubit>` for every registered plugin (⚠ see §12 backlog #4).
- Wraps the shell in `MaterialApp` / `MaterialApp.router`.
- Registers plugin routes under a `ShellRoute` with permission redirect guards.

---

## 9. State Layer Detail

### FormCubit
Handles form-level intents. Emits `FormInProgress → FormSuccess | FormFailure`.

| Method | Triggers |
|---|---|
| `createItem(T)` | `FormOperation.create` |
| `readItems()` | `FormOperation.read` → `FormLoaded` |
| `updateItem(index, T)` | `FormOperation.update` ⚠ index-based (see §12 backlog #5) |
| `deleteItem(T)` | `FormOperation.delete` |

### SectionCubit
Handles list-view state: full item list, filtered view, selection, search, status filters, date range.

| Method | Effect |
|---|---|
| `loadAll()` | Force-fetches from service, reapplies filters |
| `search(text)` | Filters by title/subTitle |
| `setStatusFilter(Set<String>)` | Filters by status key |
| `setDateRange(from, to)` | Filters by date field |
| `selectItem(T?)` | Updates `selectedItem` |
| `clearFilters()` | Resets all filters + selection |

`SectionCubit` receives a `formCubit` in its constructor but does not use it internally — coordination happens at the widget layer (⚠ see §12 backlog #7).

---

## 10. Migration Strategy (Incremental)

| Phase | Action | Status |
|---|---|---|
| 1 | Import `compat.dart`; old code compiles via `createSectionRepo()` typedef | Available |
| 2 | Move Firebase calls to `FirestoreService` | Done |
| 3 | Replace manual `MultiRepositoryProvider` wiring with `AppBootstrap` | Done |
| 4 | Add `PluginDescriptor` per module; sidebar + routes auto-generate | Done |
| 5 | Add `PermissionPolicy` per plugin | Done |
| 6 | Declare `supportsUpload: true`; pass `UploadCapability` to bootstrap | Partial (contract exists, adapter not wired) |
| 7 | Remove `compat.dart` import when all modules are migrated | Pending |

---

## 11. Decisions

| Decision | Choice | Reason |
|---|---|---|
| Backend | Firebase (default adapter) | Near-zero config for current apps |
| State | flutter_bloc Cubit | Already in use; predictable, testable |
| Form | WidgetConfig declarative fields | Keeps feature view code minimal |
| Registry key | moduleId + modelType + collection | Prevents cross-module collision |
| Permission | Two-layer (visibility + route) | Sidebar UX + deep-link security |
| Upload | Formal `UploadCapability` contract | First-class, not ad-hoc |
| Compat | Typedef + factory shim | No private constructor access needed |
| Routing | go_router `ShellRoute` | Browser URL, deep-link, back/forward support |

---

## 12. Known Issues & Improvement Backlog

Issues found during architecture review (April 2026). Ordered by severity.

### #1 — `SectionService` (Firebase) lives in `contracts/` — HIGH
**File:** `lib/src/core/contracts/section_service.dart`
**Problem:** `contracts/` is supposed to be pure Dart with no backend dependencies. This file imports `cloud_firestore` and `cloud_functions`, violating principle #1.
**Fix:** Move to `lib/src/adapters/firebase/section_service.dart` and re-export via `compat.dart`.

### #2 — `DataModel.uid` typed `String?` but semantically required — MEDIUM
**File:** `lib/src/core/contracts/data_model.dart`
**Problem:** `String? get uid; // not null` — the comment contradicts the type. Every downstream lookup (`item.uid == id`) must null-check unnecessarily.
**Fix:** Change to `String get uid`. All concrete models must provide a non-null uid, surfacing missing IDs at compile time.

### #3 — `UploadCapability` stored in `BootstrapConfig` but never injected into plugins — MEDIUM
**File:** `lib/src/core/bootstrap/app_bootstrap.dart`
**Problem:** `BootstrapConfig.uploadCapability` is accepted but never passed to `FormCubit` or `PluginDescriptor`. Plugins that declare `supportsUpload: true` have no access to the capability at runtime.
**Fix:** Pass `uploadCapability` through `AppBootstrap._buildCubits` or expose it via a `RepositoryProvider<UploadCapability>`.

### #4 — All `FormCubit`s in `_buildCubits` share the first `ScopedRepo` — HIGH (bug)
**File:** `lib/src/core/bootstrap/app_bootstrap.dart`
```dart
create: (_) => FormCubit(repo: RepositoryProvider.of<ScopedRepo>(context)),
```
**Problem:** `RepositoryProvider.of<ScopedRepo>` resolves untyped and returns the first `ScopedRepo` in the tree for every plugin. Every `FormCubit` ends up pointing at the same repository.
**Fix:** Look up each plugin's repo by `moduleId` using a typed provider key or a registry lookup inside the `create` closure.

### #5 — `FormRepoMixin.update` and `FormCubit.updateItem` expose an index — MEDIUM
**Files:** `form_repo_mixin.dart`, `form_cubit.dart`
**Problem:** `update(int index, T item)` — callers must track a list position. The underlying service finds items by `id`, not index; the index only updates the local cache.
**Fix:** Change signature to `update(T item)` and find the cache index internally via `items.indexWhere((e) => e.uid == item.uid)`.

### #6 — `ScopedRepo` uses `(service as dynamic).collectionName` — MEDIUM
**File:** `lib/src/adapters/firebase/scoped_repo.dart`
**Problem:** Dynamic cast to read `collectionName` silently falls back to `T.toString()` if the cast fails, producing a wrong registry key.
**Fix:** Define `abstract interface CollectionNamed { String get collectionName; }`, implement it on `FirestoreService`, and cast to `CollectionNamed` instead of `dynamic`.

### #7 — `SectionCubit` holds an unused `FormCubit` reference — LOW
**File:** `lib/src/core/section/cubit/section_cubit.dart`
**Problem:** `final FormCubit<T> formCubit` is stored but never called inside `SectionCubit`. This creates artificial coupling between two independent cubits.
**Fix:** Remove `formCubit` from `SectionCubit`'s constructor. Coordinate them at the widget layer (e.g., `SectionView` owns both).

### #8 — No `onError` handler on realtime stream subscriptions — MEDIUM
**Files:** `section_cubit.dart`, `form_repo_mixin.dart`
**Problem:** `_repoStream.listen((data) { ... })` has no `onError` callback. A Firestore permission error or network failure silently cancels the subscription with no state update.
**Fix:** Add `onError: (error) => emit(state.copyWith(status: SuccessStatus.failure))` (and equivalent in `FormRepoMixin`).

### #9 — `SectionState.addedItemId` skips the sentinel pattern in `copyWith` — LOW
**File:** `lib/src/core/section/cubit/section_state.dart`
**Problem:** Every call to `copyWith(searchText: 'x')` silently resets `addedItemId` to `null` because it does not fall back to `this.addedItemId`.
**Fix:** Apply the same `static const Object _unset` sentinel pattern used by `selectedItem` and `fromDate`.

### #10 — `Globals.hasUnsavedFormChanges` is a mutable global static — MEDIUM
**File:** `lib/src/core/contracts/globals.dart`
**Problem:** `FormPageView` writes this flag and `PluginLeftNavigation` reads it, but nothing reacts to changes — no stream, no notifier. The flag can also become stale between page navigations.
**Fix:** Move `hasUnsavedChanges` into `FormCubit`'s state (or a `ValueNotifier`). Navigation widgets subscribe to it reactively instead of polling a global.

---

## 13. Verification Checklist

- [ ] One-call init boots all registered plugins.
- [ ] Sidebar is generated from registry (no hard-coded nav items).
- [ ] Sidebar respects permission policies.
- [ ] Deep-link `/staff` resolves to correct plugin page.
- [ ] Browser back/forward maintains route state.
- [ ] CRUD (create, read, update, delete) works through adapter.
- [ ] Sequential IDs come from Cloud Function (not client-generated).
- [ ] Upload works with correct metadata and retrieval path.
- [ ] No duplicate Firestore listeners after hot reload or navigation.
- [ ] Emulator-backed integration suite is green.
- [ ] Two modules with same model type but different collections don't collide.
- [ ] Each `FormCubit` is wired to its own plugin's `ScopedRepo` (backlog #4).
- [ ] Firestore listener errors surface as `SuccessStatus.failure` in `SectionState` (backlog #8).
