import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_bus_tracking/bus_driver/bus_driver.dart';
import 'package:vit_bus_tracking/create_route/create_route.dart';
import 'package:vit_bus_tracking/delete_route/delete_route.dart';
import 'package:vit_bus_tracking/live_tracking/live_tracking.dart';
import 'package:vit_bus_tracking/login_page/auth_page.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';
import 'package:vit_bus_tracking/show_drives/show_drivers.dart';
import 'package:vit_bus_tracking/show_routes/show_all_routes.dart';

class CoordinatorHomePage extends StatefulWidget {
  const CoordinatorHomePage({super.key});

  @override
  State<CoordinatorHomePage> createState() => _CoordinatorHomePageState();
}

class _CoordinatorHomePageState extends State<CoordinatorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coordinator Home Page"),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (builderContext) => const SplashPage(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            onPressed: () async {
              await AuthService().handelSignOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AuthPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/route.png",
                      height: 100,
                    ),
                    const Text(
                      "Show Routes",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShowAllRoutes(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/bus.png",
                      height: 100,
                    ),
                    const Text(
                      "Live Tracking",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LiveTracking(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/driver.png",
                      height: 100,
                    ),
                    const Text(
                      "Driver Details",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BusDriverInfo(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/delete.png",
                      height: 100,
                    ),
                    const Text(
                      "Delete Route",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeleteRoute(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/travelled.png",
                      height: 100,
                    ),
                    const Text(
                      "Previous Route Travelled",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShowDrivers(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/plan.png",
                      height: 100,
                    ),
                    const Text(
                      "Planned Routes",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShowAllRoutes(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/create.png",
                      height: 100,
                    ),
                    const Text(
                      "Create Route",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MakeRoute(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
