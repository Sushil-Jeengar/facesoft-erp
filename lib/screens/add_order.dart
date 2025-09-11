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
import 'package:provider/provider.dart';


class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

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


  final _formKey = GlobalKey<FormState>();

  final TextEditingController orderNumberController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController grandTotalController = TextEditingController();
  final TextEditingController subtotalController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();

  String paymentStatus = 'Paid';



  // Predefined lists
  final List<String> itemParts = ['Part X', 'Part Y', 'Part Z'];
  final List<String> weightUnits = ['kg', 'gram', 'mg', 'Ton'];

  final List<Map<String, dynamic>> items = [];

  void _addItem() {
    setState(() {
      items.add({
        'partName': null,
        'quantity': TextEditingController(),
        'price': TextEditingController(),
        'weight': TextEditingController(),
        'weightUnit': 'kg', // Default unit
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
    });
  }


  Future<void> _fetchParties() async {
    final provider = Provider.of<PartyProvider>(context, listen: false);
    await provider.fetchParties();
    setState(() {
      parties = provider.parties;
      isPartyLoading = false;
    });
  }

  Future<void> _fetchSuppliers() async {
    final provider = Provider.of<SupplierProvider>(context, listen: false);
    await provider.fetchSuppliers();
    setState(() {
      suppliers = provider.suppliers;
      isSupplierLoading = false;
    });
  }

  Future<void> _fetchTransports() async {
    final provider = Provider.of<TransportProvider>(context, listen: false);
    await provider.fetchTransports();
    setState(() {
      transports = provider.transports;
      isTransportLoading = false;
    });
  }

  Future<void> _fetchAgents() async {
    final provider = Provider.of<AgentProvider>(context, listen: false);
    await provider.fetchAgents();
    setState(() {
      agents = provider.agents;
      isAgentLoading = false;
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
          ? const Center(child: CircularProgressIndicator())
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
          ? const Center(child: CircularProgressIndicator())
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
          ? const Center(child: CircularProgressIndicator())
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
          ? const Center(child: CircularProgressIndicator())
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
          ? const Center(child: CircularProgressIndicator())
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
      item['quantity']?.dispose();
      item['price']?.dispose();
      item['weight']?.dispose();
      item['description1']?.dispose();
      item['description2']?.dispose();
    }
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _fetchCompanies();
    _fetchParties();
    _fetchSuppliers();
    _fetchTransports();
    _fetchAgents();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 1,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            items.isNotEmpty &&
                            selectedAgent != null &&
                            selectedSupplier != null) {
                          // Print item details and supplier for debugging
                          // print('Supplier: $selectedSupplier');
                          for (var i = 0; i < items.length; i++) {
                            // final item = items[i];
                            // print(
                            //   'Item ${i + 1} - Name: ${item['partName']}, '
                            //   'Quantity: ${item['quantity'].text}, '
                            //   'Price: ${item['price'].text}, '
                            //   'Weight: ${item['weight'].text} ${item['weightUnit']}, '
                            //   'Description 1: ${item['description1'].text}, '
                            //   'Description 2: ${item['description2'].text}',
                            // );
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Order submitted successfully!"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please add at least one item, select an agent, and select a supplier!",
                              ),
                            ),
                          );
                        }
                      },
                      style: AppButtonStyles.primaryButton,
                      child: const Text(
                        "Submit Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Item Name Dropdown
          DropdownButtonFormField<String>(
            value: item['partName'],
            decoration: InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(
                Icons.description,
                color: AppColors.primary,
              ),
              labelStyle: const TextStyle(color: AppColors.primary),
            ),
            items:
                itemParts
                    .map(
                      (part) =>
                          DropdownMenuItem(value: part, child: Text(part)),
                    )
                    .toList(),
            onChanged: (val) => setState(() => item['partName'] = val),
            validator: (val) => val == null ? 'Select Item Name' : null,
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
                      Icons.currency_rupee,
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
