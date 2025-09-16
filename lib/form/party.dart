import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:facesoft/model/parties_model.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/providers/party_provider.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddPartyPage extends StatefulWidget {
  final Party? party;
  const AddPartyPage({super.key, this.party});

  @override
  State<AddPartyPage> createState() => _AddPartyPageState();
}

class _AddPartyPageState extends State<AddPartyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  String country = '';
  String state = '';
  String city = '';
  String status = 'Active';
  String partyType = 'Customer';
  Country selectedCountry = Country.parse('IN');
  Country selectedPhoneCountry = Country.parse('IN');
  List<dynamic>? _countriesData;
  File? logoImage;
  final ImagePicker picker = ImagePicker();
  String phoneCode = '+91';

  @override
  void initState() {
    super.initState();
    if (widget.party != null) {
      final Party existing = widget.party!;
      companyNameController.text = existing.companyName ?? '';
      partyType = existing.partyType ?? partyType;
      contactPersonController.text = existing.contactPerson ?? '';
      gstController.text = existing.gst ?? '';
      emailController.text = existing.email ?? '';
      mobileController.text = existing.phone ?? '';
      addressController.text = existing.address ?? '';
      balanceController.text = existing.openingBalance ?? '';
      cityController.text = existing.city ?? '';
      stateController.text = existing.state ?? '';
      countryController.text = existing.country ?? '';
      pincodeController.text = existing.code ?? '';
      status = (existing.status == true) ? 'Active' : 'Inactive';
      phoneCode = existing.phoneCode ?? '+91';
    }
  }


  Future<void> pickLogo() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.party == null ? "Add Party" : "Edit Party"),
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
                          : (widget.party != null && (widget.party!.image ?? '').isNotEmpty)
                          ? NetworkImage(widget.party!.image!)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: (logoImage == null && (widget.party?.image == null || widget.party!.image!.isEmpty))
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

                  // Party Type Dropdown
                  _buildDropdownField(
                    label: 'Party Type',
                    icon: Icons.category,
                    value: partyType,
                    items: ['Customer', 'Vendor', 'Both'],
                    onChanged: (val) => setState(() => partyType = val!),
                  ),

                  // Contact Person
                  _buildInput(
                    contactPersonController,
                    'Contact Person',
                    Icons.badge,
                  ),

                  // GST Field
                  _buildGSTField(),

                  // Email Field
                  _buildEmailField(),

                  // Mobile Field
                  _buildMobileField(),

                  // Address Field
                  _buildInput(
                    addressController,
                    'Address',
                    Icons.home,
                    TextInputType.streetAddress,
                  ),

                  // Pincode Field
                  _buildPincodeField(),

                  // Country Field
                  _buildCountryField(),

                  // State Field
                  _buildStateField(),

                  // City Field
                  _buildCityField(),

                  // Status Field
                  _buildStatusField(),

                  // Opening Balance Field
                  _buildInput(
                    balanceController,
                    'Opening Balance',
                    Icons.account_balance_wallet,
                    TextInputType.number,
                  ),

                  // Note Field
                  _buildInput(
                    noteController,
                    'Note (Optional)',
                    Icons.note,
                    TextInputType.multiline,
                    false,
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildGSTField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: gstController,
        keyboardType: TextInputType.text,
        maxLength: 15,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.receipt, color: AppColors.primary),
          labelText: 'GST Number',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
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
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.email, color: AppColors.primary),
          labelText: 'Email',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter Email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMobileField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: mobileController,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter Mobile Number';
          }
          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
            return 'Mobile number must be 10 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPincodeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: pincodeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.markunread_mailbox, color: AppColors.primary),
          labelText: 'Pincode',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter Pincode';
          }
          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
            return 'PinCode must be 6 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCountryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: countryController,
        readOnly: true,
        onTap: _showCountryOnlyPicker,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.public, color: AppColors.primary),
          labelText: 'Country',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Select country' : null,
      ),
    );
  }

  Widget _buildStateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: stateController,
        readOnly: true,
        onTap: _showStateOnlyPicker,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
          labelText: 'State',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Select state' : null,
      ),
    );
  }

  Widget _buildCityField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: cityController,
        readOnly: true,
        onTap: _showCityOnlyPicker,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
          labelText: 'City',
          labelStyle: const TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Select city' : null,
      ),
    );
  }

  Widget _buildStatusField() {
    return _buildDropdownField(
      label: 'Status',
      icon: Icons.toggle_on,
      value: status,
      items: ['Active', 'Inactive'],
      onChanged: (val) => setState(() => status = val!),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
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
            final partyProvider = Provider.of<PartyProvider>(context, listen: false);
            if (widget.party == null) {
              final newParty = Party(
                userId: userId,
                partyType: partyType,
                contactPerson: contactPersonController.text,
                email: emailController.text,
                phone: mobileController.text,
                phoneCode: phoneCode,
                gst: gstController.text,
                openingBalance: balanceController.text,
                city: cityController.text,
                state: stateController.text,
                country: countryController.text,
                address: addressController.text,
                status: status == 'Active',
                companyName: companyNameController.text,
                code: pincodeController.text,
              );
              final result = await partyProvider.createParty(newParty, imageFile: logoImage);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Party added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Failed to add party.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              final updated = Party(
                id: widget.party!.id,
                userId: widget.party!.userId ?? userId,
                partyType: partyType,
                contactPerson: contactPersonController.text,
                email: emailController.text,
                phone: mobileController.text,
                phoneCode: phoneCode,
                gst: gstController.text,
                openingBalance: balanceController.text,
                city: cityController.text,
                state: stateController.text,
                country: countryController.text,
                address: addressController.text,
                status: status == 'Active',
                companyName: companyNameController.text,
                code: pincodeController.text,
              );
              final result = await partyProvider.updateParty(updated, imageFile: logoImage);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Party updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Failed to update party.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        style: AppButtonStyles.primaryButton,
        child: Text(
          widget.party == null ? "Add Party" : "Update Party",
          style: AppTextStyles.primaryButton,
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
        validator: (value) => isRequired && (value == null || value.isEmpty) ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
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
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? 'Select $label' : null,
      ),
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
          stateController.clear();
          cityController.clear();
        });
      },
    );
  }

  Future<void> _ensureLocationDataLoaded() async {
    if (_countriesData != null) return;
    final String jsonString = await rootBundle.loadString(
      'packages/country_state_city_picker/lib/assets/country.json',
    );
    _countriesData = List<dynamic>.from(json.decode(jsonString) as List<dynamic>);
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
      backgroundColor: Colors.white,
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
    final Map<String, dynamic>? countryObj = countryMatches.isNotEmpty
        ? countryMatches.first as Map<String, dynamic>
        : null;
    final List<dynamic>? stateObjs = countryObj != null ? countryObj['state'] as List<dynamic>? : null;
    final List<dynamic> stateMatches = stateObjs
        ?.where((s) => (s as Map<String, dynamic>)['name'] == stateController.text)
        .toList() ??
        [];
    final Map<String, dynamic>? stateObj = stateMatches.isNotEmpty
        ? stateMatches.first as Map<String, dynamic>
        : null;
    final List<dynamic>? cityObjs = stateObj != null ? stateObj['city'] as List<dynamic>? : null;
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
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            itemCount: cities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final String cityName = cities[index];
              return ListTile(
                title: Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto',
                  ),
                ),
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
}
