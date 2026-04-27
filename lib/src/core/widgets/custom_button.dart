import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, tertiary, supporting, danger }

enum ButtonState { enabled, disabled, working }

enum ButtonGroup { left, right }

extension ButtonTypeExtension on ButtonType {
  Color backgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case ButtonType.primary:
        return theme.colorScheme.primary;
      case ButtonType.secondary:
        return theme.colorScheme.secondary;
      case ButtonType.tertiary:
        return theme.colorScheme.surface;
      case ButtonType.supporting:
        return theme.colorScheme.secondaryContainer;
      case ButtonType.danger:
        return theme.colorScheme.error;
    }
  }

  Color foregroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return theme.colorScheme.onPrimary;
      case ButtonType.tertiary:
        return theme.colorScheme.onSurface;
      case ButtonType.supporting:
        return theme.colorScheme.onSecondaryContainer;
    }
  }
}

class CustomButton extends StatelessWidget {
  final ButtonState buttonState;
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final ButtonType buttonType;
  final double? height;
  final ButtonGroup group;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonState = ButtonState.enabled,
    this.icon,
    this.iconSize,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.borderRadius = 4,
    this.buttonType = ButtonType.primary,
    this.height,
    this.group = ButtonGroup.left,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveBackgroundColor =
        backgroundColor ?? buttonType.backgroundColor(context);

    Color effectiveForegroundColor =
        foregroundColor ?? buttonType.foregroundColor(context);
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: buttonState == ButtonState.disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: getButtonChild(
          effectiveBackgroundColor,
          effectiveForegroundColor,
        ),
      ),
    );
  }

  Widget getButtonChild(
    Color effectiveBackgroundColor,
    Color effectiveForegroundColor,
  ) {
    final Color normalColor = effectiveForegroundColor;
    final Color disabledColor = normalColor.withValues(alpha: 0.5);
    final rowColor = switch (buttonState) {
      ButtonState.enabled => normalColor,
      ButtonState.disabled => disabledColor,
      ButtonState.working => effectiveBackgroundColor,
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: rowColor, size: iconSize),
              const SizedBox(width: 8),
            ],
            Text(text, style: TextStyle(color: rowColor)),
          ],
        ),
        if (buttonState == ButtonState.working)
          SizedBox(
            width: iconSize ?? 16,
            height: iconSize ?? 16,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(normalColor),
              strokeWidth: 2.0,
            ),
          ),
      ],
    );
  }
}
