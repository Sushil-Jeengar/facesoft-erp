import 'dart:io';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/screens/home_screen.dart';

class CompanyProfileForm extends StatefulWidget {
  const CompanyProfileForm({super.key});

  @override
  State<CompanyProfileForm> createState() => _CompanyProfileFormState();
}

class _CompanyProfileFormState extends State<CompanyProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController phoneCodeController = TextEditingController(); // Added phone code controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? logoImage;
  final ImagePicker picker = ImagePicker();

  String country = "";
  String state = "";
  String city = "";
  Country selectedCountry = Country.parse('IN'); // Default to India
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    // Set default phone code
    phoneCodeController.text = '+${selectedCountry.phoneCode}';
  }

  @override
  void dispose() {
    companyNameController.dispose();
    gstController.dispose();
    mobileController.dispose();
    phoneCodeController.dispose(); // Dispose phone code controller
    emailController.dispose();
    websiteController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickLogoImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
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
              title: const Text("Take Photo"),
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
      ),
    );
  }

  // Function to show the country/state/city picker in a dialog
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

  // Helper widget for consistent input fields
  Widget _buildInput(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType inputType = TextInputType.text,
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
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  // Mobile number input widget with country picker (similar to login page)
  Widget _buildMobileInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mobile Number',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          selectedCountry = country;
                          phoneCodeController.text = '+${selectedCountry.phoneCode}';
                        });
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        selectedCountry.flagEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${selectedCountry.phoneCode}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Enter Mobile Number',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter Mobile Number' : null,
                  ),
                ),
                Text(
                  '${mobileController.text.length}/10',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Complete Company Profile"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
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
                    onTap: pickLogoImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: logoImage != null ? FileImage(logoImage!) : null,
                      backgroundColor: Colors.grey.shade300,
                      child: logoImage == null
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

                  _buildInput(
                    companyNameController,
                    'Company Name',
                    Icons.business,
                  ),
                  _buildInput(gstController, 'GST Number', Icons.receipt),

                  // Updated mobile input with country picker
                  _buildMobileInput(),

                  _buildInput(
                    emailController,
                    'Email',
                    Icons.email,
                    TextInputType.emailAddress,
                  ),
                  _buildInput(websiteController, 'Website', Icons.web),
                  // Address TextField
                  _buildInput(
                    addressController,
                    'Address',
                    Icons.home,
                    TextInputType.streetAddress,
                  ),

                  // Country TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: countryController,
                      readOnly: true,
                      onTap: _showCountryStateCityPicker,
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
                      validator: (value) => value == null || value.isEmpty ? 'Select country' : null,
                    ),
                  ),

                  // State TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: stateController,
                      readOnly: true,
                      onTap: _showCountryStateCityPicker,
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
                      validator: (value) => value == null || value.isEmpty ? 'Select state' : null,
                    ),
                  ),

                  // City TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: cityController,
                      readOnly: true,
                      onTap: _showCountryStateCityPicker,
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
                      validator: (value) => value == null || value.isEmpty ? 'Select city' : null,
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // if (_formKey.currentState!.validate())
                        {
                          // All fields are valid, process the data
                          // print('Company Name: ${companyNameController.text}');
                          // print('GST Number: ${gstController.text}');
                          // print('Email: ${emailController.text}');
                          // print('Mobile Number: ${mobileController.text}');
                          // print('Phone Code: ${phoneCodeController.text}'); // Added phone code print
                          // print('Website: ${websiteController.text}');
                          // print('Country: $country');
                          // print('State: $state');
                          // print('City: $city');
                          // print('Address: ${addressController.text}');
                          // print('Logo Image Path: ${logoImage?.path}');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Company profile saved!'),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      },
                      style: AppButtonStyles.primaryButton,
                      child: Text(
                        "Save Company Profile",
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