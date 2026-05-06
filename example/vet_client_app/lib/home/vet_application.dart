import 'package:flutter/material.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

/// App shell — generated from the plugin registry.
/// The sidebar and routes are never hard-coded here; they come from registered plugins.
class VetApplication extends StatelessWidget {
  final Widget child;

  const VetApplication({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              const PluginLeftNavigation(
                title: 'Vet Application',
                width: 280,
                collapsedWidth: 56,
                initiallyCollapsed: false,
                showCollapseToggle: true,
                showHeader: true,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
