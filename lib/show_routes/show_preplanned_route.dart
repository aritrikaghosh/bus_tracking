import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mappls_gl/mappls_gl.dart';

class ShowPrePlannedRoute extends StatefulWidget {
  const ShowPrePlannedRoute({super.key, required this.routeName});

  final String routeName;

  @override
  State<ShowPrePlannedRoute> createState() => _ShowPrePlannedRouteState();
}

class _ShowPrePlannedRouteState extends State<ShowPrePlannedRoute> {
  late FirebaseFirestore db;
  late MapplsMapController mapController;

  late LatLng origin;
  late LatLng destination;

  bool gotData = false;
  List<Map<String, dynamic>> stopData = [];
  List<Map<String, dynamic>> routeData = [];
  List<LatLng> waypointData = [];
  List<LatLng> routeLatLngData = [];

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(12.840743, 80.153243),
    zoom: 15.0,
  );

  void getLocationData() async {
    final docRef = await db
        .collection("buses")
        .doc("routes")
        .collection(widget.routeName)
        .get();
    routeData = docRef.docs.map((e) => e.data()).toList();

    routeData.sort(
      (a, b) => (a["serial"]).compareTo(b["serial"]),
    );

    log(routeData.toString());
    origin = LatLng(routeData.first["latitude"], routeData.first["longitude"]);
    destination =
        LatLng(routeData.last["latitude"], routeData.last["longitude"]);

    for (var element in routeData) {
      routeLatLngData.add(LatLng(element["latitude"], element["longitude"]));
    }

    final docs = await db
        .collection("buses")
        .doc("stops")
        .collection(widget.routeName)
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

    setState(() {
      gotData = true;
    });
  }

  Future<void> addPolyline() async {
    final latlngData = routeLatLngData;
    latlngData.insert(0, origin);
    latlngData.insert(latlngData.length, destination);

    LatLngBounds latLngBounds = boundsFromLatLngList(latlngData);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds));
    mapController.addLine(
      LineOptions(
        geometry: latlngData,
        lineColor: "#000000",
        lineWidth: 4,
      ),
    );

    await addImageFromAsset("icon", "assets/symbols/start.png");
    await mapController.addSymbol(
      SymbolOptions(
        geometry: origin,
        iconImage: "icon",
      ),
    );

    await addImageFromAsset("icon2", "assets/symbols/end.png");
    await mapController.addSymbol(
      SymbolOptions(
        geometry: destination,
        iconImage: "icon2",
      ),
    );

    await addImageFromAsset("icon3", "assets/symbols/custom-icon.png");
    // ignore: avoid_function_literals_in_foreach_calls
    waypointData.forEach(
      (element) async {
        await mapController.addSymbol(
          SymbolOptions(
            geometry: element,
            iconImage: "icon3",
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    getLocationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "${widget.routeName} Route",
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
      ),
      body: gotData == false
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : MapplsMap(
              initialCameraPosition: _kInitialPosition,
              onMapCreated: (mapController) {
                this.mapController = mapController;
              },
              onStyleLoadedCallback: () async {
                await addPolyline();
              },
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
}
