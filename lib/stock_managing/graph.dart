import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Graph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, title: 'Saumon', color: Colors.blue),
            PieChartSectionData(value: 30, title: 'Thon', color: Colors.red),
            PieChartSectionData(value: 20, title: 'Daurade', color: Colors.green),
            PieChartSectionData(value: 10, title: 'Sardine', color: Colors.yellow),
          ],
        ),
      ),
    );
  }
}
