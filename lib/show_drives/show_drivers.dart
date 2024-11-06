import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vit_bus_tracking/show_drives/show_drivers_bloc.dart';
import 'package:vit_bus_tracking/show_drives/show_routes_bloc.dart';
import 'package:vit_bus_tracking/show_drives/show_route_travelled.dart';

class ShowDrivers extends StatefulWidget {
  const ShowDrivers({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShowDriversState();
  }
}

class _ShowDriversState extends State {
  // first we have to get the list of the drivers
  // uss time tak we have to keep the other two things disabled

  // then after selecting the driver we would select the drive
  // then we would pass this info to the driver info and get it done

  // we can use bloc for this

  late FirebaseFirestore db;
  late ShowDriversBloc showDriversBloc;
  late ShowRoutesBloc showRoutesBloc;
  List<String> listDrivers = [];
  List<dynamic> listRoutes = [];

  String driverSelected = "";
  String busTimeSelected = "";

  @override
  void initState() {
    super.initState();
    // get data from bloc
    db = FirebaseFirestore.instance;
    showDriversBloc = ShowDriversBloc();
    showRoutesBloc = ShowRoutesBloc();
    showDriversBloc.add(DriverIsNotLoaded());
    showRoutesBloc.add(RouteIsNotLoaded());
    getDrivers();
  }

  void getDrivers() async {
    await db.collection("bus_location").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          listDrivers.add(docSnapshot.id.split("_")[1]);
        }
      },
    );
    showDriversBloc.add(DriverIsLoaded());
  }

  void getRoutes() async {
    log("getting routes $driverSelected");
    final doc =
        await db.collection("bus_location").doc("bus_$driverSelected").get();
    listRoutes = doc.data()!["drives"];
    listRoutes = listRoutes.map((e) => e.toString()).toList();
    showRoutesBloc.add(RouteIsLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Show Drive',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: showDriversBloc.stream,
            builder: (context, snapshot) {
              return DropdownMenu(
                dropdownMenuEntries: listDrivers
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
                enabled: showDriversBloc.state != DriverState.notLoaded ||
                        listDrivers.isNotEmpty
                    ? true
                    : false,
                hintText: "Bus Number",
                width: MediaQuery.of(context).size.width,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                onSelected: (value) {
                  driverSelected = value!;
                  showDriversBloc.add(DriverIsSelected());
                  showRoutesBloc.add(RouteIsNotLoaded());
                  getRoutes();
                },
              );
            },
          ),
          StreamBuilder(
            stream: showRoutesBloc.stream,
            builder: ((context, snapshot) {
              return Column(
                children: [
                  DropdownMenu(
                    dropdownMenuEntries: listRoutes
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
                    enabled: showRoutesBloc.state != RouteState.notLoaded ||
                            listRoutes.isNotEmpty
                        ? true
                        : false,
                    onSelected: (value) {
                      busTimeSelected = value;
                      showRoutesBloc.add(RouteIsSelected());
                    },
                    hintText: "Bus Time",
                    width: MediaQuery.of(context).size.width,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: snapshot.data == null ||
                            snapshot.data != RouteState.selected
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ShowRoute(
                                  busNumber: driverSelected,
                                  timeSelected: busTimeSelected,
                                ),
                              ),
                            );
                          },
                    child: Text(
                      "Search route travelled",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
