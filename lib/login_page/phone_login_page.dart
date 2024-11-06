import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController phoneController = TextEditingController();

  String phoneNumber = "";

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendPhoneNumber() {
    String phoneNumberToSend = phoneNumber.trim();
    AuthService().sentOTPPhoneSignIn(
      context: context,
      phoneNumber: "+${selectedCountry.phoneCode}$phoneNumberToSend",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                // image
                Container(
                  height: 200,
                  width: 200,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.shade50,
                  ),
                  child: Image.asset("assets/image2.png"),
                ),
                const SizedBox(height: 20),

                // register
                Text(
                  "Register",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                // text after register
                const SizedBox(height: 10),
                Text(
                  "Add your phone number. We'll send you a verification code",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),

                // register feild
                const SizedBox(height: 20),
                TextFormField(
                  controller: phoneController,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w500,
                      ),
                  onChanged: (value) => setState(
                    () {
                      phoneNumber = value;
                    },
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.4),
                      ),
                    ),
                    prefix: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          countryListTheme: CountryListThemeData(
                            bottomSheetHeight:
                                MediaQuery.of(context).size.height * 0.8,
                          ),
                          onSelect: (value) {
                            setState(
                              () {
                                selectedCountry = value;
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.arrowRightToBracket,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  onPressed: sendPhoneNumber,
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  label: Text(
                    "Login",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.background,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
