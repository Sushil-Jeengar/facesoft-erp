import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';

class AddPlanPage extends StatefulWidget {
  const AddPlanPage({super.key});

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController validityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController featuresController = TextEditingController();
  final TextEditingController trialController = TextEditingController();

  String status = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput(nameController, 'Plan Name', Icons.text_fields),
                  _buildInput(
                    companyController,
                    'Company Name',
                    Icons.business,
                  ),
                  _buildInput(
                    validityController,
                    'Validity (days)',
                    Icons.calendar_today,
                    TextInputType.number,
                  ),
                  _buildInput(
                    priceController,
                    'Price',
                    Icons.attach_money,
                    TextInputType.number,
                  ),
                  _buildInput(
                    featuresController,
                    'Features',
                    Icons.featured_play_list,
                    TextInputType.multiline,
                    4,
                  ),
                  _buildInput(
                    trialController,
                    'Free Trial Days',
                    Icons.timelapse,
                    TextInputType.number,
                  ),
                  _buildDropdownField('Status', Icons.toggle_on, status, [
                    'Active',
                    'Inactive',
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.secondaryButton,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plan saved!')),
                          );
                        }
                      },
                      child: Text(
                        "Save Plan",
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

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    String currentValue,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items:
            items
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
        onChanged: (val) => setState(() => status = val!),
        validator: (val) => val == null || val.isEmpty ? 'Select $label' : null,
      ),
    );
  }
}
