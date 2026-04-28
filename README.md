# web_ui_plugins

**Plug-and-play SaaS Admin UI Framework for Flutter Web**

## Overview

`web_ui_plugins` is a modular, plugin-driven framework for building admin panels, dashboards, and SaaS back offices in Flutter Web. It provides:
- **Plugin registry:** Add/remove features as plugins (e.g., Clients, Staff, Billing)
- **Scaffolded CRUD:** Rapidly create forms, lists, and detail views for any data model
- **Firebase-first:** Realtime Firestore integration, authentication, and storage
- **Permissions:** Role-based access and visibility policies
- **Responsive UI:** Works on desktop and mobile

## Screenshots

Here are some example screenshots to help you understand what you can build with this framework:

| UI Example |  |
|---|---|
| <img src="docs/assets/images/Screenshot_1.png" width="900"/> |
| <img src="docs/assets/images/Screenshot_2.png" width="900"/> |
| <img src="docs/assets/images/Screenshot_3.png" width="900"/> | 
| <img src="docs/assets/images/Screenshot_4.png" width="900"/> | 
| <img src="docs/assets/images/Screenshot_5.png" width="900"/> | 

## Features

- 🧩 **Plugin architecture:** Each module is a self-contained plugin
- ⚡ **Zero-boilerplate CRUD:** Define a model, get forms and lists for free
- 🔒 **Permission middleware:** Control access by persona/role
- 🔄 **Realtime updates:** Firestore streams power the UI
- 🧑‍💻 **Developer experience:** Minimal code to add new sections

## Quick Start

1. **Add to your `pubspec.yaml`:**
   ```yaml
   dependencies:
     web_ui_plugins:
       path: ../web_ui_plugins
   ```

2. **Define a data model:**
   ```dart
   class ClientModel extends DataModel {
     String? id, name, email;
     // ...
     ClientModel.fromJson(Map<String, dynamic> json) { ... }
     @override Map<String, dynamic> toJson() => { ... };
     @override String? get uid => id;
   }
   ```

3. **Register a plugin:**
   ```dart
   final clientPlugin = PluginDescriptor<ClientModel>(
     moduleId: 'clients',
     title: 'Clients',
     icon: Icons.people,
     color: Colors.green,
     dataBinding: PluginDataBinding<ClientModel>(
       collectionName: 'clients',
       fromJson: ClientModel.fromJson,
       createEmpty: ClientModel.new,
     ),
     routes: [ ... ],
   );
   ```

4. **Bootstrap your app:**
   ```dart
   await AppBootstrap.initialize(config: BootstrapConfig(...));
   await AppBootstrap.registerPlugins([clientPlugin, ...]);
   runApp(AppBootstrap.buildRouterApp(...));
   ```

## Example

See [`example/shalloon_web`](example/shalloon_web) for a full working app with Staff and Clients modules.

## Architecture

- **PluginRegistry:** Central list of all plugins (modules)
- **ScopedRepo:** Data access layer, scoped by module and model
- **SectionWidget:** Handles list/detail UI, dialogs, and state
- **FormPageView:** Declarative form rendering
- **PermissionMiddleware:** Persona/role-based access control

## Roadmap

- [ ] More declarative form layouts
- [ ] Improved onboarding and docs
- [ ] More backend adapters (Supabase, REST)
- [ ] UI theming and customization

## License

MIT
