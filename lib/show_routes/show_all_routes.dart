import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vit_bus_tracking/show_routes/show_all_routes_bloc.dart';
import 'package:vit_bus_tracking/show_routes/show_preplanned_route.dart';

class ShowAllRoutes extends StatefulWidget {
  const ShowAllRoutes({super.key});

  @override
  State<ShowAllRoutes> createState() => _ShowAllRoutesState();
}

class _ShowAllRoutesState extends State<ShowAllRoutes> {
  late PlannedRoutesBloc showRoutesBloc;
  late FirebaseFirestore db;

  List<dynamic> routeNames = [];
  String routeNameSelected = "";

  void getRoutes() async {
    final docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;

    routeNames = dataMap["route_name"];
    log("$routeNames loaded");

    showRoutesBloc.add(PlannedRouteIsLoaded());
  }

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    showRoutesBloc = PlannedRoutesBloc();
    showRoutesBloc.add(PlannedRouteIsNotLoaded());
    getRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Select Route',
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
      body: Column(
        children: [
          StreamBuilder(
            stream: showRoutesBloc.stream,
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
                    enabled:
                        showRoutesBloc.state != PlannedRouteState.notLoaded ||
                                routeNames.isNotEmpty
                            ? true
                            : false,
                    onSelected: (value) {
                      routeNameSelected = value;
                      showRoutesBloc.add(PlannedRouteIsSelected());
                    },
                    hintText: "Select Route Name",
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    width: MediaQuery.of(context).size.width,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: snapshot.data == null ||
                            snapshot.data != PlannedRouteState.selected
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ShowPrePlannedRoute(
                                  routeName: routeNameSelected,
                                ),
                              ),
                            );
                          },
                    child: const Text("Search route travelled"),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
