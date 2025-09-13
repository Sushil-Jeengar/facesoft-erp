





import 'package:facesoft/model/agent_model.dart';
import 'package:facesoft/providers/agent_provider.dart';
import 'package:facesoft/model/transport_model.dart';
import 'package:facesoft/providers/transport_provider.dart';
import 'package:facesoft/model/parties_model.dart';
import 'package:facesoft/providers/party_provider.dart';
import 'package:facesoft/model/supplier_model.dart';
import 'package:facesoft/providers/supplier_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/model/company_model.dart';
import 'package:facesoft/providers/company_provider.dart';
import 'package:facesoft/model/item_model.dart';
import 'package:facesoft/providers/item_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:facesoft/screens/home_screen.dart';
import 'package:facesoft/model/order_model.dart';
import 'package:facesoft/API_services/order_api.dart';
import 'package:facesoft/providers/auth_provider.dart';


class AddOrderPage extends StatefulWidget {
  final Order? editingOrder; // when non-null, page is in edit mode
  const AddOrderPage({super.key, this.editingOrder});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {


  List<Company> companies = [];
  bool isLoading = true;
  Company? selectedCompany;
  List<String> companyNames = [];

  Party? selectedParty;
  List<Party> parties = [];
  bool isPartyLoading = true;

  List<Supplier> suppliers = [];
  bool isSupplierLoading = true;
  Supplier? selectedSupplier;

  List<Transport> transports = [];
  bool isTransportLoading = true;
  Transport? selectedTransport;

  List<Agent> agents = [];
  bool isAgentLoading = true;
  Agent? selectedAgent;

  List<Map<String, dynamic>> items = [];
  List<Item> allItems = [];
  bool isItemsLoading = true;
  String? selectedItemId;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController orderNumberController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController grandTotalController = TextEditingController();
  final TextEditingController subtotalController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();

  String paymentStatus = 'Paid';

  final List<String> itemParts = ['Part X', 'Part Y', 'Part Z'];
  final List<String> weightUnits = ['kg', 'gram', 'mg', 'Ton'];

  void _addItem() {
    setState(() {
      items.add({
        'partName': null,
        'partId': null,
        'quantity': TextEditingController(),
        'price': TextEditingController(),
        'weight': TextEditingController(),
        'weightUnit': 'kg',
        'description1': TextEditingController(),
        'description2': TextEditingController(),
      });
    });
    _updateTotals();
  }

  void _removeItem(int index) {
    setState(() {
      for (var controller in [
        'quantity',
        'price',
        'weight',
        'description1',
        'description2',
      ]) {
        (items[index][controller] as TextEditingController?)?.dispose();
      }
      items.removeAt(index);
    });
    _updateTotals();
  }

  Future<void> _fetchCompanies() async {
    final provider = Provider.of<CompanyProvider>(context, listen: false);
    await provider.fetchCompanies();
    setState(() {
      companies = provider.companies;
      final Set<String> seen = {};
      companyNames = companies
          .map((c) => c.name ?? '')
          .where((n) => n.isNotEmpty && seen.add(n))
          .toList();
      isLoading = false;
      // Preselect company in edit mode
      if (widget.editingOrder != null &&
          widget.editingOrder!.companyId != null &&
          companies.isNotEmpty) {
        final matches = companies.where((c) => c.id == widget.editingOrder!.companyId);
        if (matches.isNotEmpty) {
          selectedCompany = matches.first;
        }
      }
    });
  }


  Future<void> _fetchParties() async {
    final provider = Provider.of<PartyProvider>(context, listen: false);
    await provider.fetchParties();
    setState(() {
      parties = provider.parties;
      isPartyLoading = false;
      if (widget.editingOrder != null &&
          widget.editingOrder!.partyId != null &&
          parties.isNotEmpty) {
        final matches = parties.where((p) => p.id == widget.editingOrder!.partyId);
        if (matches.isNotEmpty) {
          selectedParty = matches.first;
        }
      }
    });
  }

  Future<void> _fetchSuppliers() async {
    final provider = Provider.of<SupplierProvider>(context, listen: false);
    await provider.fetchSuppliers();
    setState(() {
      suppliers = provider.suppliers;
      isSupplierLoading = false;
      if (widget.editingOrder != null &&
          widget.editingOrder!.supplierId != null &&
          suppliers.isNotEmpty) {
        final matches = suppliers.where((s) => s.id == widget.editingOrder!.supplierId);
        if (matches.isNotEmpty) {
          selectedSupplier = matches.first;
        }
      }
    });
  }

  Future<void> _fetchTransports() async {
    final provider = Provider.of<TransportProvider>(context, listen: false);
    await provider.fetchTransports();
    setState(() {
      transports = provider.transports;
      isTransportLoading = false;
      if (widget.editingOrder != null &&
          widget.editingOrder!.transportId != null &&
          transports.isNotEmpty) {
        final matches = transports.where((t) => t.id == widget.editingOrder!.transportId);
        if (matches.isNotEmpty) {
          selectedTransport = matches.first;
        }
      }
    });
  }

  Future<void> _fetchAgents() async {
    final provider = Provider.of<AgentProvider>(context, listen: false);
    await provider.fetchAgents();
    setState(() {
      agents = provider.agents;
      isAgentLoading = false;
      if (widget.editingOrder != null &&
          widget.editingOrder!.agentId != null &&
          agents.isNotEmpty) {
        final matches = agents.where((a) => a.id == widget.editingOrder!.agentId);
        if (matches.isNotEmpty) {
          selectedAgent = matches.first;
        }
      }
    });
  }


  void _updateTotals() {
    double subtotal = 0;
    for (var item in items) {
      final quantity = double.tryParse(item['quantity']!.text) ?? 0;
      final price = double.tryParse(item['price']!.text) ?? 0;
      subtotal += quantity * price;
    }
    final discount = double.tryParse(discountController.text) ?? 0;
    final tax = double.tryParse(taxAmountController.text) ?? 0;
    final grandTotal = subtotal - discount + tax;

    subtotalController.text = subtotal.toStringAsFixed(2);
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  Future<void> _selectOrderDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      orderDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }



  Widget _buildSupplierDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isSupplierLoading
          ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          : DropdownButtonFormField<Supplier>(
        value: selectedSupplier,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: AppColors.primary),
          labelText: 'Supplier Contact Person',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: suppliers
            .map((s) => DropdownMenuItem<Supplier>(
          value: s,
          child: Text(s.contactPerson ?? ''),
        ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedSupplier = val;
          });
        },
        validator: (value) => value == null ? 'Select Supplier' : null,
      ),
    );
  }

  Widget _buildPartyDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isPartyLoading
          ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          : DropdownButtonFormField<Party>(
        value: selectedParty,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: AppColors.primary),
          labelText: 'Party Contact Person',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: parties
            .map((party) => DropdownMenuItem<Party>(
          value: party,
          child: Text(party.contactPerson ?? ''),
        ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedParty = val;
          });
        },
        validator: (value) => value == null ? 'Select Party' : null,
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isLoading
          ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          : DropdownButtonFormField<Company>(
        value: selectedCompany,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.business, color: AppColors.primary),
          labelText: 'Company Name',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: companies
            .map((c) => DropdownMenuItem<Company>(
          value: c,
          child: Text(c.name ?? ''),
        ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedCompany = val;
          });
        },
        validator: (value) => value == null ? 'Select Company' : null,
      ),
    );
  }

  Widget _buildTransportDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isTransportLoading
          ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          : DropdownButtonFormField<Transport>(
        value: selectedTransport,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.local_shipping, color: AppColors.primary),
          labelText: 'Transport',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: transports
            .map((t) => DropdownMenuItem<Transport>(
          value: t,
          child: Text(t.contactPerson ?? ''),
        ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedTransport = val;
          });
        },
        validator: (value) => value == null ? 'Select Transport' : null,
      ),
    );
  }

  Widget _buildAgentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isAgentLoading
          ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          : DropdownButtonFormField<Agent>(
        value: selectedAgent,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: AppColors.primary),
          labelText: 'Agent',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: agents
            .map((a) => DropdownMenuItem<Agent>(
          value: a,
          child: Text(a.agentName ?? ''),
        ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedAgent = val;
          });
        },
        validator: (value) => value == null ? 'Select Agent' : null,
      ),
    );
  }



  @override
  void dispose() {
    orderNumberController.dispose();
    orderDateController.dispose();
    deliveryAddressController.dispose();
    discountController.dispose();
    grandTotalController.dispose();
    subtotalController.dispose();
    taxAmountController.dispose();
    for (var item in items) {
      if (item['quantity'] is TextEditingController) {
        (item['quantity'] as TextEditingController).dispose();
      }
      if (item['price'] is TextEditingController) {
        (item['price'] as TextEditingController).dispose();
      }
      if (item['weight'] is TextEditingController) {
        (item['weight'] as TextEditingController).dispose();
      }
      if (item['description1'] is TextEditingController) {
        (item['description1'] as TextEditingController).dispose();
      }
      if (item['description2'] is TextEditingController) {
        (item['description2'] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }


  Future<void> _fetchItems() async {
    try {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      await itemProvider.fetchItems();
      
      setState(() {
        allItems = itemProvider.items;
        isItemsLoading = false;
        
        // If in edit mode and we have items to pre-select
        if (widget.editingOrder != null && widget.editingOrder!.items != null) {
          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            if (item['partId'] != null) {
              // Find the matching item in allItems
              final matchedItem = allItems.firstWhere(
                (i) => i.id == item['partId'],
                orElse: () => Item(id: -1, name: ''),
              );
              if (matchedItem.id != -1) {
                // Update the partName in the items list
                items[i]['partName'] = matchedItem.name;
              }
            }
          }
        }
      });
    } catch (e) {
      setState(() => isItemsLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: $e')),
        );
      }
    }
  }

  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;
    
    if (!_formKey.currentState!.validate() || 
        items.isEmpty || 
        selectedAgent == null || 
        selectedSupplier == null ||
        selectedParty == null ||
        selectedCompany == null ||
        selectedTransport == null) {
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields and add at least one item!"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.authData?.user.id;
      
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not authenticated. Please log in again."),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      final orderData = {
        'user_id': userId,
        'company_id': selectedCompany!.id,
        'party_id': selectedParty!.id,
        'supplier_id': selectedSupplier!.id,
        'transport_id': selectedTransport!.id,
        'agent_id': selectedAgent!.id,
        'order_number': orderNumberController.text,
        'order_date': orderDateController.text,
        'party_name': selectedParty!.title ?? selectedParty!.companyName ?? '',
        'supplier': selectedSupplier!.title ?? selectedSupplier!.companyName ?? '',
        'transport': selectedTransport!.transportName ?? '',
        'delivery_address': deliveryAddressController.text,
        'payment_status': paymentStatus,
        'choose_agent': selectedAgent!.agentName ?? '',
        'description_1': '', // Add these fields to your form if needed
        'description_2': '',
        'discount': double.tryParse(discountController.text) ?? 0.0,
        'subtotal': double.tryParse(subtotalController.text) ?? 0.0,
        'tax_amount': double.tryParse(taxAmountController.text) ?? 0.0,
        'grand_total': double.tryParse(grandTotalController.text) ?? 0.0,
        'status': true,
        'icon': {
          'name': 'shopping-cart',
          'library': 'fontawesome',
          'svg': '<svg>...</svg>',
          'displayName': 'Shopping Cart'
        },
        'order_items': items.map((item) => {
          'item_id': item['partId'],
          'item_name': allItems.firstWhere(
            (i) => i.id == item['partId'],
            orElse: () => Item(id: -1, name: 'Unknown'),
          ).name,
          'price': double.tryParse(item['price']?.text ?? '0') ?? 0.0,
          'weight': double.tryParse(item['weight']?.text ?? '0') ?? 0.0,
          'quantity': int.tryParse(item['quantity']?.text ?? '0') ?? 0,
          'unit': item['weightUnit'] ?? 'kg',
          'description_1': item['description1']?.text ?? '',
          'description_2': item['description2']?.text ?? '',
        }).toList(),
      };

      if (widget.editingOrder != null && widget.editingOrder!.id != null) {
        // EDIT MODE → PUT update
        // Some backends don't accept order-level description fields; strip them on update
        final updateBody = Map<String, dynamic>.from(orderData)
          ..remove('description_1')
          ..remove('description_2');
        final success = await OrderApiService.updateOrder(
          orderId: widget.editingOrder!.id!,
          body: updateBody,
        );
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order updated successfully!'), duration: Duration(seconds: 1)),
            );
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
          }
        } else {
          throw Exception('Failed to update order');
        }
      } else {
        // CREATE MODE → POST new
        final response = await http.post(
          Uri.parse('http://192.168.1.169:5000/v1/api/admin/orders'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(orderData),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order created successfully!'),
                duration: Duration(seconds: 1),
              ),
            );
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
          }
        } else {
          throw Exception('Failed to create order: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('Order submit error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
    _fetchParties();
    _fetchSuppliers();
    _fetchTransports();
    _fetchAgents();
    _fetchItems();

    if (widget.editingOrder != null) {
      // Prefill fields in edit mode
      final o = widget.editingOrder!;
      orderNumberController.text = o.orderNumber ?? '';
      orderDateController.text = o.orderDate != null ? DateFormat('yyyy-MM-dd').format(o.orderDate!) : '';
      deliveryAddressController.text = o.deliveryAddress ?? '';
      paymentStatus = o.paymentStatus ?? paymentStatus;

      // Discount/Subtotal/Tax/Grand Total may be strings in model
      discountController.text = o.discount?.toString() ?? '';
      subtotalController.text = o.subtotal?.toString() ?? '';
      taxAmountController.text = o.taxAmount?.toString() ?? '';
      grandTotalController.text = o.grandTotal?.toString() ?? '';

      // Prefill items
      if (o.items != null && o.items!.isNotEmpty) {
        for (final it in o.items!) {
          final itemMap = {
            'partName': it.itemName,
            'partId': it.itemId,
            'quantity': TextEditingController(text: (it.quantity ?? 0).toString()),
            'price': TextEditingController(text: (it.price ?? 0).toString()),
            'weight': TextEditingController(text: (it.weight ?? 0).toString()),
            'weightUnit': it.unit ?? 'kg',
            'description1': TextEditingController(text: it.description1 ?? ''),
            'description2': TextEditingController(text: it.description2 ?? ''),
          };
          items.add(itemMap);
        }
        // Update totals after prefill
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateTotals());
      }
    } else {
      // Set initial order number for create mode
      orderNumberController.text = 'ORD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInput(
                        orderNumberController,
                        'Order Number',
                        Icons.confirmation_number,
                      ),
                      _buildDateInput(
                        orderDateController,
                        'Order Date',
                        Icons.calendar_today,
                        context,
                      ),
                      _buildCompanyDropdown(),
                      _buildPartyDropdown(),
                      _buildSupplierDropdown(),
                      _buildTransportDropdown(),
                      _buildInput(
                        deliveryAddressController,
                        'Delivery Address',
                        Icons.location_on,
                      ),
                      _buildDropdownField(
                        'Payment Status',
                        ['Paid', 'Unpaid', 'Partial'],
                        paymentStatus,
                        (val) => setState(() => paymentStatus = val!),
                      ),
                      _buildAgentDropdown(),
                    ],
                  ),
                ),
              ),
              
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildItemInput(index, item);
                      }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Item',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInput(
                        discountController,
                        'Discount',
                        Icons.percent,
                        TextInputType.number,
                      ),
                      _buildInput(
                        subtotalController,
                        'Subtotal',
                        Icons.calculate,
                        TextInputType.number,
                        true, // readOnly
                      ),
                      _buildInput(
                        taxAmountController,
                        'Tax Amount',
                        Icons.request_quote,
                        TextInputType.number,
                      ),
                      _buildInput(
                        grandTotalController,
                        'Grand Total',
                        Icons.attach_money,
                        TextInputType.number,
                        true, // readOnly
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: _isSubmitting
                            ? Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitOrder,
                                style: AppButtonStyles.primaryButton,
                                child: Text(
                                  widget.editingOrder != null ? "Update Order" : "Submit Order",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType inputType = TextInputType.text,
    bool readOnly = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        readOnly: readOnly,
        onChanged: (value) => _updateTotals(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator:
            readOnly
                ? null
                : (value) =>
                    value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDateInput(
    TextEditingController controller,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectOrderDate(context),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          suffixIcon: const Icon(Icons.edit_calendar, color: AppColors.primary),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Select $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person, color: AppColors.primary),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Select $label' : null,
      ),
    );
  }

  Widget _buildItemInput(int index, Map<String, dynamic> item) {
    // Get the current item's name if it exists
    String? currentItemName = item['partName'];
    
    // Find the current item in allItems if we have a partId
    Item? currentItem;
    if (item['partId'] != null) {
      currentItem = allItems.firstWhere(
        (i) => i.id == item['partId'],
        orElse: () => Item(name: 'Loading...', id: item['partId']), // Changed to use item['partId']
      );
      
      // If we found the item and it has a name, use it
      if (currentItem.name != null && currentItem.name!.isNotEmpty) {
        currentItemName = currentItem.name;
        // Update the item in the items list
        items[index]['partName'] = currentItemName;
      } else if (item['partName'] != null) {
        // If we have a partName from the order, use it
        currentItemName = item['partName'];
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Item Name Dropdown
          isItemsLoading
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: item['partId']?.toString(),
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.inventory_2,
                      color: AppColors.primary,
                    ),
                    labelStyle: const TextStyle(color: AppColors.primary),
                    hintText: currentItemName ?? 'Select an item',
                  ),
                  items: [
                    // First add the current item if it exists but not in allItems
                    if (item['partId'] != null && !allItems.any((i) => i.id == item['partId']) && currentItemName != null)
                      DropdownMenuItem<String>(
                        value: item['partId'].toString(),
                        child: Text(currentItemName),
                      ),
                    // Then add all other items
                    ...allItems.map((i) => DropdownMenuItem<String>(
                      value: i.id.toString(),
                      child: Text(i.name),
                    )),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      final selected = allItems.firstWhere(
                        (element) => element.id.toString() == val,
                        orElse: () => Item(id: -1, name: 'Unknown'),
                      );
                      setState(() {
                        item['partId'] = selected.id;
                        item['partName'] = selected.name ?? 'Unknown';
                        // Auto-fill price if available
                        if (selected.price != null &&
                            selected.price!.isNotEmpty) {
                          item['price'].text = selected.price!;
                        }
                        if (selected.weight != null &&
                            selected.weight!.isNotEmpty) {
                          item['weight'].text = selected.weight!;
                        }
                        _updateTotals();
                      });
                    }
                  },
                  validator: (val) =>
                      val == null ? 'Please select an item' : null,
                ),
          const SizedBox(height: 8),
          // Quantity and Price Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item['quantity'],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.numbers,
                      color: AppColors.primary,
                    ),
                    labelStyle: const TextStyle(color: AppColors.primary),
                  ),
                  onChanged: (value) => _updateTotals(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Quantity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: item['price'],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.primary,
                    ),
                    labelStyle: const TextStyle(color: AppColors.primary),
                  ),
                  onChanged: (value) => _updateTotals(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Price';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid positive price';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[300]),
                onPressed: () => _removeItem(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weight and Unit Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: item['weight'],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                    ),
                    labelStyle: const TextStyle(color: AppColors.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Weight';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid positive weight';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: item['weightUnit'],
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: const TextStyle(color: AppColors.primary),
                  ),
                  items:
                      weightUnits
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => item['weightUnit'] = val),
                  validator: (val) => val == null ? 'Select Unit' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: item['description1'],
            decoration: InputDecoration(
              labelText: 'Description 1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(
                Icons.description,
                color: AppColors.primary,
              ),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: item['description2'],
            decoration: InputDecoration(
              labelText: 'Description 2',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(
                Icons.description,
                color: AppColors.primary,
              ),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
