import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo data - replace this with actual data later

    final Map<String, dynamic> order = {
      'orderNumber': 'ORD-2024-001',
      'partyName': 'ABC Electronics Pvt Ltd',
      'date': '2024-01-15',
      'status': 'Paid',
      'items': [
        {
          'name': 'Laptop Dell Inspiron',
          'quantity': '2',
          'price': '₹45000',
        },
        {
          'name': 'Wireless Mouse',
          'quantity': '3',
          'price': '₹1200',
        },
        {
          'name': 'USB Cable',
          'quantity': '5',
          'price': '₹300',
        },
        {
          'name': 'Monitor Stand',
          'quantity': '1',
          'price': '₹2500',
        },
      ],
    };

    final items = order['items'] as List;
    double totalAmount = 0;

    // Calculate total amount from items
    for (var item in items) {
      final quantity = int.parse(item['quantity'].toString());
      final price = double.parse(item['price'].toString().replaceAll('₹', ''));
      totalAmount += quantity * price;
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Order ${order['orderNumber']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
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
                  value: order['orderNumber'] ?? 'N/A',
                ),
                _buildDetailRow(
                  icon: Icons.business,
                  label: 'Party Name',
                  value: order['partyName'] ?? 'N/A',
                ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: order['date'] ?? 'N/A',
                ),
                _buildDetailRow(
                  icon:
                  order['status'] == 'Paid'
                      ? Icons.check_circle
                      : Icons.cancel,
                  label: 'Status',
                  value: order['status'] ?? 'N/A',
                  valueColor:
                  order['status'] == 'Paid' ? Colors.green : Colors.red,
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
                Table(
                  border: TableBorder.all(color: Colors.grey[300]!, width: 1),
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
                    ...items.asMap().entries.map((entry) {
                      final item = entry.value;
                      final quantity = int.parse(item['quantity'].toString());
                      final price = double.parse(
                        item['price'].toString().replaceAll('₹', ''),
                      );
                      final subtotal = quantity * price;
                      return TableRow(
                        children: [
                          _buildTableCell(item['name']),
                          _buildTableCell(item['quantity']),
                          _buildTableCell(item['price']),
                          _buildTableCell('₹${subtotal.toStringAsFixed(2)}'),
                        ],
                      );
                    }),
                  ],
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
      ),
    );
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:facesoft/style/app_style.dart';
//
// class OrderDetailPage extends StatelessWidget {
//
//
//   const OrderDetailPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final items = order['items'] as List;
//     double totalAmount = 0;
//
//     // Calculate total amount from items
//     for (var item in items) {
//       final quantity = int.parse(item['quantity'].toString());
//       final price = double.parse(item['price'].toString().replaceAll('₹', ''));
//       totalAmount += quantity * price;
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text('Order ${order['orderNumber']}'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           elevation: 2,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Order Header
//                 Text(
//                   'Order Details',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Order Info
//                 _buildDetailRow(
//                   icon: Icons.confirmation_number,
//                   label: 'Order Number',
//                   value: order['orderNumber'] ?? 'N/A',
//                 ),
//                 _buildDetailRow(
//                   icon: Icons.business,
//                   label: 'Party Name',
//                   value: order['partyName'] ?? 'N/A',
//                 ),
//                 _buildDetailRow(
//                   icon: Icons.calendar_today,
//                   label: 'Date',
//                   value: order['date'] ?? 'N/A',
//                 ),
//                 _buildDetailRow(
//                   icon:
//                       order['status'] == 'Paid'
//                           ? Icons.check_circle
//                           : Icons.cancel,
//                   label: 'Status',
//                   value: order['status'] ?? 'N/A',
//                   valueColor:
//                       order['status'] == 'Paid' ? Colors.green : Colors.red,
//                 ),
//                 const Divider(color: Colors.grey, thickness: 1, height: 32),
//                 // Items Header
//                 Text(
//                   'Items Ordered',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // Items Table
//                 Table(
//                   border: TableBorder.all(color: Colors.grey[300]!, width: 1),
//                   columnWidths: const {
//                     0: FlexColumnWidth(3),
//                     1: FlexColumnWidth(2),
//                     2: FlexColumnWidth(2),
//                     3: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(color: Colors.grey[100]),
//                       children: [
//                         _buildTableHeader('Item'),
//                         _buildTableHeader('Quantity'),
//                         _buildTableHeader('Price'),
//                         _buildTableHeader('Subtotal'),
//                       ],
//                     ),
//                     ...items.asMap().entries.map((entry) {
//                       final item = entry.value;
//                       final quantity = int.parse(item['quantity'].toString());
//                       final price = double.parse(
//                         item['price'].toString().replaceAll('₹', ''),
//                       );
//                       final subtotal = quantity * price;
//                       return TableRow(
//                         children: [
//                           _buildTableCell(item['name']),
//                           _buildTableCell(item['quantity']),
//                           _buildTableCell(item['price']),
//                           _buildTableCell('₹${subtotal.toStringAsFixed(2)}'),
//                         ],
//                       );
//                     }),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Total Amount
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Total Amount',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     Text(
//                       '₹${totalAmount.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     Color? valueColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 24, color: AppColors.primary),
//           const SizedBox(width: 12),
//           Text(
//             '$label: ',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: valueColor ?? Colors.black87,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTableHeader(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           color: AppColors.primary,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
//
//   Widget _buildTableCell(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 14),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
