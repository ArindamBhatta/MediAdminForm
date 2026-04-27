import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/src/core/contracts/plugin_descriptor.dart';
import 'package:web_ui_plugins/src/core/permissions/permission_middleware.dart';
import 'package:web_ui_plugins/src/core/registry/plugin_registry.dart';
import 'package:web_ui_plugins/src/core/widgets/custom_snack_bar.dart';
import 'package:web_ui_plugins/src/core/widgets/globals.dart';

class PluginLeftNavigation extends StatelessWidget {
  final double width;
  final bool warnOnUnsavedChanges;
  final VoidCallback? onItemTap;

  const PluginLeftNavigation({
    super.key,
    this.width = 240,
    this.warnOnUnsavedChanges = true,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = PluginRegistry.instance.all.where((plugin) {
      return PermissionMiddleware.instance.isPluginVisible(
        plugin.descriptor.moduleId,
      );
    }).toList();

    final currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;

    return Container(
      width: width,
      color: Theme.of(context).colorScheme.primaryFixed,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          height: 12,
        ),
        itemBuilder: (context, index) {
          final descriptor = items[index].descriptor;
          final primaryRoute = descriptor.routes.firstOrNull;
          if (primaryRoute == null) {
            return const SizedBox.shrink();
          }

          final isSelected = _matchesRoute(currentPath, descriptor.routes);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (warnOnUnsavedChanges &&
                    currentPath != primaryRoute.path &&
                    Globals.hasUnsavedFormChanges) {
                  CustomSnackBar.show(
                    context,
                    'You lost some unsaved changes by navigating out of this page.',
                    category: SnackBarCategory.warning,
                  );
                  Globals.hasUnsavedFormChanges = false;
                }

                context.go(primaryRoute.path);
                onItemTap?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? descriptor.color.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(descriptor.icon, color: descriptor.color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        descriptor.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _matchesRoute(
    String currentPath,
    List<PluginRouteDescriptor> routes,
  ) {
    for (final route in routes) {
      final path = route.path;
      if (currentPath == path) {
        return true;
      }
      if (path != '/' && currentPath.startsWith('$path/')) {
        return true;
      }
    }
    return false;
  }
}