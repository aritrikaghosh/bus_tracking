import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/signup_route_bloc.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    required this.email,
    required this.uid,
  });

  final String email;
  final String uid;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _textFormKey1 = GlobalKey<FormFieldState>();
  final _textFormKey2 = GlobalKey<FormFieldState>();

  bool isUploading = false;
  String studentName = "";
  String studentRegNumber = "";
  String parentPhoneNumber = "";
  String studentPhoneNumber = "";
  String routeNameSelected = "";

  Country selectedParentCountry = Country(
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

  Country selectedStudentCountry = Country(
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

  late FirebaseFirestore db;
  List<dynamic> routeNames = [];
  late SignUpRoutesBloc signUpRoutesBloc;

  void getRoutes() async {
    final docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;

    routeNames = dataMap["route_name"];
    log("$routeNames loaded");

    signUpRoutesBloc.add(SignUpRouteIsLoaded());
  }

  bool validateForm() {
    if (studentName.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Student Name",
        context: context,
      );
      return false;
    }
    if (studentRegNumber.isEmpty || studentRegNumber.length != 9) {
      ShowSnackBar().showSnackBar(
        message: "Enter Reg. number",
        context: context,
      );
      return false;
    }
    if (parentPhoneNumber.isEmpty || parentPhoneNumber.length <= 9) {
      ShowSnackBar().showSnackBar(
        message: "Enter Parent Phone number",
        context: context,
      );
      return false;
    }
    if (studentPhoneNumber.isEmpty || studentPhoneNumber.length <= 9) {
      ShowSnackBar().showSnackBar(
        message: "Enter Your Phone number",
        context: context,
      );
      return false;
    }
    if (routeNameSelected.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Driver Mobile Number",
        context: context,
      );
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    signUpRoutesBloc = SignUpRoutesBloc();
    db = FirebaseFirestore.instance;
    signUpRoutesBloc.add(SignUpRouteIsNotLoaded());
    getRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // signup image
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Image.asset(
                      "assets/image2.png",
                      height: 150,
                    ),
                  ),

                  // sizedbox for spacing
                  const SizedBox(height: 10),

                  // space for name input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      key: _textFormKey1,
                      cursorColor: Theme.of(context).colorScheme.primary,

                      // setting the auto focus as true
                      autofocus: true,

                      // enabled on the uploading variable
                      enabled: !isUploading,

                      style: Theme.of(context).textTheme.bodyMedium,

                      // text capital
                      textCapitalization: TextCapitalization.words,

                      // giving the underline color
                      decoration: InputDecoration(
                        // hint text to add the city name
                        hintText: "Student Name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: ((value) => studentName = value.trim()),
                    ),
                  ),

                  // sizedbox for spacing
                  const SizedBox(height: 10),

                  // space for reg number input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      key: _textFormKey2,
                      cursorColor: Theme.of(context).colorScheme.primary,

                      // setting the auto focus as true
                      autofocus: true,

                      // enabled on the uploading variable
                      enabled: !isUploading,

                      // only capital letters
                      textCapitalization: TextCapitalization.characters,

                      style: Theme.of(context).textTheme.bodyMedium,

                      // max numbers
                      maxLength: 9,

                      // giving the underline color
                      decoration: InputDecoration(
                        // hint text to add the city name
                        hintText: "Student Reg. Number",
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: ((value) => studentRegNumber = value.trim()),
                    ),
                  ),

                  // sizedbox for spacing
                  const SizedBox(height: 10),

                  // space for parent phone number
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      cursorColor: Theme.of(context).colorScheme.primary,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                      onChanged: ((value) => parentPhoneNumber = value),
                      decoration: InputDecoration(
                        hintText: "Enter parent phone number",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
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
                                    selectedParentCountry = value;
                                  },
                                );
                              },
                            );
                          },
                          child: Text(
                            "${selectedParentCountry.flagEmoji} +${selectedParentCountry.phoneCode}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // space for parent phone number
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      cursorColor: Theme.of(context).colorScheme.primary,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                      onChanged: ((value) => studentPhoneNumber = value),
                      decoration: InputDecoration(
                        hintText: "Enter your phone number",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
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
                                    selectedStudentCountry = value;
                                  },
                                );
                              },
                            );
                          },
                          child: Text(
                            "${selectedStudentCountry.flagEmoji} +${selectedStudentCountry.phoneCode}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // sizedbox for spacing
                  const SizedBox(height: 10),

                  // usual route travelled
                  // driver route name
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: StreamBuilder(
                      stream: signUpRoutesBloc.stream,
                      builder: ((context, snapshot) {
                        return Column(
                          children: [
                            DropdownMenu(
                              dropdownMenuEntries: routeNames
                                  .map(
                                    (e) => DropdownMenuEntry(
                                      value: e,
                                      label: e,
                                      style: ButtonStyle(
                                        padding: const MaterialStatePropertyAll(
                                          EdgeInsets.all(10),
                                        ),
                                        shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                        ),
                                        textStyle: MaterialStatePropertyAll(
                                          Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              enabled: signUpRoutesBloc.state !=
                                          SignUpRouteState.notLoaded ||
                                      routeNames.isNotEmpty ||
                                      isUploading
                                  ? true
                                  : false,
                              onSelected: (value) {
                                routeNameSelected = value;
                                signUpRoutesBloc.add(SignUpRouteIsSelected());
                              },
                              inputDecorationTheme: const InputDecorationTheme(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              width: MediaQuery.of(context).size.width * 0.8,
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              hintText: "Select Route Name",
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: snapshot.data == null ||
                                      snapshot.data !=
                                          SignUpRouteState.selected ||
                                      isUploading
                                  ? null
                                  : () async {
                                      if (validateForm()) {
                                        setState(() {
                                          isUploading = true;
                                        });

                                        // here upload the data
                                        await AuthService().uploadStudentData(
                                          studentName: studentName,
                                          studentId:
                                              studentRegNumber.toUpperCase(),
                                          studentEmail: widget.email,
                                          parentPhone:
                                              "+${selectedParentCountry.phoneCode}$parentPhoneNumber",
                                          studentPhone:
                                              "+${selectedStudentCountry.phoneCode}$studentPhoneNumber",
                                          routeTravelled: routeNameSelected,
                                          uid: widget.uid,
                                        );

                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop();

                                        // push to newer screen
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              const SplashPage(),
                                        ));
                                      }
                                    },
                              child: Text(
                                "Sign Up",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: snapshot.data == null ||
                                              snapshot.data !=
                                                  SignUpRouteState.selected ||
                                              isUploading
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                    ),
                              ),
                            ),
                          ],
                        );
                      }),
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
