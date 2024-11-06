import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vit_bus_tracking/bus_driver/driver_routes_bloc.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

class BusDriverInfo extends StatefulWidget {
  const BusDriverInfo({super.key});

  @override
  State<BusDriverInfo> createState() => _BusDriverInfoState();
}

class _BusDriverInfoState extends State<BusDriverInfo> {
  final _formKey = GlobalKey<FormState>();
  final _textFormKey1 = GlobalKey<FormFieldState>();
  final _textFormKey2 = GlobalKey<FormFieldState>();
  final _textFormKey3 = GlobalKey<FormFieldState>();
  final _textFormKey4 = GlobalKey<FormFieldState>();

  String driverName = "";
  String busNumber = "";
  String driverEmployeeNumber = "";
  String driverMobileNumber = "";
  String routeNameSelected = "";

  bool isUploading = false;

  late FirebaseFirestore db;
  List<dynamic> routeNames = [];
  late DriverRoutesBloc driverRoutesBloc;

  void getRoutes() async {
    final docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;

    routeNames = dataMap["route_name"];
    log("$routeNames loaded");

    driverRoutesBloc.add(DriverRouteIsLoaded());
  }

  Future<void> uploadDriverData() async {
    Map<String, dynamic> driverData = {
      "Driver Name": driverName,
      "Bus Number": busNumber,
      "Driver Employee Number": driverEmployeeNumber,
      "Driver Mobile Number": int.parse(driverMobileNumber),
      "Route Name": routeNameSelected,
    };

    await db.collection("bus_driver").doc(driverEmployeeNumber).set(driverData);

    // add a new driver
    final docRef = await db.collection("bus_driver").doc("drivers").get();

    Map<String, dynamic> dataMap = docRef.data() as Map<String, dynamic>;

    Map<String, dynamic> driverMap = dataMap["drivers"] ?? {};
    driverMap.addAll({driverEmployeeNumber: busNumber});

    Map<String, dynamic> employeeMap = dataMap["employees"] ?? {};
    employeeMap.addAll({driverEmployeeNumber: driverName});

    Map<String, dynamic> routeMap = dataMap["route_mapping"] ?? {};
    routeMap.addAll({driverEmployeeNumber: routeNameSelected});

    await db.collection("bus_driver").doc("drivers").set(
      {
        "drivers": driverMap,
        "employees": employeeMap,
        "route_mapping": routeMap,
      },
    );
  }

  bool validateForm() {
    if (driverName.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Driver Name",
        context: context,
      );
      return false;
    }
    if (busNumber.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter bus number",
        context: context,
      );
      return false;
    }
    if (driverEmployeeNumber.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Employee number",
        context: context,
      );
      return false;
    }
    if (driverMobileNumber.isEmpty) {
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
    driverRoutesBloc = DriverRoutesBloc();
    db = FirebaseFirestore.instance;
    driverRoutesBloc.add(DriverRouteIsNotLoaded());
    getRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Driver Info",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // driver name
              TextFormField(
                key: _textFormKey1,
                cursorColor: Theme.of(context).colorScheme.primary,

                // setting the auto focus as true
                autofocus: true,

                // enabled on the uploading variable
                enabled: !isUploading,

                style: Theme.of(context).textTheme.bodyMedium,

                // giving the underline color
                decoration: const InputDecoration(
                  // hint text to add the city name
                  hintText: "Driver Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: ((value) {
                  driverName = value.trim();
                }),
              ),
              const Divider(thickness: 1.5, color: Colors.grey),
              // driver bus number
              TextFormField(
                key: _textFormKey2,
                cursorColor: Theme.of(context).colorScheme.primary,

                // enabled on the uploading variable
                enabled: !isUploading,

                style: Theme.of(context).textTheme.bodyMedium,

                // max length 10
                maxLength: 10,

                // keyboard style
                textCapitalization: TextCapitalization.characters,

                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],

                // giving the underline color
                decoration: const InputDecoration(
                  // hint text to add the city name
                  hintText: "Bus Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                  counterText: "",
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: ((value) {
                  busNumber = value.trim();
                }),
              ),
              const Divider(thickness: 1.5, color: Colors.grey),
              // driver employee number
              TextFormField(
                key: _textFormKey3,
                cursorColor: Theme.of(context).colorScheme.primary,

                // enabled on the uploading variable
                enabled: !isUploading,

                style: Theme.of(context).textTheme.bodyMedium,

                // giving the underline color
                decoration: const InputDecoration(
                  // hint text to add the city name
                  hintText: "Driver Employee Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: ((value) {
                  driverEmployeeNumber = value.trim();
                }),
              ),
              const Divider(thickness: 1.5, color: Colors.grey),
              // driver mobile number
              TextFormField(
                key: _textFormKey4,
                cursorColor: Theme.of(context).colorScheme.primary,

                // enabled on the uploading variable
                enabled: !isUploading,

                style: Theme.of(context).textTheme.bodyMedium,

                // keyboard type
                keyboardType: TextInputType.number,

                // max length
                maxLength: 10,

                // dont allow spaces
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],

                // giving the underline color
                decoration: const InputDecoration(
                  // hint text to add the city name
                  hintText: "Driver Mobile Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                  counterText: "",
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: ((value) {
                  driverMobileNumber = value.trim();
                }),
              ),
              const Divider(thickness: 1.5, color: Colors.grey),
              // driver route name
              StreamBuilder(
                stream: driverRoutesBloc.stream,
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
                                  textStyle: MaterialStatePropertyAll(
                                    Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.background,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        enabled: driverRoutesBloc.state !=
                                    DriverRouteState.notLoaded ||
                                routeNames.isNotEmpty ||
                                isUploading
                            ? true
                            : false,
                        onSelected: (value) {
                          routeNameSelected = value;
                          driverRoutesBloc.add(DriverRouteIsSelected());
                        },
                        inputDecorationTheme: const InputDecorationTheme(
                          activeIndicatorBorder: BorderSide(
                            color: Colors.transparent,
                          ),
                          outlineBorder: BorderSide(
                            color: Colors.transparent,
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        hintText: "Select Route Name",
                        width: MediaQuery.of(context).size.width,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: snapshot.data == null ||
                                snapshot.data != DriverRouteState.selected ||
                                isUploading
                            ? null
                            : () async {
                                if (validateForm()) {
                                  setState(() {
                                    isUploading = true;
                                  });

                                  // here upload the data
                                  await uploadDriverData();

                                  // Pop the screen after uploading
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pop();
                                }
                              },
                        child: Text(
                          "Add Driver",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: snapshot.data == null ||
                                            snapshot.data !=
                                                DriverRouteState.selected ||
                                            isUploading
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // show a circular route
              if (isUploading) const CircularProgressIndicator.adaptive(),
              // --------------------------

              // in the future to add a pic as well

              // --------------------------
            ],
          ),
        ),
      ),
    );
  }
}
