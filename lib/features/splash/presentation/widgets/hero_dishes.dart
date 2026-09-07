import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class HeroDishes extends StatefulWidget {
  const HeroDishes({
    required this.dishes,
    this.edgeOverflow = 0,
    this.randomRotation = true,
    super.key,
  });

  final List<Image> dishes;
  final double edgeOverflow;
  final bool randomRotation;

  @override
  State<HeroDishes> createState() => _HeroDishesState();
}

class _HeroDishesState extends State<HeroDishes> {
  late List<double> _rotations;

  @override
  void initState() {
    super.initState();
    _rotations = _createRotations();
  }

  @override
  void didUpdateWidget(HeroDishes oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dishes.length != widget.dishes.length ||
        oldWidget.randomRotation != widget.randomRotation) {
      _rotations = _createRotations();
    }
  }

  List<double> _createRotations() {
    if (!widget.randomRotation) {
      return List.filled(widget.dishes.length, 0);
    }

    final random = math.Random();
    return List.generate(
      widget.dishes.length,
      (_) => (random.nextDouble() - 0.5) * (math.pi / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, dish) in widget.dishes.indexed)
          Align(
            alignment: index.isEven
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(
                index.isEven ? widget.edgeOverflow : -widget.edgeOverflow,
                0,
              ),
              child: Transform.rotate(angle: _rotations[index], child: dish),
            ),
          ),
      ],
    );
  }
}
