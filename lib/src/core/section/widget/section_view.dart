import 'package:flutter/material.dart';
import 'package:web_ui_plugins/src/core/widgets/enums.dart';
import 'package:web_ui_plugins/src/core/widgets/globals.dart';

class SectionView extends StatelessWidget {
  final Widget child;
  final Section section;
  final List<Widget>? headerLeftActions;
  final List<Widget>? headerCenterActions;
  final List<Widget>? headerRightActions;
  final double headerLeftActionsInset;
  final List<Widget>? actions;

  const SectionView({
    super.key,
    required this.child,
    required this.section,
    this.headerLeftActions,
    this.headerCenterActions,
    this.headerRightActions,
    this.headerLeftActionsInset = 0,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //header portion of section
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          height: Globals.topBarHeight,
          child: Padding(
            padding: EdgeInsets.only(
              left: Globals.sidePadding,
              right: Globals.sidePadding / 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(section.icon, size: 24, color: section.color),
                SizedBox(width: Globals.sidePadding),
                Text(
                  section.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (headerLeftActions != null &&
                    headerLeftActions!.isNotEmpty) ...[
                  SizedBox(width: Globals.sidePadding),
                  Padding(
                    padding: EdgeInsets.only(left: headerLeftActionsInset),
                    child: Row(
                      spacing: Globals.sidePadding / 2,
                      children: headerLeftActions!,
                    ),
                  ),
                ],
                const Spacer(),
                if (headerCenterActions != null &&
                    headerCenterActions!.isNotEmpty) ...[
                  Row(
                    spacing: Globals.sidePadding / 2,
                    children: headerCenterActions!,
                  ),
                  const Spacer(),
                ],
                if (headerRightActions != null &&
                    headerRightActions!.isNotEmpty)
                  Row(
                    spacing: Globals.sidePadding / 2,
                    children: headerRightActions!,
                  )
                else if (actions != null)
                  Row(spacing: Globals.sidePadding, children: actions!),
              ],
            ),
          ),
        ),
        const Divider(thickness: 1, height: 1),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: child, //Pass the child eg(SubSectionView)
          ),
        ),
      ],
    );
  }
}
