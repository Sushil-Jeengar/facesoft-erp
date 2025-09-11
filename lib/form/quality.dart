import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/model/quality_model.dart';
import 'package:facesoft/providers/quality_provider.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AddQualityPage extends StatefulWidget {
  final Quality? quality;

  const AddQualityPage({super.key, this.quality});

  @override
  State<AddQualityPage> createState() => _AddQualityPageState();
}

class _AddQualityPageState extends State<AddQualityPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController codeController;
  late final TextEditingController detailsController;
  late final TextEditingController colorController;
  late final TextEditingController compositionController;
  late final TextEditingController gsmController;
  late final TextEditingController widthController;
  late bool status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.quality?.qualityName ?? '');
    codeController = TextEditingController(text: widget.quality?.qualityCode ?? '');
    detailsController = TextEditingController(text: widget.quality?.details ?? '');
    colorController = TextEditingController(text: widget.quality?.color ?? '');
    compositionController = TextEditingController(text: widget.quality?.composition ?? '');
    gsmController = TextEditingController(text: widget.quality?.gsm ?? '');
    widthController = TextEditingController(text: widget.quality?.width ?? '');
    status = widget.quality?.status ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    detailsController.dispose();
    colorController.dispose();
    compositionController.dispose();
    gsmController.dispose();
    widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.quality == null ? 'Add Quality' : 'Edit Quality'),
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
              key: _formKey,
              child: Column(
                children: [
                  _buildInput(
                    nameController,
                    'Quality Name',
                    Icons.text_fields,
                  ),
                  _buildInput(
                    codeController,
                    'Quality Code',
                    Icons.high_quality_outlined,
                  ),
                  _buildInput(
                    detailsController,
                    'Details',
                    Icons.description,
                    TextInputType.multiline,
                    4,
                  ),
                  _buildInput(colorController, 'Color', Icons.palette),
                  _buildInput(
                    compositionController,
                    'Composition',
                    Icons.layers,
                  ),
                  _buildInput(
                    gsmController,
                    'GSM (Optional)',
                    Icons.speed,
                    TextInputType.number,
                    1,
                    false,
                  ),
                  _buildInput(
                    widthController,
                    'Width (inches)',
                    Icons.straighten,
                    TextInputType.number,
                    1,
                    false,
                  ),
                  _buildDropdownField(
                    'Status',
                    Icons.toggle_on,
                    status ? 'Active' : 'Inactive',
                    ['Active', 'Inactive'],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed: _isSaving ? null : () async {
                        setState(() => _isSaving = true);
                        if (_formKey.currentState!.validate()) {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final userId = authProvider.authData?.user.id;
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User not authenticated!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Map<String, dynamic> updateData = {};
                          if (widget.quality != null) {
                            if (nameController.text != widget.quality!.qualityName) {
                              updateData['quality_name'] = nameController.text;
                            }
                            if (codeController.text != widget.quality!.qualityCode) {
                              updateData['quality_code'] = codeController.text;
                            }
                            if (detailsController.text != widget.quality!.details) {
                              updateData['details'] = detailsController.text;
                            }
                            if (colorController.text != widget.quality!.color) {
                              updateData['color'] = colorController.text;
                            }
                            if (compositionController.text != widget.quality!.composition) {
                              updateData['composition'] = compositionController.text;
                            }
                            if (gsmController.text != widget.quality!.gsm) {
                              updateData['gsm'] = gsmController.text.isEmpty ? null : gsmController.text;
                            }
                            if (widthController.text != widget.quality!.width) {
                              updateData['width'] = widthController.text.isEmpty ? null : widthController.text;
                            }
                            if (status != widget.quality!.status) {
                              updateData['status'] = status;
                            }
                          } else {
                            updateData.addAll({
                              'user_id': userId,
                              'quality_name': nameController.text,
                              'quality_code': codeController.text,
                              'details': detailsController.text,
                              'color': colorController.text,
                              'composition': compositionController.text,
                              'gsm': gsmController.text.isEmpty ? null : gsmController.text,
                              'width': widthController.text.isEmpty ? null : widthController.text,
                              'status': status,
                            });
                          }

                          try {
                            final provider = Provider.of<QualityProvider>(context, listen: false);
                            final success = widget.quality == null
                                ? await provider.createQuality(Quality.fromJson(updateData))
                                : await provider.updateQuality(widget.quality!.id!, updateData);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(widget.quality == null
                                      ? 'Quality saved successfully!'
                                      : 'Quality updated successfully!'),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to save quality'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          setState(() => _isSaving = false);
                        }
                      },
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.quality == null ? "Save Quality" : "Update Quality",
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
        bool isRequired = true,
      ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
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
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Enter $label' : null
            : null,
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
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: items
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: (val) => setState(() => status = val == 'Active'),
        validator: (val) => val == null || val.isEmpty ? 'Select $label' : null,
      ),
    );
  }
}
