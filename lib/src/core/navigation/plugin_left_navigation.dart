import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ui_plugins/web_ui_plugins.dart';

class PluginLeftNavigation extends StatefulWidget {
  final String? title;
  final double width;
  final double collapsedWidth;
  final bool initiallyCollapsed;
  final bool showCollapseToggle;
  final bool showHeader;
  final bool warnOnUnsavedChanges;
  final VoidCallback? onItemTap;
  final Widget Function(BuildContext context, bool collapsed)? footerBuilder;
  final ValueChanged<bool>? onCollapseChanged;

  const PluginLeftNavigation({
    super.key,
    this.title,
    this.width = 240,
    this.collapsedWidth = 56,
    this.initiallyCollapsed = false,
    this.showCollapseToggle = true,
    this.showHeader = true,
    this.warnOnUnsavedChanges = true,
    this.onItemTap,
    this.footerBuilder,
    this.onCollapseChanged,
  });

  @override
  State<PluginLeftNavigation> createState() => _PluginLeftNavigationState();
}

class _PluginLeftNavigationState extends State<PluginLeftNavigation> {
  static const Duration _animDuration = Duration(milliseconds: 260);
  static const Curve _animCurve = Curves.easeInOutCubic;

  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  void _toggleCollapse() {
    setState(() {
      _collapsed = !_collapsed;
    });
    widget.onCollapseChanged?.call(_collapsed);
  }

  Widget _buildHeader(BuildContext context) {
    final toggleButton = Tooltip(
      message: _collapsed ? 'Expand sidebar' : 'Collapse sidebar',
      child: IconButton(
        onPressed: _toggleCollapse,
        icon: Icon(
          _collapsed ? Icons.menu_open : Icons.menu,
          color: Theme.of(context).colorScheme.onPrimaryFixed,
          size: 20,
        ),
      ),
    );

    return SizedBox(
      height: Globals.topBarHeight,
      child: Container(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        child: _collapsed
            ? Center(child: toggleButton)
            : Row(
                children: [
                  if ((widget.title ?? '').trim().isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          widget.title!,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  toggleButton,
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = PluginRegistry.instance.all.where((plugin) {
      return PermissionMiddleware.instance.isPluginVisible(
        plugin.descriptor.moduleId,
      );
    }).toList();

    final currentPath = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;

    final navWidth = _collapsed ? widget.collapsedWidth : widget.width;

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      width: navWidth,
      color: Theme.of(context).colorScheme.primaryFixed,
      child: Column(
        children: [
          if (widget.showHeader && widget.showCollapseToggle)
            _buildHeader(context),
          Expanded(
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
                      if (widget.warnOnUnsavedChanges &&
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
                      widget.onItemTap?.call();
                    },
                    child: Tooltip(
                      message: _collapsed ? descriptor.title : '',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: _collapsed ? 10 : 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? descriptor.color.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: _collapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            Icon(
                              descriptor.icon,
                              color: descriptor.color,
                              size: 20,
                            ),
                            if (!_collapsed) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  descriptor.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelLarge?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.footerBuilder != null)
            widget.footerBuilder!(context, _collapsed),
        ],
      ),
    );
  }

  bool _matchesRoute(String currentPath, List<PluginRouteDescriptor> routes) {
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
