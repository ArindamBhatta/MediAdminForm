import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum SnackBarCategory { error, warning, success, info, failure }

extension SnackBarCategoryExtension on SnackBarCategory {
  Color backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      SnackBarCategory.error => scheme.error,
      SnackBarCategory.failure => const Color(0xFFB00020),
      SnackBarCategory.warning => const Color(0xFFED6C02),
      SnackBarCategory.success => const Color(0xFF2E7D32),
      SnackBarCategory.info => const Color(0xFF0288D1),
    };
  }

  IconData get icon {
    return switch (this) {
      SnackBarCategory.error => Icons.error_outline,
      SnackBarCategory.failure => Icons.report_problem_outlined,
      SnackBarCategory.warning => Icons.warning_amber_rounded,
      SnackBarCategory.success => Icons.check_circle_outline,
      SnackBarCategory.info => Icons.info_outline,
    };
  }

  Duration get duration {
    return switch (this) {
      SnackBarCategory.error => const Duration(seconds: 4),
      SnackBarCategory.failure => const Duration(seconds: 5),
      SnackBarCategory.warning => const Duration(seconds: 4),
      SnackBarCategory.success => const Duration(seconds: 3),
      SnackBarCategory.info => const Duration(seconds: 3),
    };
  }
}

class CustomSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarCategory category = SnackBarCategory.info,
    Color? backgroundColor,
    Duration? duration,
  }) {
    _show(
      context,
      message,
      category: category,
      backgroundColor: backgroundColor,
      duration: duration ?? category.duration,
    );
  }

  static void showPersistent(
    BuildContext context,
    String message, {
    SnackBarCategory category = SnackBarCategory.info,
    Color? backgroundColor,
  }) {
    _show(
      context,
      message,
      category: category,
      backgroundColor: backgroundColor,
      duration: const Duration(days: 365),
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required SnackBarCategory category,
    Color? backgroundColor,
    required Duration duration,
  }) {
    void showNow() {
      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(category.icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor ?? category.backgroundColor(context),
        duration: duration,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.startToEnd,
        elevation: 2.0,
      );

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuildPhase =
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks ||
        phase == SchedulerPhase.persistentCallbacks;

    if (isBuildPhase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNow();
      });
      return;
    }

    showNow();
  }
}
