import 'dart:io';
import 'dart:convert';
import 'package:facesoft/model/supplier_model.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/providers/supplier_provider.dart';
import 'package:flutter/material.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddSupplierPage extends StatefulWidget {
  final Supplier? supplier;
  const AddSupplierPage({super.key, this.supplier});
  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  bool _isAddingSupplier = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneCodeController = TextEditingController(
    text: '+91',
  );
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  String country = '';
  String state = '';
  String city = '';
  String phoneCode = '+91';
  bool status = true;
  File? logoImage;
  final ImagePicker picker = ImagePicker();
  Country selectedCountry = Country.parse('IN');
  Country selectedPhoneCountry = Country.parse('IN');
  List<dynamic>? _countriesData;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      companyNameController.text = widget.supplier!.companyName ?? '';
      gstNumberController.text = widget.supplier!.gst ?? '';
      emailController.text = widget.supplier!.email ?? '';
      phoneController.text = widget.supplier!.phone ?? '';
      addressController.text = widget.supplier!.address ?? '';
      noteController.text = widget.supplier!.note ?? '';
      countryController.text = widget.supplier!.country ?? '';
      stateController.text = widget.supplier!.state ?? '';
      cityController.text = widget.supplier!.city ?? '';
      phoneCodeController.text = widget.supplier!.phoneCode ?? '+91';
      pincodeController.text = widget.supplier!.code ?? '';
      contactPersonController.text = widget.supplier!.contactPerson ?? '';
      status = widget.supplier!.status ?? true;
      country = widget.supplier!.country ?? '';
      state = widget.supplier!.state ?? '';
      city = widget.supplier!.city ?? '';
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter Email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }


  Future<void> pickLogo() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      logoImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      logoImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          selectedPhoneCountry = country;
          phoneCode = '+${country.phoneCode}';
          phoneCodeController.text = phoneCode;
        });
      },
    );
  }

  void _showCountryOnlyPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country countrySel) {
        setState(() {
          selectedCountry = countrySel;
          countryController.text = countrySel.name;
          country = countrySel.name;
          stateController.clear();
          cityController.clear();
          state = '';
          city = '';
        });
      },
    );
  }

  Future<void> _ensureLocationDataLoaded() async {
    if (_countriesData != null) return;
    final String jsonString = await rootBundle.loadString(
      'packages/country_state_city_picker/lib/assets/country.json',
    );
    _countriesData = List<dynamic>.from(
      (json.decode(jsonString) as List<dynamic>),
    );
  }

  Future<void> _showStateOnlyPicker() async {
    if (countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select country first')),
      );
      return;
    }
    await _ensureLocationDataLoaded();
    final List<dynamic> matches = _countriesData
        ?.where((c) => (c as Map<String, dynamic>)['name'] == countryController.text)
        .toList() ?? [];
    final List<dynamic>? stateObjs = matches.isNotEmpty
        ? (matches.first as Map<String, dynamic>)['state'] as List<dynamic>?
        : null;
    final List<String> states = stateObjs
        ?.map((s) => (s as Map<String, dynamic>)['name'].toString())
        .toList() ?? [];
    if (states.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No states found for selected country')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            itemCount: states.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final String stateName = states[index];
              return ListTile(
                title: Text(stateName),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    stateController.text = stateName;
                    state = stateName;
                    cityController.clear();
                    city = '';
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showCityOnlyPicker() async {
    if (countryController.text.isEmpty || stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select state first')),
      );
      return;
    }
    await _ensureLocationDataLoaded();
    final List<dynamic> countryMatches = _countriesData
        ?.where((c) => (c as Map<String, dynamic>)['name'] == countryController.text)
        .toList() ?? [];
    final Map<String, dynamic>? countryObj = countryMatches.isNotEmpty
        ? countryMatches.first as Map<String, dynamic>
        : null;
    final List<dynamic>? stateObjs = countryObj != null
        ? countryObj['state'] as List<dynamic>?
        : null;
    final List<dynamic> stateMatches = stateObjs
        ?.where((s) => (s as Map<String, dynamic>)['name'] == stateController.text)
        .toList() ?? [];
    final Map<String, dynamic>? stateObj = stateMatches.isNotEmpty
        ? stateMatches.first as Map<String, dynamic>
        : null;
    final List<dynamic>? cityObjs = stateObj != null
        ? stateObj['city'] as List<dynamic>?
        : null;
    final List<String> cities = cityObjs
        ?.map((c) => (c as Map<String, dynamic>)['name'].toString())
        .toList() ?? [];
    if (cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cities found for selected state')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            itemCount: cities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final String cityName = cities[index];
              return ListTile(
                title: Text(cityName),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    cityController.text = cityName;
                    city = cityName;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.supplier == null ? 'Add Supplier' : 'Edit Supplier'),
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
                  // Image Upload
                  GestureDetector(
                    onTap: pickLogo,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: logoImage != null
                          ? FileImage(logoImage!)
                          : (widget.supplier != null && (widget.supplier!.image ?? '').isNotEmpty)
                          ? NetworkImage(widget.supplier!.image!)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: (logoImage == null && (widget.supplier?.image == null || widget.supplier!.image!.isEmpty))
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Upload Logo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Company Name
                  _buildInput(
                    companyNameController,
                    'Company Name',
                    Icons.business,
                  ),
                  // Contact Person
                  _buildInput(
                    contactPersonController,
                    'Contact Person',
                    Icons.contacts,
                  ),
                  // GST Number
                  _buildInput(
                    gstNumberController,
                    'GST Number',
                    Icons.receipt,
                    TextInputType.text,
                    false,
                    null,
                    15,
                  ),
                  // Email
                  _buildInput(
                    emailController,
                    'Email',
                    Icons.email,
                    TextInputType.emailAddress,
                    true, // isRequired
                    _validateEmail, // Pass the validator here
                  ),
                  // Mobile Number with Country Code
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: const TextStyle(color: AppColors.primary),
                        prefixIcon: GestureDetector(
                          onTap: _showCountryCodePicker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 10),
                              Text(
                                selectedPhoneCountry.flagEmoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                phoneCode,
                                style: const TextStyle(color: Colors.black),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter Mobile Number' : null,
                    ),
                  ),
                  // Address
                  _buildInput(
                    addressController,
                    'Address',
                    Icons.home,
                    TextInputType.streetAddress,
                  ),
                  // PinCode
                  _buildInput(
                    pincodeController,
                    'PinCode',
                    Icons.location_on,
                    TextInputType.number,
                    false,
                    null,
                    6,
                  ),
                  // Country
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: countryController,
                      readOnly: true,
                      onTap: _showCountryOnlyPicker,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.public,
                          color: AppColors.primary,
                        ),
                        labelText: 'Country',
                        labelStyle: const TextStyle(color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Select country' : null,
                    ),
                  ),
                  // State
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: stateController,
                      readOnly: true,
                      onTap: _showStateOnlyPicker,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        labelText: 'State',
                        labelStyle: const TextStyle(color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Select state' : null,
                    ),
                  ),
                  // City
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: cityController,
                      readOnly: true,
                      onTap: _showCityOnlyPicker,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_city,
                          color: AppColors.primary,
                        ),
                        labelText: 'City',
                        labelStyle: const TextStyle(color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Select city' : null,
                    ),
                  ),
                  // Status Dropdown
                  _buildDropdownField(
                    'Status',
                    Icons.toggle_on,
                    status ? 'Active' : 'Inactive',
                    ['Active', 'Inactive'],
                  ),
                  // Note
                  _buildInput(
                    noteController,
                    'Note (Optional)',
                    Icons.note,
                    TextInputType.text,
                    false,
                  ),
                  const SizedBox(height: 20),
                  // Add Supplier Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAddingSupplier
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isAddingSupplier = true);
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final supplierProvider = Provider.of<SupplierProvider>(
                            context,
                            listen: false,
                          );
                          Map<String, dynamic> supplierData = {};
                          if (widget.supplier != null) {
                            supplierData['user_id'] = authProvider.authData!.user.id;
                            // For update, only include changed fields
                            if (companyNameController.text != widget.supplier!.companyName) {
                              supplierData['company_name'] = companyNameController.text;
                            }
                            if (gstNumberController.text != widget.supplier!.gst) {
                              supplierData['gst'] = gstNumberController.text;
                            }
                            if (emailController.text != widget.supplier!.email) {
                              supplierData['email'] = emailController.text;
                            }
                            if (phoneController.text != widget.supplier!.phone) {
                              supplierData['phone'] = phoneController.text;
                            }
                            if (addressController.text != widget.supplier!.address) {
                              supplierData['address'] = addressController.text;
                            }
                            if (noteController.text != widget.supplier!.note) {
                              supplierData['note'] = noteController.text;
                            }
                            if (countryController.text != widget.supplier!.country) {
                              supplierData['country'] = countryController.text;
                            }
                            if (stateController.text != widget.supplier!.state) {
                              supplierData['state'] = stateController.text;
                            }
                            if (cityController.text != widget.supplier!.city) {
                              supplierData['city'] = cityController.text;
                            }
                            if (phoneCodeController.text != widget.supplier!.phoneCode) {
                              supplierData['phone_code'] = phoneCodeController.text;
                            }
                            if (pincodeController.text != widget.supplier!.code) {
                              supplierData['code'] = pincodeController.text;
                            }
                            if (contactPersonController.text != widget.supplier!.contactPerson) {
                              supplierData['contact_person'] = contactPersonController.text;
                            }
                            if (widget.supplier != null && status != widget.supplier!.status) {
                              supplierData['status'] = status;
                            }
                          } else {
                            // For create, include all fields
                            supplierData = {
                              'user_id': authProvider.authData!.user.id,
                              'company_name': companyNameController.text,
                              'contact_person': contactPersonController.text,
                              'email': emailController.text,
                              'phone': phoneController.text,
                              'phone_code': phoneCode,
                              'gst': gstNumberController.text,
                              'opening_balance': "0",
                              'code': pincodeController.text,
                              'city': cityController.text,
                              'state': stateController.text,
                              'country': countryController.text,
                              'address': addressController.text,
                              'status': status,
                              'owner_name': "Owner Name",
                            };
                          }
                          try {
                            final result = widget.supplier == null
                                ? await supplierProvider.addSupplier(
                              supplierData,
                              imageFile: logoImage,
                            )
                                : await supplierProvider.updateSupplier(
                              widget.supplier!.id!,
                              supplierData,
                              imageFile: logoImage,
                            );
                            if (result['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.supplier == null
                                        ? 'Supplier added successfully!'
                                        : 'Supplier updated successfully!',
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result is Map<String, dynamic>
                                        ? result['message'] ?? 'Failed to save supplier'
                                        : 'Failed to save supplier',
                                  ),
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
                          } finally {
                            setState(() => _isAddingSupplier = false);
                          }
                        }
                      },
                      style: AppButtonStyles.primaryButton,
                      child: _isAddingSupplier
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        widget.supplier == null ? "Add Supplier" : "Update Supplier",
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
        String? Function(String?)? validator,
        int? maxLength,
      ]) {
    List<TextInputFormatter>? inputFormatters;
    if (label == 'Mobile Number' || label == 'PinCode') {
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        controller: controller,
        keyboardType: inputType,
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
        validator: validator ??
            (isRequired
                ? (value) => value == null || value.isEmpty ? 'Enter $label' : null
                : null),
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      IconData icon,
      String currentValue, // This will display 'Active'/'Inactive'
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
        validator: (value) => value == null || value.isEmpty ? 'Select $label' : null,
      ),
    );
  }
}
