import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/providers/order_provider.dart';
import 'package:facesoft/model/order_model.dart';
import 'package:facesoft/API_services/order_api.dart';
import 'package:facesoft/pages/order_detail_page.dart';
import 'package:facesoft/screens/add_order.dart';
import 'package:facesoft/providers/auth_provider.dart';

class OrderPage extends StatefulWidget {
  final void Function(int) onTabSelected;
  final void Function(Order order)? onEditOrder;
  const OrderPage({super.key, required this.onTabSelected, this.onEditOrder});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _filter = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Order> _filteredOrders = [];
  bool _isSelectionMode = false;
  final List<String> _selectedOrderNumbers = [];
  List<String> _selectedParties = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.authData?.user.id;
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.addListener(_onOrdersChanged);
      orderProvider.fetchOrders(userId: userId).then((_) {
        _applyFilters();
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.removeListener(_onOrdersChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onOrdersChanged() {
    if (mounted) {
      setState(() {
        _filteredOrders = List.from(Provider.of<OrderProvider>(context, listen: false).orders);
        _applyFilters();
      });
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      // If search is cleared, reset filters
      setState(() {
        _filter = 'All';
        _selectedStartDate = null;
        _selectedEndDate = null;
        _filteredOrders = List.from(Provider.of<OrderProvider>(context, listen: false).orders);
      });
    } else {
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      List<Order> tempOrders = List.from(orderProvider.orders);

      // Apply payment status filter
      if (_filter != 'All') {
        tempOrders = tempOrders.where((order) => order.paymentStatus == _filter).toList();
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        tempOrders = tempOrders.where((order) {
          final orderNumber = order.orderNumber?.toLowerCase() ?? '';
          final partyId = order.partyId?.toString() ?? '';
          
          return orderNumber.contains(query) || 
                partyId.contains(query);
        }).toList();
      }

      // Apply date range filter
      if (_selectedStartDate != null || _selectedEndDate != null) {
        tempOrders = tempOrders.where((order) {
          if (order.orderDate == null) return false;
          
          final orderDate = order.orderDate!;
          final orderDateOnly = DateTime(orderDate.year, orderDate.month, orderDate.day);
          
          // Check start date only
          if (_selectedStartDate != null && _selectedEndDate == null) {
            final startDateOnly = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
            return orderDateOnly.isAtSameMomentAs(startDateOnly) || orderDateOnly.isAfter(startDateOnly);
          }
          
          // Check end date only
          if (_selectedEndDate != null && _selectedStartDate == null) {
            final endDateOnly = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
            return orderDateOnly.isAtSameMomentAs(endDateOnly) || orderDateOnly.isBefore(endDateOnly);
          }
          
          // Check both start and end dates
          if (_selectedStartDate != null && _selectedEndDate != null) {
            final startDateOnly = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
            final endDateOnly = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
            return (orderDateOnly.isAtSameMomentAs(startDateOnly) || orderDateOnly.isAfter(startDateOnly)) &&
                   (orderDateOnly.isAtSameMomentAs(endDateOnly) || orderDateOnly.isBefore(endDateOnly));
          }
          
          return true;
        }).toList();
      }
      
      if (mounted) {
        setState(() {
          _filteredOrders = tempOrders;
        });
      }
    });
  }


  void _showFilterDialog() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    DateTime? tempStartDate = _selectedStartDate;
    DateTime? tempEndDate = _selectedEndDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.grey[100]!],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Orders',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 28,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Colors.grey),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Filter by Date Range',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: tempStartDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: AppColors.primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: AppColors.primary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          tempStartDate = pickedDate;
                                          // Ensure end date is after start date
                                          if (tempEndDate != null && tempEndDate!.isBefore(tempStartDate!)) {
                                            tempEndDate = null;
                                          }
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        tempStartDate == null
                                            ? 'Select Start Date'
                                            : 'Start: ${tempStartDate!.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(
                                          color: tempStartDate == null ? Colors.grey[600] : AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: tempEndDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: AppColors.primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: AppColors.primary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          tempEndDate = pickedDate;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        tempEndDate == null
                                            ? 'Select End Date'
                                            : 'End: ${tempEndDate!.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(
                                          color: tempEndDate == null ? Colors.grey[600] : AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedParties.clear();
                                  _selectedStartDate = null;
                                  _selectedEndDate = null;
                                  _applyFilters();
                                });
                                Navigator.of(context).pop();
                              },
                              style: AppButtonStyles.secondaryButton,
                              child: const Text(
                                'Clear Filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStartDate = tempStartDate;
                                  _selectedEndDate = tempEndDate;
                                });
                                Navigator.of(context).pop();
                                _applyFilters();
                              },
                              style: AppButtonStyles.primaryButton,
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedOrderNumbers.clear();
      }
    });
  }

  void _toggleOrderSelection(String orderNumber) {
    setState(() {
      if (_selectedOrderNumbers.contains(orderNumber)) {
        _selectedOrderNumbers.remove(orderNumber);
      } else {
        _selectedOrderNumbers.add(orderNumber);
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedOrderNumbers.isEmpty) return;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Show loading indicator
      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call the API to delete orders
      final success = await OrderApiService.bulkDeleteOrders(_selectedOrderNumbers);
      
      // Remove the loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Update local state only after successful API call
        setState(() {
          orderProvider.orders.removeWhere(
            (order) => _selectedOrderNumbers.contains(order.orderNumber),
          );
          _filteredOrders.removeWhere(
            (order) => _selectedOrderNumbers.contains(order.orderNumber),
          );
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Successfully deleted ${_selectedOrderNumbers.length} order(s)'),
              backgroundColor: Colors.green,
            ),
          );
          
          _selectedOrderNumbers.clear();
          _isSelectionMode = false;
        });
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to delete orders. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _bulkPrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing orders: ${_selectedOrderNumbers.join(", ")}'),
      ),
    );
    setState(() {
      _selectedOrderNumbers.clear();
      _isSelectionMode = false;
    });
  }

  void _bulkShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing orders: ${_selectedOrderNumbers.join(", ")}'),
      ),
    );
    setState(() {
      _selectedOrderNumbers.clear();
      _isSelectionMode = false;
    });
  }

  void _bulkDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading orders: ${_selectedOrderNumbers.join(", ")}'),
      ),
    );
    setState(() {
      _selectedOrderNumbers.clear();
      _isSelectionMode = false;
    });
  }

  Widget buildFilterButton(String label) {
    final bool isSelected = _filter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () {
          _filter = label;
          _applyFilters();
        },
        style: isSelected ? AppButtonStyles.primaryButton : AppButtonStyles.secondaryButton,
        child: Text(
          label,
          style: isSelected ? AppTextStyles.primaryButton : AppTextStyles.secondryButton,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Page title skeleton
                  Container(
                    width: double.infinity,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar skeleton
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filters row skeletons
                  Row(
                    children: List.generate(3, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  // List item skeletons
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) => Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemCount: 6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (orderProvider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(orderProvider.errorMessage, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final userId = authProvider.authData?.user.id;
                    orderProvider.fetchOrders(userId: userId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (orderProvider.orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        // Initialize filtered orders if empty or if orders have changed
        if (_filteredOrders.isEmpty || _filteredOrders.length != orderProvider.orders.length) {
          _filteredOrders = List.from(orderProvider.orders);
        }
        
        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by Order No. or Party Name',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: _showFilterDialog,
                          tooltip: 'Advanced Filter',
                        ),
                        IconButton(
                          icon: Icon(
                            _isSelectionMode ? Icons.close : Icons.check_box_outlined,
                            color: AppColors.primary,
                          ),
                          onPressed: _toggleSelectionMode,
                          tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Orders',
                        ),
                        if (_isSelectionMode)
                          IconButton(
                            icon: Icon(Icons.select_all, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                _selectedOrderNumbers.clear();
                                _selectedOrderNumbers.addAll(
                                  _filteredOrders.map((order) => order.orderNumber!),
                                );
                              });
                            },
                            tooltip: 'Select All Orders',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildFilterButton('All'),
                          buildFilterButton('Paid'),
                          buildFilterButton('Unpaid'),
                          buildFilterButton('Partial'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredOrders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    final isSelected = _selectedOrderNumbers.contains(order.orderNumber);
                    return Card(
                      elevation: 1,
                      color: isSelected ? Colors.grey[100] : Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isSelectionMode)
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  _toggleOrderSelection(order.orderNumber!);
                                },
                                activeColor: AppColors.primary,
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.orderNumber ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Date: ${order.orderDate.toString().split(' ')[0]}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        order.paymentStatus == 'Paid'
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 20,
                                        color: order.paymentStatus == 'Paid'
                                            ? Colors.green
                                            : order.paymentStatus == 'Partial'
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Status: ${order.paymentStatus}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: order.paymentStatus == 'Paid'
                                              ? Colors.green
                                              : order.paymentStatus == 'Partial'
                                              ? Colors.orange
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Amount: ₹${order.grandTotal}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Items:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: order.items!.length,
                                    itemBuilder: (context, itemIndex) {
                                      final item = order.items![itemIndex];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item?.itemName ?? 'N/A'} (Qty: ${item?.quantity ?? 0}, Price: ₹${(item?.price ?? 0) * (item?.quantity ?? 0)})',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (!_isSelectionMode) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // Navigate to AddOrderPage with the order to edit
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddOrderPage(editingOrder: order),
                                              ),
                                            ).then((_) {
                                              // Refresh the orders list when returning from edit
                                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                              final userId = authProvider.authData?.user.id;
                                              Provider.of<OrderProvider>(context, listen: false).fetchOrders(userId: userId);
                                            });
                                          },
                                          tooltip: 'Edit Order',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red[300],
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: const Text("Confirm Delete"),
                                                  content: Text("Are you sure you want to delete order ${order.orderNumber}?"),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                                                        final success = await orderProvider.deleteOrder(order.id.toString());
                                                        if (success) {
                                                          if (mounted) {
                                                            // Refresh the orders list
                                                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                                            final userId = authProvider.authData?.user.id;
                                                            await orderProvider.fetchOrders(userId: userId);
                                                            
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Text('Order ${order.orderNumber} deleted successfully'),
                                                                backgroundColor: Colors.green,
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Failed to delete order'),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          tooltip: 'Delete Order',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.print,
                                            color: Colors.black54,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Print ${order.orderNumber}"),
                                              ),
                                            );
                                          },
                                          tooltip: 'Print Order',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.share,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Share ${order.orderNumber}"),
                                              ),
                                            );
                                          },
                                          tooltip: 'Share Order',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.download,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Download ${order.orderNumber}"),
                                              ),
                                            );
                                          },
                                          tooltip: 'Download Order',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        Flexible(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 90,
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => OrderDetailPage(orderId: order.id!),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 6,
                                                  horizontal: 6,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 2,
                                                textStyle: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              child: const Text('View Details'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: _isSelectionMode
              ? null
              : FloatingActionButton.extended(
            onPressed: () {
              // Navigate to the Add Orders tab in HomeScreen
              widget.onTabSelected(3);
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 25),
            label: const Text(
              "Add Order",
              style: AppTextStyles.primaryButton,
            ),
            backgroundColor: AppColors.primary,
          ),
          bottomNavigationBar: _isSelectionMode
              ? BottomAppBar(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedOrderNumbers.length} selected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[300]),
                        onPressed: _selectedOrderNumbers.isNotEmpty ? _bulkDelete : null,
                        tooltip: 'Delete Selected',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.print,
                          color: Colors.black54,
                        ),
                        onPressed: _selectedOrderNumbers.isNotEmpty ? _bulkPrint : null,
                        tooltip: 'Print Selected',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: AppColors.primary,
                        ),
                        onPressed: _selectedOrderNumbers.isNotEmpty ? _bulkShare : null,
                        tooltip: 'Share Selected',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.blue,
                        ),
                        onPressed: _selectedOrderNumbers.isNotEmpty ? _bulkDownload : null,
                        tooltip: 'Download Selected',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              : null,
        );
      },
    );
  }
}
