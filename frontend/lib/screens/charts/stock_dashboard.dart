import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';

class StockDashboard extends StatefulWidget {
  const StockDashboard({super.key});

  @override
  State<StockDashboard> createState() => _StockDashboardState();
}

class _StockDashboardState extends State<StockDashboard> {
  Map<String, Map<String, dynamic>> stockCounts = {};

  // FOR DROP DOWN
  final List<String> allItems = [
    'Hollow Blocks',
    'Rebar',
    'Sack Of Bistay Sand',
    'Sack Of Cement',
    'Sack Of Gravel',
    'Sack Of Skim Coat',
  ];
  // FOR DROP DOWN
  String? selectedItem;
  // For DropDown, filter out items already in stock
  late List<String> availableItems;

  void filterAvailableItems() {
    availableItems = allItems;
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
              "price": value["unitPrice"] ?? 0.0,
            }));

        // Call filter after setting stockCounts
        filterAvailableItems();

        // Auto-select the first available item, or any stock item if all are already used
        if (selectedItem == null || !availableItems.contains(selectedItem)) {
          selectedItem =
              availableItems.isNotEmpty ? availableItems.first : null;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStockData();
    availableItems = [];
  }

  @override
  Widget build(BuildContext context) {
    final stock = selectedItem != null ? stockCounts[selectedItem] : null;

    final double availableStock = (stock?['availableStock'] ?? 0).toDouble();
    final double sold = (stock?['sold'] ?? 0).toDouble();
    final double totalStock = (stock?['totalStock'] ?? 0).toDouble();

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "Stock Overview",
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 22,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              // color: Color.fromARGB(255, 27, 211, 224),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        endDrawer: const SideMenu(),
        body: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                "assets/images/tectags_bg.png",
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedItem,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors
                              .grey[700], // 👈 Arrow color to match textfields
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        hint: Text(
                          'Select an item',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600),
                        ),
                        items: stockCounts.keys.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedItem = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an item';
                          }
                          return null;
                        },
                        dropdownColor: Colors
                            .grey[100], // Optional: Dropdown popup background
                      ),
                    ),
                    SizedBox(height: 25),
                    if (stock != null) ...[
                      Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  selectedItem ?? '',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                                          value: availableStock,
                                          title: 'Available',
                                          radius: 50,
                                          titleStyle:
                                              TextStyle(color: Colors.white),
                                        ),
                                        PieChartSectionData(
                                          color: Colors.red[300],
                                          value: sold,
                                          title: 'Sold',
                                          radius: 50,
                                          titleStyle:
                                              TextStyle(color: Colors.white),
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
                                      maxY: totalStock + 100,
                                      groupsSpace: 100,
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                                toY: totalStock,
                                                color: Colors.blue[500]),
                                          ],
                                          showingTooltipIndicators: [0],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                                toY: availableStock,
                                                color: Colors.green[500]),
                                          ],
                                          showingTooltipIndicators: [0],
                                        ),
                                        BarChartGroupData(
                                          x: 2,
                                          barRods: [
                                            BarChartRodData(
                                                toY: sold,
                                                color: Colors.red[300]),
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
                          ))
                    ] else ...[
                      SizedBox(height: 40),
                      Text(
                        "No stock selected",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
