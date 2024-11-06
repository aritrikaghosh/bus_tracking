// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:vit_bus_tracking/utils/color.dart';

class ShowRoute extends StatefulWidget {
  const ShowRoute({
    super.key,
    required this.busNumber,
    required this.timeSelected,
  });

  final busNumber;
  final timeSelected;

  @override
  State<ShowRoute> createState() => _ShowRouteState();
}

class _ShowRouteState extends State<ShowRoute> {
  late MapplsMapController mapController;
  late FirebaseFirestore db;

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(12.840743, 80.153243),
    zoom: 15.0,
  );

  void addPolyline() async {
    final snapshot = await db
        .collection('bus_location')
        .doc("bus_${widget.busNumber}")
        .collection(widget.timeSelected)
        .get();
    final data2 = snapshot.docs.map((e) => e.data()).toList();
    data2.sort(
      (a, b) => (a["time_reached"]).compareTo(b["time_reached"]),
    );

    final latlngData =
        data2.map((e) => LatLng(e["latitude"], e["longitude"])).toList();
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
    mapController.addSymbol(
      SymbolOptions(
        geometry: latlngData.first,
        iconImage: "icon",
      ),
    );

    await addImageFromAsset("icon2", "assets/symbols/end.png");
    mapController.addSymbol(
      SymbolOptions(
        geometry: latlngData.last,
        iconImage: "icon2",
      ),
    );
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return mapController.addImage(name, list);
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

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.colorPrimary,
        title: const Text('Show Route Travelled'),
      ),
      body: MapplsMap(
        initialCameraPosition: _kInitialPosition,
        onMapCreated: (mapController) {
          this.mapController = mapController;
        },
        onStyleLoadedCallback: () {
          addPolyline();
        },
      ),
    );
  }
}
