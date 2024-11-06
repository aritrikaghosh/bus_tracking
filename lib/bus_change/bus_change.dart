import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_bus_tracking/bus_change/destination_route_bloc.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

class BusChange extends StatefulWidget {
  const BusChange({super.key});

  @override
  State<BusChange> createState() => _BusChangeState();
}

class _BusChangeState extends State<BusChange> {
  final _formKey = GlobalKey<FormState>();
  final _textFormKey1 = GlobalKey<FormFieldState>();
  final _textFormKey2 = GlobalKey<FormFieldState>();
  final _textFormKey3 = GlobalKey<FormFieldState>();

  bool isUploading = false;

  late FirebaseFirestore db;
  late DestinationRoutesBloc destinationRoutesBloc;

  String name = "";
  String regNumber = "";
  String currentRouteTravlled = "";
  String destination = "";

  List<dynamic> routeNames = [];

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    destinationRoutesBloc = DestinationRoutesBloc();
    destinationRoutesBloc.add(DestinationRouteIsNotLoaded());
    getRoutes();
  }

  void getRoutes() async {
    final docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;

    routeNames = dataMap["route_name"];
    log("$routeNames loaded");

    destinationRoutesBloc.add(DestinationRouteIsLoaded());
  }

  void verifyAndUpload() async {
    setState(() {
      isUploading = true;
    });

    if (name.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Student Name",
        context: context,
      );
    } else if (regNumber.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Reg Number",
        context: context,
      );
    } else if (currentRouteTravlled.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter current bus number",
        context: context,
      );
    } else if (destination.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Destination",
        context: context,
      );
    } else {
      Map<String, dynamic> data = {
        "busNo": currentRouteTravlled,
        "location": destination,
        "regNo": regNumber,
        "studentName": name,
      };
      await db.collection("requests").doc(regNumber).set(data);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }

    setState(() {
      isUploading = false;
    });
  }

  Future<bool> getDetails() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    name = sp.getString("name") ?? "";
    regNumber = sp.getString("studentId") ?? "";
    currentRouteTravlled = sp.getString("routeTravelled") ?? "";
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Request Bus Change",
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
      body: isUploading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : FutureBuilder(
              future: getDetails(),
              builder: (context, snapshot) => (snapshot.data == null)
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // driver name
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextFormField(
                                  key: _textFormKey1,
                                  cursorColor:
                                      Theme.of(context).colorScheme.primary,

                                  // setting the auto focus as true
                                  autofocus: true,

                                  // enabled on the uploading variable
                                  enabled: name.isEmpty ? true : false,

                                  initialValue: name,

                                  style: Theme.of(context).textTheme.bodyMedium,

                                  // giving the underline color
                                  decoration: InputDecoration(
                                    // hint text to add the city name
                                    hintText: "Student Name",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  onTapOutside: (event) => FocusManager
                                      .instance.primaryFocus
                                      ?.unfocus(),
                                  onChanged: ((value) {
                                    name = value.trim();
                                  }),
                                ),
                              ),

                              const SizedBox(height: 10),
                              // driver bus number
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextFormField(
                                  key: _textFormKey2,
                                  cursorColor:
                                      Theme.of(context).colorScheme.primary,

                                  // enabled on the uploading variable
                                  enabled: regNumber.isEmpty ? true : false,

                                  initialValue: regNumber,

                                  style: Theme.of(context).textTheme.bodyMedium,

                                  // max length 10
                                  maxLength: 10,

                                  // keyboard style
                                  textCapitalization:
                                      TextCapitalization.characters,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s')),
                                  ],

                                  // giving the underline color
                                  decoration: InputDecoration(
                                    // hint text to add the city name
                                    hintText: "Reg Number",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                    counterText: "",
                                  ),
                                  onTapOutside: (event) => FocusManager
                                      .instance.primaryFocus
                                      ?.unfocus(),
                                  onChanged: ((value) {
                                    regNumber = value.trim();
                                  }),
                                ),
                              ),

                              const SizedBox(height: 10),
                              // driver employee number
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextFormField(
                                  key: _textFormKey3,
                                  cursorColor:
                                      Theme.of(context).colorScheme.primary,

                                  // enabled on the uploading variable
                                  enabled: currentRouteTravlled.isEmpty
                                      ? true
                                      : false,

                                  initialValue: currentRouteTravlled,

                                  style: Theme.of(context).textTheme.bodyMedium,

                                  // giving the underline color
                                  decoration: InputDecoration(
                                    // hint text to add the city name
                                    hintText: "Current Bus Number",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  onTapOutside: (event) => FocusManager
                                      .instance.primaryFocus
                                      ?.unfocus(),
                                  onChanged: ((value) {
                                    currentRouteTravlled = value.trim();
                                  }),
                                ),
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: StreamBuilder(
                                  stream: destinationRoutesBloc.stream,
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
                                                    padding:
                                                        const MaterialStatePropertyAll(
                                                      EdgeInsets.all(10),
                                                    ),
                                                    shape:
                                                        MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          100,
                                                        ),
                                                      ),
                                                    ),
                                                    textStyle:
                                                        MaterialStatePropertyAll(
                                                      Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          enabled:
                                              destinationRoutesBloc.state !=
                                                          DestinationRouteState
                                                              .notLoaded ||
                                                      routeNames.isNotEmpty ||
                                                      isUploading
                                                  ? true
                                                  : false,
                                          onSelected: (value) {
                                            destination = value;
                                            destinationRoutesBloc.add(
                                                DestinationRouteIsSelected());
                                          },
                                          inputDecorationTheme:
                                              const InputDecorationTheme(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(100),
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.all(10),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          hintText: "Select Route Name",
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: snapshot.data == null ||
                                                  snapshot.data !=
                                                      DestinationRouteState
                                                          .selected ||
                                                  isUploading
                                              ? null
                                              : verifyAndUpload,
                                          child: Text(
                                            "Submit Request",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: snapshot.data ==
                                                              null ||
                                                          snapshot.data !=
                                                              DestinationRouteState
                                                                  .selected ||
                                                          isUploading
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .error
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
