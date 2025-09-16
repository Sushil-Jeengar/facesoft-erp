import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          );
        },
      ),
    );
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
