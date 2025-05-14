import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/screens/pdf/services/pdf_api.dart';
import 'package:tectags/screens/pdf/services/pdf_invoice_api.dart';
import 'package:tectags/screens/pdf/models/customer.dart';
import 'package:tectags/screens/pdf/models/invoice.dart';
import 'package:tectags/screens/pdf/models/supplier.dart';
import 'package:tectags/screens/pdf/widgets/button_widget.dart';
import 'package:tectags/screens/pdf/widgets/title_widget.dart';
import 'package:tectags/services/api.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Reports',
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          foregroundColor: Colors.white,
          // title: const Text('My Profile'),
          // backgroundColor: const Color.fromARGB(255, 5, 45, 90),
          // elevation: 0,
          // foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        endDrawer: const SideMenu(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/tectags_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TitleWidget(
                  icon: Icons.picture_as_pdf,
                  text: 'Generate Reports',
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ButtonWidget(
                    text: 'Invoice PDF',
                    onClicked: () async {
                      final date = DateTime.now();
                      final dueDate = date.add(const Duration(days: 7));

                      final stockMap =
                          await API.fetchStockFromMongoDB();

                      if (stockMap == null || stockMap.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to fetch stock data")),
                        );
                        return;
                      }

                      // Convert map to list of InvoiceItems
                      final invoiceItems = stockMap.entries.map((entry) {
                        final data = entry.value;

                        return InvoiceItem(
                          description: entry.key,
                          date: date,
                          quantity: data['sold'], // Use 'sold' as quantity
                          vat: 0.12, // Adjust VAT as per your local rate
                          unitPrice: data['unitPrice'],
                        );
                      }).toList();

                      final invoice = Invoice(
                        supplier: Supplier(
                          name: 'CGG Marketing',
                          address: '96 V. Luna Ave, Diliman, Quezon City, 1100 Metro Manila',
                          paymentInfo: 'Your Payment Info',
                        ),
                        customer: Customer(
                          name: 'Sample Customer',
                          address: 'Customer Address',
                        ),
                        info: InvoiceInfo(
                          date: date,
                          dueDate: dueDate,
                          description: 'Sales Report',
                          number: '${date.year}-${date.microsecondsSinceEpoch}',
                        ),
                        items: invoiceItems,
                      );

                      final pdfFile = await PdfInvoiceApi.generate(invoice);
                      PdfApi.openFile(pdfFile);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
