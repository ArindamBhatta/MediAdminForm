# web_ui_plugins — Architecture

## 1. Goal

Build a plug-and-play plugin framework where an end developer onboards a new domain module with minimal work:

1. Define an entity/model class (extends `DataModel`).
2. Define enums (section, persona, status, etc.).
3. Define a view widget.
4. Register a `PluginDescriptor` in bootstrap.

Everything else — state, repo, service, routing, permissions, sidebar, CRUD, uploads — is wired by the framework.

Targets multi-module SaaS products: clinic, shaloon/salon, medical admin.

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

## 3. Package Structure

```
lib/
├── web_ui_plugins.dart          ← public barrel export (only file consumers import)
└── src/
    ├── core/
    │   ├── contracts/           ← backend-agnostic interfaces
    │   │   ├── data_model.dart
    │   │   ├── form_service_mixin.dart
    │   │   ├── plugin_descriptor.dart
    │   │   ├── permission_contract.dart
    │   │   └── upload_contract.dart
    │   ├── registry/
    │   │   ├── scoped_registry.dart   ← replaces global Type-keyed singleton maps
    │   │   └── plugin_registry.dart   ← central plugin list, hot-reload safe
    │   ├── bootstrap/
    │   │   └── app_bootstrap.dart     ← one-call initialize → register → buildApp
    │   ├── permissions/
    │   │   └── permission_middleware.dart  ← PermissionMiddleware + PluginGate widget
    │   ├── form/
    │   │   ├── cubit/             ← FormCubit + FormViewState
    │   │   ├── repo/              ← FormRepoMixin
    │   │   ├── form_page.dart     ← FormPageView + WidgetConfig
    │   │   └── widgets/           ← field widgets (text, dropdown, date, …)
    │   ├── section/
    │   │   ├── cubit/             ← SectionCubit + SectionState
    │   │   └── widget/            ← SectionWidget, SectionView, SubSectionView, …
    │   ├── widgets/               ← shared UI primitives
    │   └── functions/             ← date/time utilities
    ├── adapters/
    │   └── firebase/              ← official default adapter
    │       ├── firestore_service.dart  ← FirestoreService (CRUD + realtime + Cloud Fn IDs)
    │       └── scoped_repo.dart        ← ScopedRepo (replaces SectionRepo)
    └── compat/
        └── compat.dart            ← migration shims for old SectionRepo/SectionService usage

example/
└── shaloon_web/                  ← reference consumer app
    ├── pubspec.yaml              ← depends on web_ui_plugins via path
    └── lib/
        ├── main.dart             ← 3-line bootstrap entry point
        ├── app/
        │   └── bootstrap.dart    ← ShaloonBootstrap.run()
        ├── domain/
        │   ├── enums/            ← ShaloonSection, ShaloonPersona, AppointmentStatus
        │   └── models/           ← StaffModel, ClientModel (only thing devs write)
        ├── features/
        │   ├── staff/            ← staffPlugin descriptor + StaffDetailView
        │   └── clients/          ← clientPlugin descriptor + ClientDetailView
        └── home/
            └── shell_view.dart   ← ShaloonShell — sidebar generated from registry
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
- List pane with search + filter
- Add dialog with form validation
- Mobile/desktop responsive layout
- Sidebar entry and route registration
- Permission gating at sidebar and route level
- Upload capability (declared in PluginFeatureFlags)

---

## 5. Core Contracts

### 5.1 DataModel
```dart
abstract class DataModel extends Equatable {
  String? get uid;
  String? get title;
  String? get subTitle;
  Map<String, dynamic> toJson();
}
```

### 5.2 PluginDescriptor
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
    PluginRouteDescriptor(path: '/staff', builder: (_) => StaffSectionPage()),
  ],
)
```

### 5.3 PermissionPolicy (two-layer)
- **Visibility policy** — is this plugin shown in the sidebar?
- **Route access policy** — can the user navigate to the route?

Built-in implementations:
- `OpenPermissionPolicy` — grants all (development only)
- `PersonaPermissionPolicy({'admin', 'manager'})` — restrict by role

### 5.4 UploadCapability
Abstract contract; Firebase Storage implementation to be added in `adapters/firebase/`.
```dart
abstract class UploadCapability {
  Future<UploadResult> upload(UploadConfig config);
  Future<void> delete(String storagePath);
  Future<UploadResult> replace(String oldPath, UploadConfig config);
}
```

---

## 6. Registry Design (Replaces Global Singletons)

### Problem with old pattern
- `SectionRepo` keyed only by `Type` → collisions when two modules share a model type.
- `SectionService` keyed by `"collection-Type"` → global, no module isolation.

### New pattern: ScopedKey
```
ScopedKey = moduleId / modelType / collection / scopeId
```
Examples:
- `staff/StaffModel/staff/default`
- `clients/ClientModel/clients/default`

`ScopedRegistry<T>` stores one instance per key. `FirestoreService` and `ScopedRepo` both use it. No cross-module leakage.

---

## 7. Runtime Data Flow

```
View action
  → FormCubit (intent)
    → ScopedRepo (cache + stream)
      → FirestoreService (Firebase adapter)
        → Firestore snapshot listener (realtime)
          → FirestoreService.emitData()
            → FormRepoMixin stream
              → SectionCubit (filter/search/select state)
                → SectionWidget (list + detail UI rebuild)
```

Create/update/delete also go through `ScopedRepo → FirestoreService`, with sequential IDs from the `getNextCategoryId` Cloud Function.

---

## 8. Bootstrap API

```dart
// main.dart — the only file that changes between apps

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppBootstrap.initialize(
    config: BootstrapConfig(
      initializeFirebase: () async {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        // optional emulator setup
      },
    ),
  );

  await AppBootstrap.registerPlugins([staffPlugin, clientPlugin]);

  runApp(AppBootstrap.buildApp(title: 'Shaloon', shell: ShaloonShell()));
}
```

`AppBootstrap.buildApp` automatically:
- Creates `RepositoryProvider<ScopedRepo<T>>` for every registered plugin.
- Creates `BlocProvider<FormCubit<T>>` for every registered plugin.
- Wraps the shell in `MaterialApp`.

---

## 9. Migration Strategy (Incremental)

| Phase | Action |
|---|---|
| 1 | Import `compat.dart`; use `createSectionRepo()` + `SectionService` typedef — old code compiles |
| 2 | Move Firebase-specific service calls to `FirestoreService` (already done) |
| 3 | Replace manual `MultiRepositoryProvider` wiring in `main.dart` with `AppBootstrap` |
| 4 | Add `PluginDescriptor` per module; sidebar and routes auto-generate |
| 5 | Add `PermissionPolicy` per plugin; sidebar and routes gated correctly |
| 6 | Declare `supportsUpload: true` and pass `UploadCapability` to bootstrap |
| 7 | Remove `compat.dart` import when all modules are migrated |

---

## 10. Decisions

| Decision | Choice | Reason |
|---|---|---|
| Backend | Firebase (default adapter) | Near-zero config for current apps |
| State | flutter_bloc Cubit | Already in use; predictable, testable |
| Form | WidgetConfig declarative fields | Keeps view code minimal |
| Registry key | moduleId + model + collection | Prevents cross-module collision |
| Permission | Two-layer (visibility + route) | Sidebar UX + deep-link security |
| Upload | Formal UploadCapability contract | First-class, not ad-hoc |
| Compat | Typedef + factory function | No private constructor access needed |

---

## 11. Verification Checklist

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
