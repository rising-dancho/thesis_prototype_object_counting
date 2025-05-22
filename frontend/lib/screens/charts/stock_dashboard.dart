import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockDashboard extends StatelessWidget {
  final int availableStock = 4980;
  final int sold = 420;
  final int totalStock = 5000;
  final int unitPrice = 96;

  const StockDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Overview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Sack Of Bistay Sand',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Pie Chart: Available vs Sold'),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green[500],
                      value: availableStock.toDouble(),
                      title: 'Available',
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red[300],
                      value: sold.toDouble(),
                      title: 'Sold',
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Text('Bar Chart: Stock Breakdown'),
            SizedBox(height: 50),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: totalStock.toDouble() +
                      100, // Add some space above the tallest bar
                  groupsSpace: 100,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalStock.toDouble(),
                          color: Colors.blue[500],
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: availableStock.toDouble(),
                          color: Colors.green[500],
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: sold.toDouble(),
                          color: Colors.red[300],
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 0:
                              return Text('Total');
                            case 1:
                              return Text('Available');
                            case 2:
                              return Text('Sold');
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40, // default is too small
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
