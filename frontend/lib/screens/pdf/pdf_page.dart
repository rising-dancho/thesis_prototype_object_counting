import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/screens/pdf/services/pdf_api.dart';
import 'package:tectags/screens/pdf/services/pdf_invoice_api.dart';
import 'package:tectags/screens/pdf/models/customer.dart';
import 'package:tectags/screens/pdf/models/invoice.dart';
import 'package:tectags/screens/pdf/models/supplier.dart';
import 'package:tectags/screens/pdf/widgets/button_widget.dart';
import 'package:tectags/screens/pdf/widgets/title_widget.dart';

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
            'Generate Reports',
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
                  text: 'Reports',
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ButtonWidget(
                    text: 'Invoice PDF',
                    onClicked: () async {
                      final date = DateTime.now();
                      final dueDate = date.add(Duration(days: 7));

                      final invoice = Invoice(
                        supplier: Supplier(
                          name: 'Sarah Field',
                          address: 'Sarah Street 9, Beijing, China',
                          paymentInfo: 'https://paypal.me/sarahfieldzz',
                        ),
                        customer: Customer(
                          name: 'Apple Inc.',
                          address: 'Apple Street, Cupertino, CA 95014',
                        ),
                        info: InvoiceInfo(
                          date: date,
                          dueDate: dueDate,
                          description: 'My description...',
                          number: '${DateTime.now().year}-9999',
                        ),
                        items: [
                          InvoiceItem(
                            description: 'Coffee',
                            date: DateTime.now(),
                            quantity: 3,
                            vat: 0.19,
                            unitPrice: 5.99,
                          ),
                          InvoiceItem(
                            description: 'Water',
                            date: DateTime.now(),
                            quantity: 8,
                            vat: 0.19,
                            unitPrice: 0.99,
                          ),
                          InvoiceItem(
                            description: 'Orange',
                            date: DateTime.now(),
                            quantity: 3,
                            vat: 0.19,
                            unitPrice: 2.99,
                          ),
                          InvoiceItem(
                            description: 'Apple',
                            date: DateTime.now(),
                            quantity: 8,
                            vat: 0.19,
                            unitPrice: 3.99,
                          ),
                          InvoiceItem(
                            description: 'Mango',
                            date: DateTime.now(),
                            quantity: 1,
                            vat: 0.19,
                            unitPrice: 1.59,
                          ),
                          InvoiceItem(
                            description: 'Blue Berries',
                            date: DateTime.now(),
                            quantity: 5,
                            vat: 0.19,
                            unitPrice: 0.99,
                          ),
                          InvoiceItem(
                            description: 'Lemon',
                            date: DateTime.now(),
                            quantity: 4,
                            vat: 0.19,
                            unitPrice: 1.29,
                          ),
                        ],
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
