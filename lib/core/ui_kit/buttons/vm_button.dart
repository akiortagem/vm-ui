import 'package:flutter/material.dart';
import 'package:vm_ui/core/ui_kit/colors.dart';

/// The supported sizes for [VMButton].
enum VMButtonSize { large, medium, small }

/// The visual treatments supported by [VMButton].
enum VMButtonVariant { filled, outlined }

/// The primary call-to-action button used throughout the app.
///
/// Set [onPressed] to `null` to display the disabled state. Active and pressed
/// colors are resolved automatically from the button's Material state.
class VMButton extends StatelessWidget {
  const VMButton({
    required this.label,
    required this.onPressed,
    this.size = VMButtonSize.medium,
    this.variant = VMButtonVariant.filled,
    this.expand = false,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  const VMButton.outlined({
    required this.label,
    required this.onPressed,
    this.size = VMButtonSize.medium,
    this.expand = false,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  }) : variant = VMButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final VMButtonSize size;
  final VMButtonVariant variant;

  /// Whether the button should fill the available horizontal space.
  final bool expand;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimensions = _ButtonDimensions.from(size);
    final button = ElevatedButton(
      onPressed: onPressed,
      autofocus: autofocus,
      focusNode: focusNode,
      style: _style(dimensions),
      child: Text(label),
    );

    final result = SizedBox(
      width: expand ? double.infinity : dimensions.minimumWidth,
      height: dimensions.height,
      child: button,
    );

    if (semanticLabel == null) {
      return result;
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: result,
    );
  }

  ButtonStyle _style(_ButtonDimensions dimensions) {
    final isOutlined = variant == VMButtonVariant.outlined;

    return ButtonStyle(
      animationDuration: const Duration(milliseconds: 120),
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: WidgetStatePropertyAll(
        Size(dimensions.minimumWidth, dimensions.height),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: dimensions.horizontalPadding),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.height / 2),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: dimensions.fontSize,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (isOutlined) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.disabled)) {
          return VMColorTheme.black40;
        }
        if (states.contains(WidgetState.pressed)) {
          return VMColorTheme.red80;
        }
        return VMColorTheme.red60;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return isOutlined ? VMColorTheme.black50 : VMColorTheme.black60;
        }
        if (states.contains(WidgetState.pressed)) {
          return isOutlined ? VMColorTheme.red70 : VMColorTheme.black10;
        }
        return isOutlined ? VMColorTheme.red60 : VMColorTheme.black10;
      }),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStateProperty.resolveWith((states) {
        if (!isOutlined) {
          return BorderSide.none;
        }
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: VMColorTheme.black40);
        }
        if (states.contains(WidgetState.pressed)) {
          return const BorderSide(color: VMColorTheme.red70);
        }
        return const BorderSide(color: VMColorTheme.red60);
      }),
    );
  }
}

class _ButtonDimensions {
  const _ButtonDimensions({
    required this.height,
    required this.minimumWidth,
    required this.horizontalPadding,
    required this.fontSize,
  });

  factory _ButtonDimensions.from(VMButtonSize size) {
    return switch (size) {
      VMButtonSize.large => const _ButtonDimensions(
        height: 72,
        minimumWidth: 254,
        horizontalPadding: 46,
        fontSize: 24,
      ),
      VMButtonSize.medium => const _ButtonDimensions(
        height: 40,
        minimumWidth: 140,
        horizontalPadding: 24,
        fontSize: 14,
      ),
      VMButtonSize.small => const _ButtonDimensions(
        height: 28,
        minimumWidth: 98,
        horizontalPadding: 16,
        fontSize: 11,
      ),
    };
  }

  final double height;
  final double minimumWidth;
  final double horizontalPadding;
  final double fontSize;
}
