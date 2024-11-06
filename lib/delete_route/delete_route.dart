import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vit_bus_tracking/delete_route/delete_routes_bloc.dart';
import 'package:wakelock/wakelock.dart';

class DeleteRoute extends StatefulWidget {
  const DeleteRoute({super.key});

  @override
  State<DeleteRoute> createState() => _DeleteRouteState();
}

class _DeleteRouteState extends State<DeleteRoute> {
  late DeleteRoutesBloc deleteRouteBloc;
  late FirebaseFirestore db;

  List<dynamic> listRoutes = [];

  String selectedRouteName = "";

  bool deleteButtonPressed = false;
  bool deleting = false;

  Future<void> getRouteNames() async {
    final doc = await db.collection("buses").doc("route_name").get();
    listRoutes = doc.data()!["route_name"];
    listRoutes = listRoutes.map((e) => e.toString()).toList();
    log(listRoutes.toString());
    deleteRouteBloc.add(RouteIsLoaded());
  }

  Future<void> deleteSelectedRoute() async {
    deleting = true;
    setState(() {});

    log("deleting from route_name");

    // deleting the route name
    var doc = await db.collection("buses").doc("route_name").get();
    final dataMap = doc.data() as Map<String, dynamic>;

    List<dynamic> routeNames = dataMap["route_name"];
    routeNames.remove(selectedRouteName);

    await db.collection("buses").doc("route_name").set(
      {"route_name": routeNames},
    );

    log("deleted from route_name");

    log("deleting the route itself");
    // delete the route
    var docRef = await db
        .collection("buses")
        .doc("routes")
        .collection(selectedRouteName)
        .get();
    var routeData = docRef.docs.map((e) => e.id).toList();
    for (int i = 0; i < routeData.length; i++) {
      await db
          .collection("buses")
          .doc("routes")
          .collection(selectedRouteName)
          .doc(routeData[i])
          .delete();
    }

    log("route deleted");
    log("deleting the stop");

    // delete the stops
    docRef = await db
        .collection("buses")
        .doc("stops")
        .collection(selectedRouteName)
        .get();
    routeData = docRef.docs.map((e) => e.id).toList();
    for (int i = 0; i < routeData.length; i++) {
      await db
          .collection("buses")
          .doc("stops")
          .collection(selectedRouteName)
          .doc(routeData[i])
          .delete();
    }

    log("deleted stops");

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    Wakelock.enable();
    deleteRouteBloc = DeleteRoutesBloc();
    db = FirebaseFirestore.instance;
    deleteRouteBloc.add(RouteIsNotLoaded());
    getRouteNames();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Delete Route',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
        leading: const SizedBox(),
      ),
      body: !deleting
          ? Column(
              children: [
                if (deleteButtonPressed)
                  MaterialBanner(
                    content: const Text('Do you want to delete it?'),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.delete_forever),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: deleteSelectedRoute,
                        child: const Text('Yes Delete It'),
                      ),
                      ElevatedButton(
                        child: const Text('Do Not Delete'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                StreamBuilder(
                  stream: deleteRouteBloc.stream,
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
                          enabled: deleteRouteBloc.state !=
                                      DeleteRouteState.notLoaded ||
                                  listRoutes.isNotEmpty
                              ? true
                              : false,
                          onSelected: (value) {
                            selectedRouteName = value;
                            deleteRouteBloc.add(RouteIsSelected());
                          },
                          hintText: "Bus Time",
                          width: MediaQuery.of(context).size.width,
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: snapshot.data == null ||
                                  snapshot.data != DeleteRouteState.selected
                              ? null
                              : () {
                                  // give one more button
                                  // are you sure kar ke
                                  // agar udhar yes ayye to hi karo
                                  deleteButtonPressed = true;
                                  setState(() {});
                                },
                          child: Text(
                            "Delete Route",
                            style: Theme.of(context).textTheme.bodyMedium!,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
    );
  }
}
