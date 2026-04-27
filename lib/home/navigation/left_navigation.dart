import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_ui_plugins/core/widgets/custom_snack_bar.dart';
import 'package:web_ui_plugins/core/widgets/enums.dart';
import 'package:web_ui_plugins/core/widgets/globals.dart';
import 'package:web_ui_plugins/home/navigation/navigation_cubit.dart';

class _RightTooltip extends StatefulWidget {
  final String message;
  final bool enabled;
  final Widget child;

  const _RightTooltip({
    required this.message,
    required this.enabled,
    required this.child,
  });

  @override
  State<_RightTooltip> createState() => _RightTooltipState();
}

class _RightTooltipState extends State<_RightTooltip> {
  OverlayEntry? _entry;

  void _show(Offset position) {
    if (!widget.enabled || widget.message.isEmpty) return;
    _remove();
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx + 14,
        top: position.dy - 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _show(event.position),
      onExit: (_) => _remove(),
      child: widget.child,
    );
  }
}

class LeftNavigation extends StatelessWidget {
  final Section selectedItem;
  final double width;
  final bool collapsed;
  final VoidCallback? onItemTap;

  const LeftNavigation({
    super.key,
    required this.selectedItem,
    required this.width,
    this.collapsed = false,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // During expand/collapse animation, use the current constrained width
        // to decide whether labels can safely fit.
        final bool showLabels = !collapsed && constraints.maxWidth >= 180;
        return Container(
          width: width,
          color: Theme.of(context).colorScheme.primaryFixed,
          child: getMenu(context, showLabels: showLabels),
        );
      },
    );
  }

  Widget getMenu(BuildContext context, {required bool showLabels}) {
    final groupedItems = SectionGroups.allGroups.entries
        .map(
          (entry) => entry.value.where((section) {
            if (section == Section.operators) {
              return Globals.persona == Role.manager;
            }
            return true;
          }).toList(),
        )
        .where((items) => items.isNotEmpty)
        .toList();

    if (groupedItems.isEmpty) return const SizedBox.shrink();

    const itemHeight = 34.0;
    const separatorHeight = 16.0;

    double? selectedTop;
    var runningTop = 0.0;
    for (var groupIndex = 0; groupIndex < groupedItems.length; groupIndex++) {
      final items = groupedItems[groupIndex];
      final localIndex = items.indexOf(selectedItem);
      if (localIndex != -1) {
        selectedTop = runningTop + (localIndex * itemHeight);
        break;
      }

      runningTop += items.length * itemHeight;
      if (groupIndex < groupedItems.length - 1) {
        runningTop += separatorHeight;
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Stack(
          children: [
            if (selectedTop != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                left: 8,
                right: 8,
                top: selectedTop,
                child: IgnorePointer(
                  child: Container(
                    height: itemHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  var groupIndex = 0;
                  groupIndex < groupedItems.length;
                  groupIndex++
                ) ...[
                  ...groupedItems[groupIndex].map((section) {
                    final isSelected = section == selectedItem;
                    return SizedBox(
                      height: itemHeight,
                      child: _RightTooltip(
                        message: section.name,
                        enabled: !showLabels,
                        child: InkWell(
                          borderRadius: BorderRadius.zero,
                          onTap: () {
                            final isSectionChange = section != selectedItem;
                            if (isSectionChange &&
                                Globals.hasUnsavedFormChanges) {
                              CustomSnackBar.show(
                                context,
                                "You lost some unsaved changes by navigating out of this page.",
                                category: SnackBarCategory.warning,
                              );
                              Globals.hasUnsavedFormChanges = false;
                            }

                            context.read<NavigationCubit>().navigate(section);
                            onItemTap?.call();
                          },
                          child: Padding(
                            padding: showLabels
                                ? const EdgeInsets.symmetric(horizontal: 20)
                                : const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: showLabels
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                Icon(
                                  section.icon,
                                  color: section.color,
                                  size: 20,
                                ),
                                if (showLabels) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeInOutCubic,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelLarge?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ) ??
                                          TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                      child: Text(
                                        section.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (groupIndex < groupedItems.length - 1)
                    Divider(
                      color: Theme.of(context).colorScheme.outline,
                      thickness: 0.5,
                      height: separatorHeight,
                    ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
