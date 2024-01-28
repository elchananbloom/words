

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:words/providers/speed_provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SpeedSliderWidget extends ConsumerStatefulWidget {
  const SpeedSliderWidget({
    super.key,
  });


  @override
  _SpeedSliderState createState() => _SpeedSliderState();
}

class _SpeedSliderState extends ConsumerState<SpeedSliderWidget> {
  int speedIndex = 2;
  double speed = 1.0;
  final labels = ['0.5', '0.75', '1', '1.5', '2'];
  final doubleLabels = [0.5, 0.75, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    speed = ref.read(speedProvider.notifier).state;
    speedIndex = doubleLabels.indexOf(speed);
  }

  handleChangeSpeed(value) {
    setState(() {
      speedIndex = value.toInt();
    });
    ref.read(speedProvider.notifier).state =
        double.parse(labels[value.toInt()]);
  }

  @override
  Widget build(BuildContext context) {
    const double min = 0;
    final double max = labels.length - 1.toDouble();
    final double divisions = max;

    var thumbRadius = 15.0;
    return SfSliderTheme(
      data: SfSliderThemeData(
        thumbRadius: thumbRadius,
      ),
      child: SfSlider(
        value: speedIndex.toDouble(),
        min: min,
        max: max,
        interval: divisions,
        thumbIcon: Center(
          child: Text(
            labels[speedIndex.toInt()],
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        onChanged: (value) {
          handleChangeSpeed(value);
        },
      ),
    );
  }
}
