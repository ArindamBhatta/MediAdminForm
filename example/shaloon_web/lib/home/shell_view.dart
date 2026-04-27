import 'package:flutter/material.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

/// App shell — generated from the plugin registry.
/// The sidebar and routes are never hard-coded here; they come from registered plugins.
class ShalloonShell extends StatelessWidget {
  final Widget child;

  const ShalloonShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const PluginLeftNavigation(),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
