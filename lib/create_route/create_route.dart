import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vit_bus_tracking/model/place.dart';
import 'package:vit_bus_tracking/create_route/search_place.dart';
import 'package:vit_bus_tracking/show_routes/show_route_planned.dart';
import 'package:vit_bus_tracking/utils/color.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

class MakeRoute extends StatefulWidget {
  const MakeRoute({super.key});

  @override
  State<MakeRoute> createState() => _MakeRouteState();
}

class _MakeRouteState extends State<MakeRoute> {
  final _formKey = GlobalKey<FormState>();
  final _textFormKey = GlobalKey<FormFieldState>();

  Place? source;
  Place? destination;
  String routeName = "";

  List<Place> places = [];
  List<dynamic> routeNameUsed = [];

  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
  }

  Future<void> onTap({required where}) async {
    final data = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPlace(),
      ),
    );

    if (data == null) return;

    if (where == "source") {
      source = data;
    } else if (where == "destination") {
      destination = data;
    } else {
      places.last = data;
    }

    setState(() {});
  }

  Future<void> onTapDone() async {
    if (source == null) {
      ShowSnackBar().showSnackBar(
        message: "Enter Source",
        context: context,
      );
    } else if (destination == null) {
      ShowSnackBar().showSnackBar(
        message: "Enter Destination",
        context: context,
      );
    } else if (routeName.isEmpty) {
      ShowSnackBar().showSnackBar(
        message: "Enter Route Name",
        context: context,
      );
    } else if (routeNameUsed.contains(routeName)) {
      ShowSnackBar().showSnackBar(
        message: "Route already exists",
        context: context,
      );
    } else {
      places.insert(0, source!);
      places.insert(places.length, destination!);
      // now push to the next screen and make the way points and all
      bool correct = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShowRoutePlanned(
            pointsOfTravel: places,
            routeName: routeName,
          ),
        ),
      );

      if (correct) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        places.removeLast();
        places.removeAt(0);
        setState(() {});
      }
    }
  }

  Widget addStops() {
    return Column(
      children: [
        ...places
            .map(
              (e) => ListTile(
                title: Text(
                  e.name == '' ? '' : e.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  "Stop",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () async => onTap(where: "stops"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    places.remove(e);
                    setState(() {});
                  },
                ),
              ),
            )
            .toList(),
        ElevatedButton(
          onPressed: () {
            if (places.isEmpty || places.last.name != '') {
              places.add(Place(name: '', eloc: ''));
              setState(() {});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Enter data in last stop first",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: Text(
            "Add stop",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }

  Future<bool> getRouteNames() async {
    var docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;
    routeNameUsed = dataMap["route_name"];

    log("got the routes");
    log(routeNameUsed.toString());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Make route",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          FutureBuilder(
            future: getRouteNames(),
            builder: (context, snapshot) {
              // ignore: unnecessary_null_comparison
              if (snapshot == null || snapshot.data == false) {
                return const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.check),
                );
              } else {
                return IconButton(
                  onPressed: onTapDone,
                  icon: const Icon(Icons.check),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: _textFormKey,
                cursorColor: MyColor.colorPrimary,

                // setting the auto focus as true
                autofocus: true,

                // giving the underline color
                decoration: const InputDecoration(
                  // hint text to add the city name
                  hintText: "Route Name",
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
                  routeName = value.trim();
                }),
              ),
              const Divider(thickness: 1.5, color: Colors.grey),
              ListTile(
                title: Text(
                  source == null ? '' : source!.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  "Source",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () async => onTap(where: "source"),
              ),
              const Divider(thickness: 1.5, color: Colors.grey),
              ListTile(
                title: Text(
                  destination == null ? '' : destination!.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  "Destination",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () async => onTap(where: "destination"),
              ),
              const Divider(thickness: 2, color: Colors.grey),
              Text(
                "Stops",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Divider(thickness: 2, color: Colors.grey),
              addStops(),
            ],
          ),
        ),
      ),
    );
  }
}
