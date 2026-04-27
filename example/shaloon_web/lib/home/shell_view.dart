import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

import '../domain/models/staff_model.dart';
import '../domain/models/client_model.dart';
import '../features/staff/staff_plugin.dart';
import '../features/clients/client_plugin.dart';

/// Sidebar item entry derived from the plugin registry.
class _SidebarEntry {
  final String moduleId;
  final String label;
  final IconData icon;
  final Color color;
  final WidgetBuilder pageBuilder;

  const _SidebarEntry({
    required this.moduleId,
    required this.label,
    required this.icon,
    required this.color,
    required this.pageBuilder,
  });
}

/// App shell — generated from the plugin registry.
/// The sidebar and routes are never hard-coded here; they come from registered plugins.
class ShaloonShell extends StatefulWidget {
  const ShaloonShell({super.key});

  @override
  State<ShaloonShell> createState() => _ShaloonShellState();
}

class _ShaloonShellState extends State<ShaloonShell> {
  int _selectedIndex = 0;

  List<_SidebarEntry> _buildEntries() {
    final user = PermissionMiddleware.instance.currentUser;
    final plugins = user != null
        ? PluginRegistry.instance.visibleTo(user)
        : PluginRegistry.instance.all;

    return plugins.map((p) {
      final firstRoute = p.descriptor.routes.isNotEmpty
          ? p.descriptor.routes.first
          : null;
      return _SidebarEntry(
        moduleId: p.descriptor.moduleId,
        label: p.descriptor.title,
        icon: p.descriptor.icon,
        color: p.descriptor.color,
        pageBuilder: firstRoute?.builder ?? (_) => const SizedBox.shrink(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    if (entries.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No plugins registered.')),
      );
    }
    final current = entries[_selectedIndex.clamp(0, entries.length - 1)];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            destinations: entries
                .map(
                  (e) => NavigationRailDestination(
                    icon: Icon(e.icon, color: e.color),
                    label: Text(e.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          // Main content area
          Expanded(child: current.pageBuilder(context)),
        ],
      ),
    );
  }
}
