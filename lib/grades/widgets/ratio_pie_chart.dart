import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RatioPieChart extends StatelessWidget {
  final List<double> ratio;
  final double size;

  const RatioPieChart({
    super.key,
    required this.ratio,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (ratio.every((element) => element == 0)) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text("N/A")),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: size * 0.2,
          sections: [
            PieChartSectionData(
              value: ratio[0], // Positive
              color: Colors.green,
              radius: size * 0.3,
              showTitle: false,
            ),
            PieChartSectionData(
              value: ratio[2], // Mid (5-6)
              color: Colors.yellow,
              radius: size * 0.3,
              showTitle: false,
            ),
            PieChartSectionData(
              value: ratio[1], // Negative
              color: Colors.red,
              radius: size * 0.3,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }
}
