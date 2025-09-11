import 'package:country_picker/country_picker.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:facesoft/screens/complete_profile.dart';
import 'package:facesoft/style/app_style.dart';
import 'package:facesoft/API_services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool otpSent = false;
  bool showPhoneInput = true;
  bool isLoading = false;
  Country selectedCountry = Country.parse('IN');
  Map<String, String> loginArgs = {};

  void showOtpBottomSheet() {
    otpController.clear();

    final isPhone = phoneController.text.isNotEmpty;
    final contactInfo =
        isPhone
            ? '+${selectedCountry.phoneCode}${phoneController.text}'
            : emailController.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'An OTP has been sent to $contactInfo',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit OTP',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.black54,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showOtpBottomSheet();
                      },
                      style: AppButtonStyles.secondaryButton,
                      child: const Text(
                        'Resend OTP',
                        style: AppTextStyles.secondryButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Map<String, String> args = Map.from(loginArgs);
                        args["otp"] = otpController.text;

                        final authData = await AuthService.verifyOtp(args);
                        if (authData != null) {

                          Provider.of<AuthProvider>(context, listen: false).setAuthData(authData);

                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompleteProfile(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP Verification failed')),
                          );
                        }
                      },
                      style: AppButtonStyles.primaryButton,
                      child: const Text(
                        'Sign In',
                        style: AppTextStyles.primaryButton,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/FaceLogoE.png',
                    width: 200,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please enter your email address or phone number.\nWe will send you an OTP to verify.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
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
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Plese Enter Phone No.',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                emailController
                                    .clear(); // Clear email if phone is typed
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        Text(
                          '${phoneController.text.length}/10',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // OR separator
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white70)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white70)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Email input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Please Enter Email',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        icon: Icon(Icons.email, color: Colors.white70),
                        //Email icon added
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          phoneController
                              .clear(); // Clear phone if email is typed
                        }
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Get OTP Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      //onPressed: showOtpBottomSheet,
                      onPressed: isLoading ? null : () async {
                        setState(() {
                          isLoading = true;
                        });

                        Map<String, String> args = {};

                        if (emailController.text.isNotEmpty) {
                          args["email"] = emailController.text;
                        }
                        if (phoneController.text.isNotEmpty) {
                          args["phone"] = '+' + selectedCountry.phoneCode + phoneController.text;
                        }

                        if (args.isEmpty) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter phone number or email")),
                          );
                          return;
                        }

                        loginArgs = args;
                        final result = await AuthService.sendOtp(args);

                        setState(() {
                          isLoading = false;
                        });

                        if (result['success']) {
                          showOtpBottomSheet();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['error'] ?? 'Failed to send OTP')),
                          );
                        }
                      },
                      style: AppButtonStyles.primaryButton,
                      child:
                      isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        :
                      const Text(
                            'Get OTP',
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