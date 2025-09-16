import 'dart:io';
import 'dart:convert';
import 'package:facesoft/model/company_model.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/providers/company_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:country_picker/country_picker.dart';

import 'package:facesoft/style/app_style.dart';
import 'package:provider/provider.dart';

class AddCompanyPage extends StatefulWidget {
  final Company? company;

  const AddCompanyPage({super.key, this.company});

  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {

  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController addressController =
      TextEditingController(); // Added address controller
  final TextEditingController phoneCodeController = TextEditingController(
    text: '+91',
  );

  String country = '';
  String state = '';
  String city = '';
  bool isActive = true;

  Country selectedCountry = Country.parse('IN');
  Country selectedPhoneCountry = Country.parse('IN');
  String phoneCode = '+91';

  File? logoImage;
  final ImagePicker picker = ImagePicker();

  late Company? company = widget.company;


  List<dynamic>? _countriesData;
  List<String> _availableStates = [];
  List<String> _availableCities = [];

  @override
  void initState() {
    super.initState();
    print(widget.company);
    if (widget.company != null) {
      final company = widget.company!;
      nameController.text = company.name!;
      gstController.text = company.gst ?? '';
      emailController.text = company.email!;

      // Split phone into phone code and last 10 digits (UI only)
      final fullPhone = company.phone ?? '';
      final digitsOnly = fullPhone.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 10) {
        final last10Digits = digitsOnly.substring(digitsOnly.length - 10);
        final prefixDigits = digitsOnly.substring(0, digitsOnly.length - 10);
        mobileController.text = last10Digits;
        if ((company.phoneCode ?? '').isNotEmpty) {
          phoneCode = company.phoneCode!;
        } else if (prefixDigits.isNotEmpty) {
          phoneCode = '+$prefixDigits';
        } else {
          phoneCode = '+91';
        }
        phoneCodeController.text = phoneCode;
      } else {
        // Fallbacks if fewer than 10 digits
        if ((company.phoneCode ?? '').isNotEmpty) {
          phoneCode = company.phoneCode!;
          phoneCodeController.text = phoneCode;
        } else if (fullPhone.startsWith('+')) {
          final codeOnly = RegExp(r'^\+\d+').stringMatch(fullPhone) ?? '+91';
          phoneCode = codeOnly;
          phoneCodeController.text = phoneCode;
        } else {
          phoneCodeController.text = phoneCode;
        }
        mobileController.text = digitsOnly;
      }

      websiteController.text = company.website ?? '';
      countryController.text = company.country!;
      stateController.text = company.state!;
      cityController.text = company.city!;
      addressController.text = company.address!;
      codeController.text = company.code ?? '';
      isActive = company.status!;
      // Optionally, load the company logo if available
      if (company.image != null) {
        // You may need to download the image and set it to logoImage
      }
    }
  }


  void dispose() {
    nameController.dispose();
    gstController.dispose();
    emailController.dispose();
    mobileController.dispose();
    websiteController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
    codeController.dispose();
    phoneCodeController.dispose();
    super.dispose();
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

  void _showCountryStateCityPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SelectState(
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                  onCountryChanged: (val) {
                    setState(() {
                      country = val;
                      countryController.text = val;
                    });
                  },
                  onStateChanged: (val) {
                    setState(() {
                      state = val;
                      stateController.text = val;
                    });
                  },
                  onCityChanged: (val) {
                    setState(() {
                      city = val;
                      cityController.text = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Just close the dialog
                    },
                    style: AppButtonStyles.primaryButton,
                    child: Text("Done", style: AppTextStyles.primaryButton),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCountryOnlyPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
          countryController.text = country.name;
          // Reset dependent fields when country changes
          stateController.clear();
          cityController.clear();
          _availableStates = [];
          _availableCities = [];
        });
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
            .toList() ??
        [];
    final List<dynamic>? stateObjs = matches.isNotEmpty
        ? (matches.first as Map<String, dynamic>)['state'] as List<dynamic>?
        : null;
    final List<String> states = (stateObjs
            ?.map((s) => (s as Map<String, dynamic>)['name'].toString())
            .toList() ??
        [])
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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
                    cityController.clear();
                    _availableCities = [];
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
            .toList() ??
        [];
    final Map<String, dynamic>? countryObj =
        countryMatches.isNotEmpty ? countryMatches.first as Map<String, dynamic> : null;
    final List<dynamic>? stateObjs = countryObj != null
        ? countryObj['state'] as List<dynamic>?
        : null;
    final List<dynamic> stateMatches = stateObjs
            ?.where((s) => (s as Map<String, dynamic>)['name'] == stateController.text)
            .toList() ??
        [];
    final Map<String, dynamic>? stateObj =
        stateMatches.isNotEmpty ? stateMatches.first as Map<String, dynamic> : null;
    final List<dynamic>? cityObjs = stateObj != null
        ? stateObj['city'] as List<dynamic>?
        : null;
    final List<String> cities = cityObjs
            ?.map((c) => (c as Map<String, dynamic>)['name'].toString())
            .toList() ??
        [];

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
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPhoneField = false,
  ]) {
    final isNumericInput = label == "PinCode" || label == "Mobile Number";
    if (isPhoneField) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          maxLength: 10,
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
                    selectedPhoneCountry.flagEmoji,
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
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'Enter $label';
            }
            if (label == 'Mobile Number' && value.length != 10) {
              return 'Mobile number must be 10 digits';
            }
            return null;
          },
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumericInput ? TextInputType.number : inputType,
        maxLength:
            label == "Mobile Number" ? 10 : (label == "PinCode" ? 6 : null),
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
        title: Text(widget.company != null ? 'Edit Company' : 'Add Company'),
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
                  // Logo Upload
                  GestureDetector(
                    onTap: pickLogo,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: logoImage != null
                          ? FileImage(logoImage!)
                          : (widget.company?.image != null && widget.company!.image!.isNotEmpty
                              ? NetworkImage(widget.company!.image!)
                              : null),
                      backgroundColor: Colors.grey.shade300,
                      child: logoImage == null && (widget.company?.image == null || widget.company!.image!.isEmpty)
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
                  _buildInput(nameController, 'Company Name', Icons.business),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      maxLength: 15,
                      controller: gstController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.receipt,
                          color: AppColors.primary,
                        ),
                        labelText: 'GST Number',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter GST Number';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]{15}$').hasMatch(value)) {
                          return 'GST must be 15 alphanumeric characters';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        gstController.value = gstController.value.copyWith(
                          text: value.toUpperCase(),
                          selection: TextSelection.fromPosition(
                            TextPosition(offset: value.length),
                          ),
                        );
                      },
                    ),
                  ),

                  _buildInput(
                    emailController,
                    'Email',
                    Icons.email,
                    TextInputType.emailAddress,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  _buildInput(
                    mobileController,
                    'Mobile Number',
                    Icons.phone,
                    TextInputType.phone,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Mobile number must be 10 digits';
                      }
                      return null;
                    },
                    true,
                  ),
                  _buildInput(websiteController, 'Website', Icons.web),
                  // Address TextField (New)
                  _buildInput(
                    addressController,
                    'Address',
                    Icons.home,
                    TextInputType.streetAddress,
                  ),
                  _buildInput(codeController, 'PinCode', Icons.location_on, TextInputType.phone,
                        (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter PinCode';
                      }
                      if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                        return 'PinCode must be 6 digits';
                      }
                      return null;
                    },),

                  // Country TextField
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
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Select country'
                                  : null,
                    ),
                  ),

                  // State TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: stateController,
                      readOnly: true,
                      onTap: _showStateOnlyPicker,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.map, color: AppColors.primary),
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
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Select state'
                                  : null,
                    ),
                  ),

                  // City TextField
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
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Select city'
                                  : null,
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed:
                          _isSaving
                              ? null
                              : () async {
                                setState(() => _isSaving = true);
                                if (_formKey.currentState!.validate()) {
                                  final userId =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      ).authData?.user.id;
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'User not authenticated!',
                                        ),
                                      ),
                                    );
                                    setState(() => _isSaving = false);
                                    return;
                                  }
                                  if (widget.company != null) {
                                    // Edit mode - update existing company
                                    final updatedCompany = Company(
                                      id: widget.company!.id,
                                      userId: widget.company!.userId,
                                      name: nameController.text,
                                      email: emailController.text,
                                      phone: mobileController.text,
                                      phoneCode: phoneCode,
                                      address: addressController.text,
                                      city: cityController.text,
                                      state: stateController.text,
                                      country: countryController.text,
                                      status: isActive,
                                      website: websiteController.text,
                                      gst: gstController.text,
                                      openingBalance: widget.company!.openingBalance,
                                      code: codeController.text,
                                      image: widget.company!.image,
                                      note: widget.company!.note,
                                      createdAt: widget.company!.createdAt,
                                      updatedAt: widget.company!.updatedAt,
                                      ownerName: widget.company!.ownerName,
                                    );
                                    final success =
                                        await Provider.of<CompanyProvider>(
                                          context,
                                          listen: false,
                                        ).updateCompany(updatedCompany, imageFile: logoImage);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Company updated successfully!'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to update company!'),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Add mode - create new company
                                    final newCompany = Company(
                                      id: 0,
                                      userId: userId,
                                      name: nameController.text,
                                      email: emailController.text,
                                      phone: mobileController.text,
                                      phoneCode: phoneCode,
                                      address: addressController.text,
                                      city: cityController.text,
                                      state: stateController.text,
                                      country: countryController.text,
                                      status: isActive,
                                      website: websiteController.text,
                                      gst: gstController.text,
                                      openingBalance: "0",
                                      code: codeController.text,
                                    );
                                    final success =
                                        await Provider.of<CompanyProvider>(
                                          context,
                                          listen: false,
                                        ).addCompany(newCompany, userId, imageFile: logoImage);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Company saved!'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to save company!'),
                                        ),
                                      );
                                    }
                                  }
                                }
                                setState(() => _isSaving = false);
                              },
                      child:
                          _isSaving
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                widget.company != null ? "Update Company" : "Save Company",
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
