import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';

class StockDashboard extends StatefulWidget {
  const StockDashboard({super.key});

  @override
  State<StockDashboard> createState() => _StockDashboardState();
}

class _StockDashboardState extends State<StockDashboard> {
  Map<String, Map<String, dynamic>> stockCounts = {};

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  // INFO DISPLAYED IN THE CARDS PULLED FROM THE STOCKS COLLECTION
  Future<void> fetchStockData() async {
    Map<String, Map<String, dynamic>>? data = await API.fetchStockFromMongoDB();
    debugPrint("Fetched Stock Data: $data");
    debugPrint("STOCK COUNTS Data: $stockCounts");

    if (data == null) {
      debugPrint("⚠️ No stock data fetched.");
      return; // Exit early if data is null
    }

    // Optional: print each stock item
    data.forEach((key, value) {
      debugPrint("PRICE HERE!!: $key => $value");
    });

    if (mounted) {
      setState(() {
        stockCounts = data.map((key, value) => MapEntry(key, {
              "availableStock": value["availableStock"] ?? 0,
              "totalStock": value["totalStock"] ?? 0,
              "sold": value["sold"] ?? 0,
              "price": value["unitPrice"] ?? 0.0, // PRICE
            }));
      });
      debugPrint("Updated StockCounts: $stockCounts");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String selectedStock = 'Sack Of Bistay Sand';
    final stock = stockCounts[selectedStock];

    final double availableStock = (stock?['availableStock'] ?? 0).toDouble();
    final double sold = (stock?['sold'] ?? 0).toDouble();
    final double totalStock = (stock?['totalStock'] ?? 0).toDouble();

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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.left,
                          );
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
