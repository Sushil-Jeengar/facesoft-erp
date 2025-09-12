import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/model/user_profile_model.dart';
import 'package:facesoft/screens/company_profile.dart';
import 'package:facesoft/API_services/user_api.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class CompleteProfile extends StatefulWidget {
  final UserProfile? initialProfile;
  const CompleteProfile({super.key, this.initialProfile});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  bool get _isProfileComplete {
    return _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneCodeController = TextEditingController(text: '+91');
  final TextEditingController _bioController = TextEditingController();

  String _country = '';
  String _state = '';
  String _city = '';
  String _phoneCode = '+91';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  Country _selectedPhoneCountry = Country.parse('IN');
  List<dynamic>? _countriesData;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile(widget.initialProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(_isProfileComplete ? "Update Your Profile" : "Complete Your Profile"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        backgroundColor: Colors.grey.shade300,
                        child: _profileImage == null
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
                    const SizedBox(height: 30),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      validator: (value) => value == null || value.isEmpty ? "First Name" : null,
                      decoration: _inputDecoration("First Name", icon: Icons.person),
                    ),
                    const SizedBox(height: 20),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      validator: (value) => value == null || value.isEmpty ? "Last Name" : null,
                      decoration: _inputDecoration("Last Name", icon: Icons.person),
                    ),
                    const SizedBox(height: 20),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      validator: (value) => value == null || value.isEmpty ? "Username" : null,
                      decoration: _inputDecoration("Username", icon: Icons.alternate_email),
                    ),
                    const SizedBox(height: 20),

                    // Gender
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputDecoration("Gender", icon: Icons.wc),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Select gender' : null,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number with Country Code
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 10,
                        controller: _phoneController,
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
                                  _selectedPhoneCountry.flagEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(_phoneCode, style: const TextStyle(color: Colors.black)),
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
                          if (value == null || value.isEmpty) {
                            return 'Enter Mobile Number';
                          }
                          if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty ? "Email" : null,
                      decoration: _inputDecoration("Email", icon: Icons.email),
                    ),
                    const SizedBox(height: 20),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      keyboardType: TextInputType.multiline,
                      validator: (value) => value == null || value.isEmpty ? "Full Address" : null,
                      decoration: _inputDecoration("Full Address", icon: Icons.location_on),
                    ),
                    const SizedBox(height: 20),

                    // Bio (optional)
                    TextFormField(
                      controller: _bioController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: _inputDecoration("Bio (optional)", icon: Icons.notes),
                    ),
                    const SizedBox(height: 20),

                    // Country
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _countryController,
                        readOnly: true,
                        onTap: _showCountryOnlyPicker,
                        decoration: _inputDecoration("Country", icon: Icons.public),
                        validator: (value) => value == null || value.isEmpty ? 'Select country' : null,
                      ),
                    ),

                    // State
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _stateController,
                        readOnly: true,
                        onTap: _showStateOnlyPicker,
                        decoration: _inputDecoration("State", icon: Icons.map),
                        validator: (value) => value == null || value.isEmpty ? 'Select state' : null,
                      ),
                    ),

                    // City
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _cityController,
                        readOnly: true,
                        onTap: _showCityOnlyPicker,
                        decoration: _inputDecoration("City", icon: Icons.location_city),
                        validator: (value) => value == null || value.isEmpty ? 'Select city' : null,
                      ),
                    ),

                    // PinCode
                    TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter PinCode';
                        }
                        if (value.length != 6) {
                          return 'PinCode must be 6 digits';
                        }
                        return null;
                      },
                      decoration: _inputDecoration("PinCode", icon: Icons.location_on),
                    ),
                    const SizedBox(height: 20),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: AppButtonStyles.primaryButton,
                        child: Text(
                          "Continue",
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
      ),
    );
  }

  // Input Decoration Helper
  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      labelText: hint,
      labelStyle: TextStyle(color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
    );
  }

  // Image Picker
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: await _showImageSourceDialog(),
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Image Source Dialog
  Future<ImageSource> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image From"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("Gallery"),
          ),
        ],
      ),
    ) ??
        ImageSource.gallery;
  }

  // Country Code Picker
  void _showCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedPhoneCountry = country;
          _phoneCode = '+${country.phoneCode}';
          _phoneCodeController.text = _phoneCode;
        });
      },
    );
  }

  // Country Picker
  void _showCountryOnlyPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _countryController.text = country.name;
          _stateController.clear();
          _cityController.clear();
        });
      },
    );
  }

  // State Picker
  Future<void> _showStateOnlyPicker() async {
    if (_countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select country first')),
      );
      return;
    }
    await _ensureLocationDataLoaded();
    final List<dynamic> matches = _countriesData
        ?.where((c) => (c as Map<String, dynamic>)['name'] == _countryController.text)
        .toList() ??
        [];
    final List<dynamic>? stateObjs = matches.isNotEmpty
        ? (matches.first as Map<String, dynamic>)['state'] as List<dynamic>?
        : null;
    final List<String> states = stateObjs
        ?.map((s) => (s as Map<String, dynamic>)['name'].toString())
        .toList() ??
        [];
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
                    _stateController.text = stateName;
                    _cityController.clear();
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  // City Picker
  Future<void> _showCityOnlyPicker() async {
    if (_countryController.text.isEmpty || _stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select state first')),
      );
      return;
    }
    await _ensureLocationDataLoaded();
    final List<dynamic> countryMatches = _countriesData
        ?.where((c) => (c as Map<String, dynamic>)['name'] == _countryController.text)
        .toList() ??
        [];
    final Map<String, dynamic>? countryObj =
    countryMatches.isNotEmpty ? countryMatches.first as Map<String, dynamic> : null;
    final List<dynamic>? stateObjs = countryObj != null
        ? countryObj['state'] as List<dynamic>?
        : null;
    final List<dynamic> stateMatches = stateObjs
        ?.where((s) => (s as Map<String, dynamic>)['name'] == _stateController.text)
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
                    _cityController.text = cityName;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  // Load Country Data
  Future<void> _ensureLocationDataLoaded() async {
    if (_countriesData != null) return;
    final String jsonString = await rootBundle.loadString(
      'packages/country_state_city_picker/lib/assets/country.json',
    );
    _countriesData = List<dynamic>.from(
      ( json.decode(jsonString) as List<dynamic>),
    );
  }

  void _prefillFromProfile(UserProfile? profile) {
    if (profile == null) return;
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _usernameController.text = profile.userName ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _countryController.text = profile.country ?? '';
    _stateController.text = profile.state ?? '';
    _cityController.text = profile.city ?? '';
    _bioController.text = profile.bio ?? '';

    if (profile.pincode != null) {
      _pincodeController.text = profile.pincode.toString();
    }

    // Normalize gender values such as m/f/y to Male/Female/Other
    _selectedGender = _normalizeGender(profile.gender);

    // Attempt to split phone with country code if present
    final String rawPhone = profile.phoneNumber ?? '';
    final String digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final String justDigits = digitsOnly.replaceAll('+', '');
    if (justDigits.length >= 10) {
      final String localPart = justDigits.substring(justDigits.length - 10);
      final String countryCodeDigits = justDigits.substring(0, justDigits.length - 10);
      _phoneController.text = localPart;
      if (countryCodeDigits.isNotEmpty) {
        _phoneCode = '+$countryCodeDigits';
        _phoneCodeController.text = _phoneCode;
      }
    } else if (justDigits.isNotEmpty) {
      _phoneController.text = justDigits;
    }
  }

  String? _normalizeGender(String? value) {
    if (value == null) return null;
    final String v = value.trim().toLowerCase();
    if (v == 'm' || v == 'male') return 'Male';
    if (v == 'f' || v == 'female') return 'Female';
    if (v == 'o' || v == 'other' || v == 'y') return 'Other';
    return 'Other';
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffold = ScaffoldMessenger.of(context);
    try {
      final int? id = widget.initialProfile?.id;
      if (id == null) {
        scaffold.showSnackBar(const SnackBar(content: Text('Missing user id')));
        return;
      }

      final Map<String, dynamic> changed = _computeChangedFields(widget.initialProfile);
      if (changed.isEmpty && _profileImage == null) {
        scaffold.showSnackBar(const SnackBar(content: Text('No changes to update')));
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final bool ok = await UserService.updateUserProfilePartial(
        id,
        changed,
        imageFile: _profileImage,
      );

      if (mounted) Navigator.of(context).pop();

      if (ok) {
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.saveAuthDataToLocal();

          scaffold.showSnackBar(
            SnackBar(
              content: Text(_isProfileComplete
                  ? 'Profile updated successfully'
                  : 'Profile completed successfully'),
            ),
          );

          if (widget.initialProfile?.phoneNumber != null && widget.initialProfile?.email != null) {
            // ✅ Both phone & email present → just pop back
            Navigator.pop(context, true); // you can return true for refresh if needed
          } else {
            // ❌ Missing one → go to company form
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CompanyProfileForm()),
            );
          }
        }
      }
      else {
        scaffold.showSnackBar(const SnackBar(content: Text('Failed to update profile')));
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  Map<String, dynamic> _computeChangedFields(UserProfile? original) {
    final Map<String, dynamic> changed = {};
    if (original == null) return changed;

    void setIfChanged(String key, dynamic oldValue, dynamic newValue) {
      if (newValue != oldValue && !(newValue == null && oldValue == '')) {
        changed[key] = newValue;
      }
    }

    setIfChanged('first_name', original.firstName, _firstNameController.text.trim());
    setIfChanged('last_name', original.lastName, _lastNameController.text.trim());
    setIfChanged('user_name', original.userName, _usernameController.text.trim());
    setIfChanged('email', original.email, _emailController.text.trim());
    setIfChanged('address', original.address, _addressController.text.trim());
    setIfChanged('country', original.country, _countryController.text.trim());
    setIfChanged('state', original.state, _stateController.text.trim());
    setIfChanged('city', original.city, _cityController.text.trim());

    final String fullPhone = _composeFullPhone();
    setIfChanged('phone_number', original.phoneNumber, fullPhone);

    final int? pin = _pincodeController.text.isNotEmpty ? int.tryParse(_pincodeController.text) : null;
    setIfChanged('pincode', original.pincode, pin);

    final String? genderForApi = _mapGenderToApi(_selectedGender);
    setIfChanged('gender', original.gender, genderForApi);

    final String bio = _bioController.text.trim();
    setIfChanged('bio', original.bio, bio.isEmpty ? null : bio);

    return changed;
  }

  String _composeFullPhone() {
    final String code = _phoneCode.startsWith('+') ? _phoneCode : '+$_phoneCode';
    final String local = _phoneController.text.trim();
    return '$code$local';
  }

  String? _mapGenderToApi(String? uiValue) {
    if (uiValue == null) return null;
    switch (uiValue) {
      case 'Male':
        return 'm';
      case 'Female':
        return 'f';
      default:
        return 'y';
    }
  }
}
