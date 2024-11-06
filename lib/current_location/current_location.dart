import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:vit_bus_tracking/model/stop.dart';

import 'package:vit_bus_tracking/plugin/tracking_plugin.dart';
import 'package:vit_bus_tracking/current_location/current_location_bloc.dart';
import 'package:mappls_gl/mappls_gl.dart';

import 'package:wakelock/wakelock.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CurrentLocationState();
  }
}

class _CurrentLocationState extends State with TickerProviderStateMixin {
  late MapplsMapController? controller;
  late FirebaseFirestore db;
  late CurrentLocationBloc currentLocationBloc;

  TrackingPlugin? _trackingPlugin;
  List<LatLng> travelledPoints = [];
  bool isDispose = false;
  bool doesDocExists = false;
  int count = 0;

  bool isBroken = false;

  // lets remove the hard coding
  // and get the route number dynamically

  // final busNumber = "GJ10AP3596";
  // final routeNumber = 69;

  final String employeeNumber = "10022617";

  late final String busNumber;
  late final String routeName;

  late Map<String, Stop> stops = {};
  late Map<String, dynamic> reachedStop = {};

  final todayDateTime = Timestamp.fromDate(DateTime.now()).toDate().toString();

  void setPermission() async {
    final location = Location();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.granted) {
      await location.requestPermission();
    }
    if (hasPermissions != PermissionStatus.denied ||
        hasPermissions != PermissionStatus.deniedForever) {
      setPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    currentLocationBloc = CurrentLocationBloc();
    setPermission();
  }

  @override
  void dispose() {
    isDispose = true;
    _trackingPlugin?.dispose();
    controller = null;
    _trackingPlugin = null;
    currentLocationBloc.close();
    super.dispose();
  }

  void travelledRoute() {
    if (mounted && !isDispose) {
      _trackingPlugin?.drawPolyline(travelledPoints);
    }
  }

  Future<void> getStopData() async {
    // first get the route number for the bus
    var docRef = await db.collection("bus_driver").doc("drivers").get();
    Map<String, dynamic> routeMapping =
        docRef.data()!["route_mapping"] ?? {} as Map<String, dynamic>;
    Map<String, dynamic> drivers =
        docRef.data()!["drivers"] ?? {} as Map<String, dynamic>;

    routeMapping.forEach(
      (key, value) {
        if (key == employeeNumber) {
          routeName = value;
        }
      },
    );

    drivers.forEach(
      (key, value) {
        if (key == employeeNumber) {
          busNumber = value;
        }
      },
    );

    var stopDocs =
        await db.collection("buses").doc("stops").collection(routeName).get();

    var stopData = stopDocs.docs.map((e) => e.data()).toList();
    stopData.sort(
      (a, b) => (a["serial"]).compareTo(b["serial"]),
    );

    for (int i = 0; i < stopData.length; i++) {
      Map<String, dynamic> ele = stopData[i];
      stops.addAll(
        {
          ele["serial"].toString(): Stop(
            latitude: ele["latitude"],
            longitude: ele["longitude"],
            serial: ele["serial"],
          )
        },
      );
    }

    reachedStop.addAll({"currentStop": "0"});
    reachedStop.addAll({"emergency": isBroken});
    reachedStop.addAll({"id": busNumber});

    await db.collection("notifications").doc("bus_$busNumber").set(reachedStop);
  }

  Future<void> removeFromActiveDrive() async {
    var docRef =
        await db.collection("bus_location").doc("bus_$busNumber").get();
    final dataMap = docRef.data() as Map<String, dynamic>;
    final drives = dataMap["drives"];
    await db.collection("bus_location").doc("bus_$busNumber").set(
      {
        "drives": drives,
        "active_drive": "",
      },
    );
  }

  Future<void> storeData(UserLocation location) async {
    final userData = <String, dynamic>{
      "longitude": location.position.longitude,
      "latitude": location.position.latitude,
      "speed": location.speed ?? 0 * 3.6,
      "bus_number": busNumber,
      "route_name": routeName,
      "is_broken": isBroken,
      "bearing": location.bearing,
      "time_reached": Timestamp.now(),
    };

    // first check if we have a doc for the particular bus number or not
    // then we will be adding the data to the collection of that doc

    if (!doesDocExists) {
      try {
        log("reading data");
        var docRef =
            await db.collection("bus_location").doc("bus_$busNumber").get();

        doesDocExists = true;

        final dataMap = docRef.data() as Map<String, dynamic>;
        final drives = dataMap["drives"] + [todayDateTime.toString()];
        await db.collection("bus_location").doc("bus_$busNumber").set(
          {
            "drives": drives,
            "active_drive": todayDateTime.toString(),
          },
        );
      } catch (e) {
        log("doc doesnt exists adding it");
        await db.collection("bus_location").doc("bus_$busNumber").set({
          "drives": [todayDateTime.toString()],
          "active_drive": todayDateTime.toString(),
        });
        doesDocExists = true;
      }
    }

    await db
        .collection("bus_location")
        .doc("bus_$busNumber")
        .collection(todayDateTime.toString())
        .add(userData);

    // ab jo jo points are false we have to count the distance
    // fir like update it

    Map<String, dynamic> newStopReached = {};

    log("checking for stops");
    String lastReached = reachedStop["currentStop"];

    stops.forEach(
      (key, value) {
        // first check ki like vo false hai ki nahi
        log("$key not reached checking");
        // now calculate the distance using the value
        double distance = haversineDistance(value.latitude, value.longitude,
            location.position.latitude, location.position.longitude);

        if (distance <= 200) {
          log("$key reached changing lastReached");
          lastReached = key;
        }
      },
    );

    newStopReached.addAll(
      {
        "currentStop": lastReached,
        "emergency": isBroken,
        "id": busNumber,
      },
    );

    log("checked $newStopReached");

    if (newStopReached != reachedStop) {
      reachedStop = newStopReached;
      await db
          .collection("notifications")
          .doc("bus_$busNumber")
          .set(reachedStop);
    }

    if (count != 1) count = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Current Location',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MapplsMap(
              initialCameraPosition: _kInitialPosition,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.Tracking,
              onUserLocationUpdated: (location) async {
                if (currentLocationBloc.state == ButtonState.startNavigation) {
                  log("Position: ${location.position.toString()}, Speed: ${location.speed}, Altitude: ${location.altitude} bearing:-${location.bearing}");
                  log("time -> ${DateTime.now()}");
                  travelledPoints.add(
                    LatLng(
                      location.position.latitude,
                      location.position.longitude,
                    ),
                  );
                  travelledRoute();
                  await storeData(location);
                } else if (count != 0) {
                  await removeFromActiveDrive();
                  count = 0;
                }
              },
              onMapCreated: (map) => (controller = map),
              myLocationRenderMode: MyLocationRenderMode.GPS,
              onStyleLoadedCallback: () async {
                _trackingPlugin = TrackingPlugin(controller!, this);
                await getStopData();
                currentLocationBloc.add(ButtonStopNavigation());
              },
            ),
          ),
          StreamBuilder(
            stream: currentLocationBloc.stream,
            builder: (context, snapshot) {
              log(snapshot.data.toString());
              return ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStatePropertyAll(
                    Size(
                      MediaQuery.of(context).size.width,
                      30,
                    ),
                  ),
                ),
                onPressed: snapshot.data == ButtonState.isDisabled ||
                        snapshot.data == null
                    ? null
                    : () {
                        if (snapshot.data == ButtonState.startNavigation) {
                          Wakelock.disable();
                          currentLocationBloc.add(ButtonStopNavigation());
                        } else {
                          Wakelock.enable();
                          currentLocationBloc.add(ButtonStartNavigation());
                        }
                      },
                child: Text(
                  snapshot.data == ButtonState.isDisabled ||
                          snapshot.data == null
                      ? "Wait"
                      : snapshot.data == ButtonState.stopNavigation
                          ? "Start Navigation"
                          : "Stop Navigation",
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(12.840743, 80.153243),
    zoom: 15.0,
  );

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    var R = 6371e3; // meters
    var phi1 = (lat1 * math.pi) / 180;
    var phi2 = (lat2 * math.pi) / 180;
    var deltaPhi = ((lat2 - lat1) * math.pi) / 180;
    var deltaLambda = ((lon2 - lon1) * math.pi) / 180;

    var a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);

    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    var d = R * c; // in meters

    return d;
  }
}
