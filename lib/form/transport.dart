import 'package:country_picker/country_picker.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/providers/transport_provider.dart';
import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/model/transport_model.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddTransportPage extends StatefulWidget {
  final Transport? transport;
  const AddTransportPage({super.key, this.transport});

  @override
  State<AddTransportPage> createState() => _AddTransportPageState();
}

class _AddTransportPageState extends State<AddTransportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController phoneCodeController = TextEditingController(text: '+91');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // New: Address Controller
  String? selectedTransportType;
  String? selectedPartyType;
  String phoneCode = '+91';
  Country selectedCountry = Country.parse('IN');
  bool status = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.transport != null) {
      final transport = widget.transport!;
      nameController.text = transport.transportName ?? '';
      contactPersonController.text = transport.contactPerson ?? '';
      emailController.text = transport.email ?? '';
      noteController.text = transport.note ?? '';
      gstController.text = transport.gst ?? '';
      addressController.text = transport.address ?? ''; // Load address
      selectedTransportType = transport.transportType;
      selectedPartyType = transport.partyType;
      status = transport.status ?? true;

      // Split phone: last 10 digits -> phoneController, remaining prefix -> phoneCode
      final fullPhone = transport.phone ?? '';
      final digitsOnly = fullPhone.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 10) {
        final last10Digits = digitsOnly.substring(digitsOnly.length - 10);
        final prefixDigits = digitsOnly.substring(0, digitsOnly.length - 10);
        phoneController.text = last10Digits;
        if (prefixDigits.isNotEmpty) {
          phoneCode = '+$prefixDigits';
          phoneCodeController.text = phoneCode;
        } else {
          phoneCodeController.text = phoneCode;
        }
      } else {
        // Fallbacks if fewer than 10 digits
        if (fullPhone.startsWith('+')) {
          final codeOnly = RegExp(r'^\+\d+').stringMatch(fullPhone) ?? '+91';
          phoneCode = codeOnly;
          phoneCodeController.text = phoneCode;
          phoneController.text = fullPhone.replaceAll(RegExp(r'\D'), '');
        } else {
          phoneController.text = digitsOnly;
          phoneCodeController.text = phoneCode;
        }
      }
    }
  }

  void _showCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
          phoneCode = '+${country.phoneCode}';
          phoneCodeController.text = phoneCode;
        });
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    noteController.dispose();
    gstController.dispose();
    addressController.dispose(); // Dispose address controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.transport != null ? 'Edit Transport' : 'Add Transport'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
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
                    'Transport Name',
                    Icons.local_shipping,
                  ),
                  _buildDropdownField(
                    'Transport Type',
                    Icons.category,
                    selectedTransportType,
                    ['Road', 'Train', 'Air', 'Ship', 'Other'],
                        (newValue) {
                      setState(() {
                        selectedTransportType = newValue;
                      });
                    },
                  ),
                  _buildInput(
                    gstController,
                    'GST Number',
                    Icons.receipt,
                    TextInputType.text,
                    false,
                    false,
                  ),
                  _buildInput(
                    contactPersonController,
                    'Contact Person',
                    Icons.person,
                  ),
                  _buildInput(
                    phoneController,
                    'Phone Number',
                    Icons.phone,
                    TextInputType.phone,
                    true,
                    true,
                    [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    true,
                  ),
                  _buildInput(
                    emailController,
                    'Email (optional)',
                    Icons.email,
                    TextInputType.emailAddress,
                    false,
                    false,
                  ),
                  _buildInput(
                    addressController, // New: Address field
                    'Address (optional)',
                    Icons.home,
                    TextInputType.streetAddress,
                    false,
                    false,
                  ),
                  _buildInput(
                    noteController,
                    'Description (optional)',
                    Icons.description,
                    TextInputType.multiline,
                    false,
                    false,
                  ),
                  _buildDropdownField(
                    'Party Type',
                    Icons.group,
                    selectedPartyType,
                    [ 'Customer', 'Vendor', 'Both'],
                        (newValue) {
                      setState(() {
                        selectedPartyType = newValue;
                      });
                    },
                  ),
                  _buildDropdownField(
                    'Status',
                    Icons.toggle_on,
                    status ? 'Active' : 'Inactive',
                    ['Active', 'Inactive'],
                        (newValue) {
                      setState(() {
                        status = newValue == 'Active';
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed: _isSaving ? null : () async {
                        setState(() => _isSaving = true);
                        if (!_formKey.currentState!.validate()) return;
                        
                        final transportProvider = Provider.of<TransportProvider>(context, listen: false);
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final userId = authProvider.authData?.user.id;
                        
                        if (userId == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User not authenticated!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        try {
                          bool success;
                          
                          if (widget.transport != null) {
                            // Update existing transport
                            final updateData = {
                              'user_id' : userId,
                              'transport_name': nameController.text,
                              'contact_person': contactPersonController.text,
                              'phone': '$phoneCode${phoneController.text}',
                              'phone_code': phoneCode,
                              'email': emailController.text,
                              'note': noteController.text,
                              'gst': gstController.text,
                              'address': addressController.text,
                              'transport_type': selectedTransportType,
                              'party_type': selectedPartyType,
                              'status': status,
                            };
                            
                            success = await transportProvider.updateTransport(
                              widget.transport!.id!,
                              updateData,
                            );
                          } else {
                            // Create new transport
                            final newTransport = Transport(
                              userId: userId,
                              transportName: nameController.text,
                              contactPerson: contactPersonController.text,
                              phone: '$phoneCode${phoneController.text}',
                              phoneCode: phoneCode,
                              email: emailController.text,
                              note: noteController.text,
                              gst: gstController.text,
                              address: addressController.text,
                              transportType: selectedTransportType,
                              partyType: selectedPartyType,
                              status: status,
                            );
                            
                            success = await transportProvider.createTransport(newTransport);
                          }

                          if (!mounted) return;
                          
                          if (success) {
                            Navigator.of(context).pop(true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.transport != null 
                                    ? 'Failed to update transport' 
                                    : 'Failed to save transport',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('An error occurred. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        setState(() => _isSaving = false);
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
                              widget.transport != null ? 'Update Transport' : 'Save Transport',
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
        bool isRequired = true,
        bool isFieldRequired = true,
        List<TextInputFormatter>? inputFormatters,
        bool isPhoneField = false,
      ]) {
    if (label == 'GST Number') {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))];
    } else if (label == 'Phone Number') {
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    }

    if (isPhoneField) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          inputFormatters: inputFormatters,
          onChanged: (value) {
            if (label == 'GST Number') {
              final upper = value.toUpperCase();
              if (upper != value) {
                controller.value = controller.value.copyWith(
                  text: upper,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: upper.length),
                  ),
                );
              }
            }
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.primary),
            prefixIcon: GestureDetector(
              onTap: _showCountryCodePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  Text(
                    selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(phoneCode, style: const TextStyle(color: Colors.black)),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (value) {
            if (isFieldRequired && (value == null || value.isEmpty)) {
              return 'Enter $label';
            }
            if (value !=null && value.isNotEmpty && value.length != 10) {
              return 'Phone number must be 10 digits';
            }
            return null;
          },
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          inputFormatters: inputFormatters,
          onChanged: (value) {
            if (label == 'GST Number') {
              final upper = value.toUpperCase();
              if (upper != value) {
                controller.value = controller.value.copyWith(
                  text: upper,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: upper.length),
                  ),
                );
              }
            }
          },
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
          validator: (value) {
            if (isFieldRequired && (value == null || value.isEmpty)) {
              return 'Enter $label';
            }
            if (label == 'GST Number' && value != null && value.isNotEmpty) {
              if (value.length != 15) {
                return 'GST Number must be 15 characters';
              }
            }
            else if (label.toLowerCase().contains('email') && value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email';
              }
            }
            return null;
          },
        ),
      );
    }
  }

  Widget _buildDropdownField(
      String label,
      IconData icon,
      String? currentValue,
      List<String> items,
      ValueChanged<String?> onChanged,
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
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: onChanged,
        validator: (val) => val == null || val.isEmpty ? 'Select $label' : null,
      ),
    );
  }
}
