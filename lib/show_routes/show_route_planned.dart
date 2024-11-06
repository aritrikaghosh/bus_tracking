// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vit_bus_tracking/model/place.dart';
import 'package:vit_bus_tracking/plugin/tracking_plugin.dart';
import 'package:vit_bus_tracking/utils/polyline.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:turf/helpers.dart';

class ShowRoutePlanned extends StatefulWidget {
  const ShowRoutePlanned(
      {super.key, required this.pointsOfTravel, required this.routeName});

  final List<Place> pointsOfTravel;
  final String routeName;

  @override
  State<ShowRoutePlanned> createState() => _ShowRoutePlannedState();
}

class _ShowRoutePlannedState extends State<ShowRoutePlanned>
    with TickerProviderStateMixin {
  late MapplsMapController? mapController;
  late FirebaseFirestore db;

  TrackingPlugin? _trackingPlugin;
  List<LatLng> _travelledPoints = [];
  List<LatLng> _waypoints = [];

  bool isUploading = false;

  late Place origin;
  late Place destination;
  late List<String> waypointsMappls;

  @override
  void initState() {
    super.initState();
    origin = widget.pointsOfTravel.first;
    destination = widget.pointsOfTravel.last;
    db = FirebaseFirestore.instance;
  }

  callRouteETA() async {
    try {
      // so idhar we will get the locaiton of the bus
      // let us assume that we would get the bus number and all in the input

      // this would be having the main route
      // jo starting me hoga vo

      // replace this but the route that would be followed
      DirectionResponse? directionResponse = await MapplsDirection(
        originMapplsPin: origin.eloc,
        destinationMapplsPin: destination.eloc,
        waypointMapplsPin: widget.pointsOfTravel.map((e) => e.eloc).toList(),
        alternatives: true,
        steps: true,
        overview: DirectionCriteria.OVERVIEW_FULL,
        resource: DirectionCriteria.RESOURCE_ROUTE,
        routeType: DirectionCriteria.ROUTE_TYPE_OPTIMAL,
      ).callDirection();

      // log(directionResponse!.routes.toString());

      // we are drawing the initial route here
      // then we would call the travelled route
      if (directionResponse != null &&
          directionResponse.routes != null &&
          directionResponse.routes!.isNotEmpty) {
        Polyline polyline = Polyline.decode(
            encodedString: directionResponse.routes![0].geometry, precision: 6);
        List<LatLng> latLngList = [];
        if (polyline.decodedCoords != null) {
          polyline.decodedCoords?.forEach((element) {
            latLngList.add(LatLng(element[0], element[1]));
          });
          _travelledPoints = latLngList;

          _trackingPlugin?.drawPolyline(latLngList);
          await addImageFromAsset("icon", "assets/symbols/start.png");
          mapController?.addSymbol(
            SymbolOptions(
              mapplsPin: origin.eloc,
              iconImage: "icon",
            ),
          );

          await addImageFromAsset("icon2", "assets/symbols/end.png");
          mapController?.addSymbol(
            SymbolOptions(
              mapplsPin: destination.eloc,
              iconImage: "icon2",
            ),
          );

          waypointsMappls = widget.pointsOfTravel.map((e) => e.eloc).toList();

          waypointsMappls.remove(origin.eloc);
          waypointsMappls.remove(destination.eloc);

          await addImageFromAsset("icon3", "assets/symbols/custom-icon.png");

          waypointsMappls.forEach(
            (element) async {
              await mapController?.addSymbol(
                SymbolOptions(
                  mapplsPin: element,
                  iconImage: "icon3",
                ),
              );
            },
          );

          LatLngBounds latLngBounds = boundsFromLatLngList(latLngList);
          mapController
              ?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds));

          // this is where we would get the locations hahahaha

          // --------------------------------------------------

          _waypoints = [];

          for (int i = 0; i < directionResponse.waypoints!.length; i++) {
            DirectionsWaypoint waypoint = directionResponse.waypoints![i];
            final latitude = round(waypoint.location!.latitude, 4);
            final longitude = round(waypoint.location!.longitude, 4);
            final data = LatLng(latitude as double, longitude as double);
            if (_waypoints.contains(data) == false) {
              _waypoints.add(data);
            }
          }
        }
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        log(e.message.toString());
      }
    }
  }

  void uploadPoints() async {
    setState(() {
      isUploading = true;
    });

    // get the last updated route and update it too
    var docRef = await db.collection("buses").doc("route_name").get();

    final dataMap = docRef.data() as Map<String, dynamic>;

    List<dynamic> newRouteNames = dataMap["route_name"];
    newRouteNames.add(widget.routeName);

    await db.collection("buses").doc("route_name").set(
      {
        "route_name": newRouteNames,
      },
    );

    int index = 0;
    _travelledPoints.forEach(
      (element) async {
        await db
            .collection("buses")
            .doc("routes")
            .collection(widget.routeName)
            .add(
          {
            "serial": index++,
            "latitude": element.latitude,
            "longitude": element.longitude,
          },
        );
      },
    );

    index = 0;

    _waypoints.forEach(
      (element) async {
        await db
            .collection("buses")
            .doc("stops")
            .collection(widget.routeName)
            .add(
          {
            "serial": index++,
            "latitude": element.latitude,
            "longitude": element.longitude,
          },
        );
        index += 1;
      },
    );

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          isUploading ? 'Uploading' : 'Planning',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isUploading
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isUploading ? null : uploadPoints,
          )
        ],
      ),
      body: isUploading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : MapplsMap(
              initialCameraPosition: _kInitialPosition,
              onMapError: (code, message) => {log('$code -------- $message')},
              onMapCreated: (map) => {mapController = map},
              onStyleLoadedCallback: () async => {
                _trackingPlugin = TrackingPlugin(mapController!, this),
                await callRouteETA()
              },
            ),
    );
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return mapController?.addImage(name, list);
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

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(12.840743, 80.153243),
    zoom: 15.0,
  );
}
