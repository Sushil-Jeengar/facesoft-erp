  import 'dart:io';
  import 'dart:convert';
  import 'package:facesoft/model/agent_model.dart';
  import 'package:facesoft/providers/agent_provider.dart';
  import 'package:facesoft/providers/auth_provider.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:country_state_city_picker/country_state_city_picker.dart';
  import 'package:country_picker/country_picker.dart';
  import 'package:facesoft/style/app_style.dart';
  import 'package:provider/provider.dart';
  import 'package:flutter/services.dart';


  class AddAgentPage extends StatefulWidget {
    final Agent? agent;
    const AddAgentPage({super.key, this.agent});

    @override
    State<AddAgentPage> createState() => _AddAgentPageState();
  }

  class _AddAgentPageState extends State<AddAgentPage> {

    final _formKey = GlobalKey<FormState>();
    final TextEditingController companyNameController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController gstController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();
    final TextEditingController contactController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneCodeController = TextEditingController(
      text: '+91',
    );
    final TextEditingController pincodeController = TextEditingController();

    String country = '';
    String state = '';
    String city = '';
    String phoneCode = '+91';
    bool isActive = true;
    File? logoImage;
    final ImagePicker picker = ImagePicker();
    Country selectedCountry = Country.parse('IN');
  Country selectedPhoneCountry = Country.parse('IN');
    List<dynamic>? _countriesData;

    @override
    void initState() {
      super.initState();
      if (widget.agent != null) {
        nameController.text = widget.agent!.agentName ?? '';
        contactController.text = widget.agent!.contactPerson ?? '';
        gstController.text = widget.agent!.gst ?? '';
        emailController.text = widget.agent!.email ?? '';

        // Split phone into phone code and last 10 digits (UI only)
        final fullPhone = widget.agent!.phone ?? '';
        final digitsOnly = fullPhone.replaceAll(RegExp(r'\\D'), '');
        if (digitsOnly.length >= 10) {
          final last10Digits = digitsOnly.substring(digitsOnly.length - 10);
          final prefixDigits = digitsOnly.substring(0, digitsOnly.length - 10);
          mobileController.text = last10Digits;
          if ((widget.agent!.phoneCode ?? '').isNotEmpty) {
            phoneCode = widget.agent!.phoneCode!;
          } else if (prefixDigits.isNotEmpty) {
            phoneCode = '+$prefixDigits';
          } else {
            phoneCode = '+91';
          }
          phoneCodeController.text = phoneCode;
        } else {
          // Fallbacks if fewer than 10 digits
          if ((widget.agent!.phoneCode ?? '').isNotEmpty) {
            phoneCode = widget.agent!.phoneCode!;
            phoneCodeController.text = phoneCode;
          } else if (fullPhone.startsWith('+')) {
            final codeOnly = RegExp(r'^\\+\\d+').stringMatch(fullPhone) ?? '+91';
            phoneCode = codeOnly;
            phoneCodeController.text = phoneCode;
          } else {
            phoneCodeController.text = phoneCode;
          }
          mobileController.text = digitsOnly;
        }

        addressController.text = widget.agent!.address ?? '';
        countryController.text = widget.agent!.country ?? '';
        stateController.text = widget.agent!.state ?? '';
        cityController.text = widget.agent!.city ?? '';
        pincodeController.text = widget.agent!.code ?? '';
        isActive = widget.agent!.status ?? true;
        companyNameController.text = widget.agent!.companyName ?? '';
      }
    }


    @override
    void dispose() {
      pincodeController.dispose();
      nameController.dispose();
      contactController.dispose();
      gstController.dispose();
      emailController.dispose();
      mobileController.dispose();
      countryController.dispose();
      stateController.dispose();
      cityController.dispose();
      addressController.dispose();
      phoneCodeController.dispose();
      companyNameController.dispose();
      super.dispose();
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
                        Navigator.pop(context);
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
            // Reset dependent fields
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

    Widget _buildInput(
        TextEditingController controller,
        String label,
        IconData icon, [
          TextInputType inputType = TextInputType.text,
          bool isPhoneField = false,
          String? Function(String?)? validator,
        ]) {
      List<TextInputFormatter>? inputFormatters;
      if (label == 'Mobile Number' || label == 'PinCode') {
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
      }

      if (isPhoneField) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            inputFormatters: inputFormatters,
            maxLength: 10, // Mobile number: 10 digits
            controller: controller,
            keyboardType: inputType,
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
            validator: validator ??
                    (value) {
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
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            inputFormatters: inputFormatters,
            maxLength: label == 'PinCode' ? 6 : label == 'GST Number' ? 15 : null,
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
                    (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter $label';
                  }
                  if (label == 'PinCode' && value.length != 6) {
                    return 'Pin Code must be 6 digits';
                  }
                  if (label == 'GST Number' && value.length != 15) {
                    return 'GST Number must be 15 characters';
                  }
                  return null;
                },
          ),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.agent == null ? 'Add Agent' : 'Edit Agent'),
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
                        backgroundImage:
                            logoImage != null ? FileImage(logoImage!) : null,
                        backgroundColor: Colors.grey.shade300,
                        child:
                            logoImage == null
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
                    _buildInput(nameController, 'Agent Name', Icons.person),
                    _buildInput(companyNameController, 'Company Name', Icons.maps_home_work_outlined),
                    _buildInput(
                      contactController,
                      'Contact Person',
                      Icons.contacts,
                    ),
                    _buildInput(gstController, 'GST Number', Icons.receipt),
                    _buildInput(
                      emailController,
                      'Email',
                      Icons.email,
                      TextInputType.emailAddress,
                      false,
                      _validateEmail,
                    ),
                    _buildInput(
                      mobileController,
                      'Mobile Number',
                      Icons.phone,
                      TextInputType.phone,
                      true,
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Mobile Number';
                        }
                        if (value.length != 10) {
                          return 'Mobile number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    _buildInput(
                      addressController,
                      'Address',
                      Icons.home,
                      TextInputType.streetAddress,
                    ),
                    _buildInput(
                      pincodeController,
                      'PinCode',
                      Icons.location_on,
                      TextInputType.number,
                    ),

                    // Country, State, City fields
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
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.primaryButton,
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

                            // Prepare update data: only include changed fields
                            Map<String, dynamic> updateData = {};

                            if (widget.agent != null) {
                              // For update: only send changed fields
                              if (nameController.text != widget.agent!.agentName) {
                                updateData['agent_name'] = nameController.text;
                              }
                              if (contactController.text != widget.agent!.contactPerson) {
                                updateData['contact_person'] = contactController.text;
                              }
                              if (emailController.text != widget.agent!.email) {
                                updateData['email'] = emailController.text;
                              }
                              if (mobileController.text != widget.agent!.phone) {
                                updateData['phone'] = mobileController.text;
                              }
                              if (phoneCode != widget.agent!.phoneCode) {
                                updateData['phone_code'] = phoneCode;
                              }
                              if (gstController.text != widget.agent!.gst) {
                                updateData['gst'] = gstController.text;
                              }
                              if (addressController.text != widget.agent!.address) {
                                updateData['address'] = addressController.text;
                              }
                              if (countryController.text != widget.agent!.country) {
                                updateData['country'] = countryController.text;
                              }
                              if (stateController.text != widget.agent!.state) {
                                updateData['state'] = stateController.text;
                              }
                              if (cityController.text != widget.agent!.city) {
                                updateData['city'] = cityController.text;
                              }
                              if (pincodeController.text != widget.agent!.code) {
                                updateData['code'] = pincodeController.text;
                              }
                              if (isActive != widget.agent!.status) {
                                updateData['status'] = isActive;
                              }
                              if (companyNameController.text != widget.agent!.companyName) {
                                updateData['company_name'] = companyNameController.text;
                              }
                            } else {
                              // For create: send all fields
                              updateData.addAll({
                                'user_id': userId,
                                'agent_name': nameController.text,
                                'contact_person': contactController.text,
                                'email': emailController.text,
                                'phone': mobileController.text,
                                'phone_code': phoneCode,
                                'gst': gstController.text,
                                'address': addressController.text,
                                'country': countryController.text,
                                'state': stateController.text,
                                'city': cityController.text,
                                'code': pincodeController.text,
                                'status': isActive,
                                'company_name': companyNameController.text,
                              });
                            }

                            // Call API
                            final provider = Provider.of<AgentProvider>(context, listen: false);
                            final success = widget.agent == null
                                ? await provider.createAgent(Agent.fromJson(updateData))
                                : await provider.updateAgent(widget.agent!.id!, updateData);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(widget.agent == null
                                      ? 'Agent saved successfully!'
                                      : 'Agent updated successfully!'),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to save agent'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          "Save Agent",
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
