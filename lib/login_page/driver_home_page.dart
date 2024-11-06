import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_bus_tracking/current_location/current_location.dart';
import 'package:vit_bus_tracking/login_page/auth_page.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';
import 'package:vit_bus_tracking/live_tracking/live_tracking.dart';
import 'package:vit_bus_tracking/show_routes/show_all_routes.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Home Page"),
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
                      "assets/live.png",
                      height: 100,
                    ),
                    const Text(
                      "Start Journey",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CurrentLocation(),
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
