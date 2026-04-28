import 'package:flutter/material.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

/// App shell — generated from the plugin registry.
/// The sidebar and routes are never hard-coded here; they come from registered plugins.
class ShalloonApplication extends StatelessWidget {
  final Widget child;

  const ShalloonApplication({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
              title: const Text('Shalloon'),
            ),
            drawer: Drawer(
              child: PluginLeftNavigation(
                width: 280,
                showHeader: false,
                showCollapseToggle: false,
                onItemTap: () => Navigator.of(context).pop(),
              ),
            ),
            body: child,
          );
        }

        return Scaffold(
          body: Row(
            children: [
              const PluginLeftNavigation(
                title: 'Shalloon',
                width: 260,
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
