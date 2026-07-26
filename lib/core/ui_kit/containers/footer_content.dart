import 'package:flutter/material.dart';

/// A footer surface that holds composable page actions and supporting content.
///
/// The footer fills the available width and rounds only its top corners so it
/// can sit flush against the bottom and sides of a page.
class VMFooterContent extends StatelessWidget {
  const VMFooterContent({
    required this.child,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 80, vertical: 64),
    super.key,
  });

  final Widget child;

  /// How far the footer extends upward from the bottom of its parent.
  ///
  /// When omitted, the footer sizes itself to its content and padding.
  final double? height;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(52)),
      ),
      child: child,
    );
  }
}
