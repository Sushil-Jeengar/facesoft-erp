import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/providers/order_provider.dart';
import 'package:facesoft/model/order_model.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Order?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _fetchOrder();
  }

  Future<Order?> _fetchOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    return await orderProvider.getOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<Order?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          // Calculate total amount from items
          double totalAmount = 0;
          if (order.items != null) {
            for (var item in order.items!) {
              final quantity = item.quantity ?? 0;
              final price = item.price is num
                  ? (item.price as num).toDouble()
                  : double.tryParse(
                  (item.price?.toString().replaceAll('₹', '') ?? '0')
                      .replaceAll(',', '')) ?? 0;
              totalAmount += quantity * price;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header
                        Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Order Info
                        _buildDetailRow(
                          icon: Icons.confirmation_number,
                          label: 'Order Number',
                          value: order.orderNumber ?? 'N/A',
                        ),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: order.orderDate?.toIso8601String().split('T')[0] ??
                              'N/A',
                        ),
                        _buildDetailRow(
                          icon: Icons.payment,
                          label: 'Status',
                          value: order.paymentStatus ?? 'N/A',
                          valueColor: _getStatusColor(order.paymentStatus),
                        ),
                        const Divider(color: Colors.grey, thickness: 1, height: 32),
                        // Items Header
                        Text(
                          'Items Ordered',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Items Table
                        if (order.items?.isNotEmpty ?? false) ...[
                          Table(
                            border: TableBorder.all(color: Colors.grey[300]!,
                                width: 1),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey[100]),
                                children: [
                                  _buildTableHeader('Item'),
                                  _buildTableHeader('Quantity'),
                                  _buildTableHeader('Price'),
                                  _buildTableHeader('Subtotal'),
                                ],
                              ),
                              ...order.items!.map((item) {
                                final quantity = item.quantity ?? 0;
                                final price = item.price is num
                                    ? (item.price as num).toDouble()
                                    : double.tryParse(
                                    (item.price?.toString().replaceAll('₹', '') ??
                                        '0').replaceAll(',', '')) ?? 0;
                                final subtotal = quantity * price;
                                return TableRow(
                                  children: [
                                    _buildTableCell(item.itemName ?? 'N/A'),
                                    _buildTableCell(quantity.toString()),
                                    _buildTableCell('₹$price'),
                                    _buildTableCell(
                                        '₹${subtotal.toStringAsFixed(2)}'),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('No items in this order'),
                          ),
                        const SizedBox(height: 16),
                        // Total Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '₹${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Download Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _generateAndOpenPdf(order, totalAmount, context),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Order'),
                    style: AppButtonStyles.primaryButton
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _generateAndOpenPdf(Order order, double totalAmount, BuildContext context) async {
    try {
      // Show loading indicator
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final snackBar = SnackBar(
        content: const Text('Generating PDF...'),
        duration: const Duration(seconds: 2),
      );
      scaffoldMessenger.showSnackBar(snackBar);

      // Create a PDF document
      final pdf = pw.Document();
      
      // Add a page to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Order Details',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Order Information
            pw.Text(
              'Order #${order.orderNumber ?? 'N/A'}\n'
              'Date: ${order.orderDate?.toIso8601String().split('T')[0] ?? 'N/A'}\n'
              'Status: ${order.paymentStatus ?? 'N/A'}\n',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Divider(),
            
            // Items Table
            pw.Text(
              'Items Ordered',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            if (order.items?.isNotEmpty ?? false) ...[
              pw.Table.fromTextArray(
                headers: ['Item', 'Qty', 'Price', 'Subtotal'],
                data: order.items!.map((item) {
                  final quantity = item.quantity ?? 0;
                  final price = item.price is num
                      ? (item.price as num).toDouble()
                      : double.tryParse(
                          (item.price?.toString().replaceAll('₹', '') ?? '0')
                              .replaceAll(',', '')) ?? 0;
                  final subtotal = quantity * price;
                  return [
                    item.itemName ?? 'N/A',
                    quantity.toString(),
                    '₹$price',
                    '₹${subtotal.toStringAsFixed(2)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEEEEEE),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 12),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
              ),
            ],
            
            // Total Amount
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            
            // Footer
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text(
                'Thank you for your order!',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
            ),
          ],
        ),
      );

      // Save the PDF to a temporary file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/order_${order.orderNumber ?? 'details'}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the PDF file
      await OpenFile.open(file.path);

      // Show success message
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
      ),
    );
  }
}
