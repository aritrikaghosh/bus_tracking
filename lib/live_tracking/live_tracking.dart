import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_bus_tracking/model/live_location_model.dart';
import 'package:vit_bus_tracking/live_tracking/live_tracking_bloc.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';
import 'package:wakelock/wakelock.dart';

class LiveTracking extends StatefulWidget {
  const LiveTracking({super.key});

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  // there should be a drop down button on the top for selecting the route
  // dusra sab hamaere apne aap se karna hai
  // route select kia bring the route and draw the poly line and the stops
  // then bring the live location and keep on updating it every 30 seconds

  late FirebaseFirestore db;
  late ShowRoutesBloc showRoutesBloc;
  late MapplsMapController mapController;

  late LatLng origin;
  late LatLng destination;

  bool gotData = false;
  List<Map<String, dynamic>> stopData = [];
  List<Map<String, dynamic>> routeData = [];
  List<LatLng> waypointData = [];
  List<LatLng> routeLatLngData = [];

  List<dynamic> routeNames = [];
  List<String> busTakingTheRoutes = [];

  String routeNameSelected = "";

  late Line line;
  late List<Symbol> symbols = [];

  late TextEditingController dropdownController;

  late Map<String, String> busNumberWithLiveLocation = {};
  late List<Symbol> liveLocations = [];

  Future<void> getBusNumberWithLiveLocation() async {
    // we hae to first get all the bus numbers running on the route
    // then we have to find if they have any current location running
    // if yes then push it to the list

    // get the emp number of the buses with the route number
    var docRef = await db.collection("bus_driver").doc("drivers").get();
    Map<String, dynamic> routeMapping =
        docRef.data()!["route_mapping"] ?? {} as Map<String, dynamic>;
    Map<String, dynamic> drivers =
        docRef.data()!["drivers"] ?? {} as Map<String, dynamic>;

    var busNumberWithRoutes = [];
    routeMapping.forEach(
      (key, value) {
        if (value == routeNameSelected) {
          busNumberWithRoutes.add(drivers[key]);
        }
      },
    );
    // now go to each and every bus and check if we have an active drive there
    // if we do then we have to add it to the busNumberWithLiveLocation

    for (int i = 0; i < busNumberWithRoutes.length; i++) {
      docRef = await db
          .collection("bus_location")
          .doc("bus_${busNumberWithRoutes[i]}")
          .get();
      Map<String, dynamic> data = docRef.data() ?? {};
      if (data.containsKey("active_drive") && data["active_drive"] != "") {
        var busNumber = busNumberWithRoutes[i] as String;
        var routeNumber = data["active_drive"];
        busNumberWithLiveLocation.addAll({busNumber: routeNumber});
      }
    }

    if (busNumberWithLiveLocation.isEmpty && mounted) {
      ShowSnackBar().showSnackBar(
        message: "No active drivers",
        context: context,
      );
      // every 30 seconds we will check again
      await Future.delayed(
        const Duration(seconds: 30),
      );
      getBusNumberWithLiveLocation();
    } else if (busNumberWithLiveLocation.isNotEmpty && mounted) {
      getLiveLocationData();
    }
  }

  Future<void> getLiveLocationData() async {
    // now we have to go to each and every bus
    // go and get the last updated location and put it there

    List<LiveLocationModel> newLocationData = [];

    for (var item in busNumberWithLiveLocation.entries) {
      final busNumber = item.key;
      final activeDrive = item.value;
      dev.log("getting location of this bus -> $busNumber");
      final locationRef = db
          .collection("bus_location")
          .doc("bus_$busNumber")
          .collection(activeDrive);
      final docRef = await locationRef
          .orderBy("time_reached", descending: true)
          .limit(1)
          .get();
      final data = docRef.docs.map((e) => e.data()).toList()[0];
      LatLng position = LatLng(data["latitude"] ?? 0, data["longitude"] ?? 0);
      double bearing = data["bearing"] ?? 0;
      newLocationData.add(
        LiveLocationModel(position: position, bearing: bearing),
      );
    }

    dev.log(newLocationData.toString());

    // first remove the bus symbols
    if (liveLocations.isNotEmpty && mounted) {
      await mapController.removeSymbols(liveLocations);
      liveLocations = [];
    }

    // now add the new symbol
    await addImageFromAsset("icon4", "assets/symbols/car.png");

    for (var item in newLocationData) {
      liveLocations.add(
        await mapController.addSymbol(
          SymbolOptions(
            geometry: item.position,
            iconRotate: (item.bearing + 180) % 360,
            iconImage: "icon4",
            iconSize: 0.2,
          ),
        ),
      );
    }

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: liveLocations[0].options.geometry!,
          zoom: 13.0,
        ),
      ),
    );

    await Future.delayed(
      const Duration(seconds: 30),
    );
    if (mounted) {
      getLiveLocationData();
    }
  }

  Future<void> getPolylineLocationData() async {
    final docRef = await db
        .collection("buses")
        .doc("routes")
        .collection(routeNameSelected)
        .get();
    routeData = docRef.docs.map((e) => e.data()).toList();

    routeData.sort(
      (a, b) => (a["serial"]).compareTo(b["serial"]),
    );

    origin = LatLng(routeData.first["latitude"], routeData.first["longitude"]);
    destination =
        LatLng(routeData.last["latitude"], routeData.last["longitude"]);

    for (var element in routeData) {
      routeLatLngData.add(LatLng(element["latitude"], element["longitude"]));
    }

    final docs = await db
        .collection("buses")
        .doc("stops")
        .collection(routeNameSelected)
        .get();

    stopData = docs.docs.map((e) => e.data()).toList();
    stopData.sort(
      (a, b) => (a["serial"]).compareTo(b["serial"]),
    );

    stopData.removeAt(0);
    stopData.removeLast();

    for (var element in stopData) {
      waypointData.add(LatLng(element["latitude"], element["longitude"]));
    }
  }

  Future<void> addPolyline() async {
    final latlngData = routeLatLngData;
    latlngData.insert(0, origin);
    latlngData.insert(latlngData.length, destination);

    LatLngBounds latLngBounds = boundsFromLatLngList(latlngData);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds));
    line = await mapController.addLine(
      LineOptions(
        geometry: latlngData,
        lineColor: "#000000",
        lineWidth: 4,
      ),
    );

    await addImageFromAsset("icon", "assets/symbols/start.png");
    symbols.add(
      await mapController.addSymbol(
        SymbolOptions(
          geometry: origin,
          iconImage: "icon",
        ),
      ),
    );

    await addImageFromAsset("icon2", "assets/symbols/end.png");
    symbols.add(
      await mapController.addSymbol(
        SymbolOptions(
          geometry: destination,
          iconImage: "icon2",
        ),
      ),
    );

    await addImageFromAsset("icon3", "assets/symbols/custom-icon.png");
    // ignore: avoid_function_literals_in_foreach_calls
    waypointData.forEach(
      (element) async {
        symbols.add(
          await mapController.addSymbol(
            SymbolOptions(
              geometry: element,
              iconImage: "icon3",
            ),
          ),
        );
      },
    );
  }

  Future<void> removePolyline() async {
    await mapController.removeLine(line);
    await mapController.removeSymbols(symbols);
    symbols = [];
    stopData = [];
    routeData = [];
    waypointData = [];
    routeLatLngData = [];
    busNumberWithLiveLocation = {};
    liveLocations = [];
    busTakingTheRoutes = [];
  }

  Future<void> getRoutes() async {
    final docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;

    routeNames = dataMap["route_name"];
    dev.log("$routeNames loaded");

    showRoutesBloc.add(RouteIsLoaded());

    await getDefaultRoute();
  }

  Future<void> getDefaultRoute() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? defaultRoute = sp.getString("routeTravelled");

    if (defaultRoute != null && routeNames.contains(defaultRoute)) {
      routeNameSelected = defaultRoute;
      showRoutesBloc.add(RouteIsSelected());
      dropdownController.setText(routeNameSelected);
      await getPolylineLocationData();
      await addPolyline();
      await getBusNumberWithLiveLocation();
    }
  }

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    showRoutesBloc = ShowRoutesBloc();
    showRoutesBloc.add(RouteIsNotLoaded());
    dropdownController = TextEditingController();
    Wakelock.enable();
    getRoutes();
    // getDefaultRoute(); // this function is in get routes after the routes are found then only we will go with get default route
    // cause there is a possiblity ki route naa ho ya fir delete ho gaya ho uss time pe error naa ayye so we are pushing it there
  }

  @override
  void dispose() {
    showRoutesBloc.close();
    dropdownController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Track the bus",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
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
                    controller: dropdownController,
                    enabled: showRoutesBloc.state != RouteState.notLoaded ||
                            routeNames.isNotEmpty
                        ? true
                        : false,
                    onSelected: (value) async {
                      if (routeNameSelected.isNotEmpty) {
                        showRoutesBloc.add(RouteIsChanged());
                        gotData = false;
                        await removePolyline();
                      } else {
                        showRoutesBloc.add(RouteIsSelected());
                      }
                      routeNameSelected = value!;
                      dropdownController.setText(routeNameSelected);
                      await getPolylineLocationData();
                      await addPolyline();
                      await getBusNumberWithLiveLocation();
                    },
                    hintText: "Select Route Name",
                    width: MediaQuery.of(context).size.width,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: MapplsMap(
              initialCameraPosition: _kInitialPosition,
              onMapCreated: (mapController) {
                this.mapController = mapController;
              },
            ),
          ),
        ],
      ),
    );
  }

  boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null || x1 == null || y0 == null || y1 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return mapController.addImage(name, list);
  }

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(12.840743, 80.153243),
    zoom: 15.0,
  );
}
