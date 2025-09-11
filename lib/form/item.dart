import 'package:facesoft/model/item_model.dart';
import 'package:facesoft/providers/item_provider.dart';
import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:provider/provider.dart';

class AddItemPage extends StatefulWidget {
  final Item? item;
  const AddItemPage({super.key, this.item});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {


  // Single item form with controllers and key
  final Map<String, dynamic> _item = {
    'nameController': TextEditingController(),
    'quantityController': TextEditingController(),
    'priceController': TextEditingController(),
    'unitController': TextEditingController(),
    'weightController': TextEditingController(),
    'formKey': GlobalKey<FormState>(),
  };

  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form if an item is provided
    if (widget.item != null) {
      _item['nameController'].text = widget.item!.name;
      _item['quantityController'].text = widget.item!.quantity?.toString() ?? '';
      _item['priceController'].text = widget.item!.price ?? '';
      _item['unitController'].text = widget.item!.unit ?? '';
      _item['weightController'].text = widget.item!.weight ?? '';
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _item['nameController'].dispose();
    _item['quantityController'].dispose();
    _item['priceController'].dispose();
    _item['unitController'].dispose();
    _item['weightController'].dispose();
    super.dispose();
  }

  // Helper widget for consistent input fields
  Widget _buildInput(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType inputType = TextInputType.text,
        String? Function(String?)? validator,
      ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
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
        validator ??
                (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _item['formKey'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  _buildInput(
                    _item['nameController'],
                    'Item Name',
                    Icons.fastfood_outlined,
                    TextInputType.text,
                  ),
                  // Quantity (commented out to send only name)
                  // _buildInput(
                  //   _item['quantityController'],
                  //   'Quantity',
                  //   Icons.numbers,
                  //   TextInputType.number,
                  //       (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Enter Quantity';
                  //     }
                  //     if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  //       return 'Enter a valid positive number';
                  //     }
                  //     return null;
                  //   },
                  // ),

                  // Weight & Unit
                  // Weight & Unit (commented out to send only name)
                  // Row(
                  //   children: [
                  //     // Weight Field
                  //     Expanded(
                  //       child: _buildInput(
                  //         _item['weightController'],
                  //         'Weight',
                  //         Icons.monitor_weight,
                  //         TextInputType.number,
                  //             (value) {
                  //           if (value == null || value.isEmpty) {
                  //             return 'Enter Weight';
                  //           }
                  //           if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  //             return 'Enter a valid positive weight';
                  //           }
                  //           return null;
                  //         },
                  //       ),
                  //     ),
                  //     const SizedBox(width: 10),
                  //     // Unit Dropdown
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(bottom: 16),
                  //         child: DropdownButtonFormField<String>(
                  //           value: _selectedUnit,
                  //           decoration: InputDecoration(
                  //             labelText: 'Unit',
                  //             labelStyle: const TextStyle(color: AppColors.primary),
                  //             border: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(color: AppColors.primary),
                  //             ),
                  //           ),
                  //           items: ['mg', 'Gram', 'Kg', 'Ton']
                  //               .map((unit) => DropdownMenuItem(
                  //             value: unit,
                  //             child: Text(unit),
                  //           ))
                  //               .toList(),
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _selectedUnit = value;
                  //             });
                  //           },
                  //           validator: (value) => value == null ? 'Select a unit' : null,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Price
                  // Price (commented out to send only name)
                  // _buildInput(
                  //   _item['priceController'],
                  //   'Price (₹)',
                  //   Icons.attach_money,
                  //   TextInputType.number,
                  //       (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Enter Price';
                  //     }
                  //     if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  //       return 'Enter a valid positive price';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 16),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed: () async {
                        if (_item['formKey'].currentState!.validate()) {
                          // Create an Item object from the form data
                          Item itemToSave = Item(
                            id: widget.item?.id, // Include id if editing
                            name: _item['nameController'].text,
                            // quantity: int.tryParse(_item['quantityController'].text),
                            // unit: _item['unitController'].text,
                            // weight: _item['weightController'].text,
                            // price: _item['priceController'].text,
                          );

                          // Call createItem or updateItem based on whether an item is provided
                          bool success;
                          if (widget.item == null) {
                            success = await Provider.of<ItemProvider>(context, listen: false)
                                .createItem(itemToSave);
                          } else {
                            success = await Provider.of<ItemProvider>(context, listen: false)
                                .updateItem(widget.item!.id.toString(), itemToSave);
                          }

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item saved successfully!')),
                            );
                            // Optionally navigate back after saving
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to save item. Please try again.')),
                            );
                          }
                        }
                      },
                      child: Text(
                        widget.item == null ? 'Save Item' : 'Update Item',
                        style: AppTextStyles.primaryButton,
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
}
