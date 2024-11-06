import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_bus_tracking/bus_change/bus_change.dart';
import 'package:vit_bus_tracking/firebase_api/firebase_api.dart';
import 'package:vit_bus_tracking/login_page/auth_page.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';
import 'package:vit_bus_tracking/live_tracking/live_tracking.dart';
import 'package:vit_bus_tracking/show_routes/show_all_routes.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseApi().initNotifications();
    FirebaseApi().subscribeToTopic("GJ10AP3596");
    FirebaseApi().subscribeToTopic("2");
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        log("onMessageOpenedApp: $message");
        var title = message.notification?.title;
        var body = message.notification?.body;
        var category = message.data.values.toString();
        log("category: $category");

        if (category == "(emergency)") {
          showEmergencyDialog(title, body);
        } else if (category == "(update)") {
          showUpdateDialog(title, body);
        }
      },
    );
  }

  void showEmergencyDialog(var title, var body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actionsPadding: const EdgeInsets.only(top: 10),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: Color(0xFFEF9A9A),
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text(title),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(body),
            ),
          ],
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void showUpdateDialog(var title, var body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actionsPadding: const EdgeInsets.only(top: 10),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: Color.fromARGB(188, 198, 198, 198),
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text(title),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(body),
            ),
          ],
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student View",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
              Navigator.of(context).pop();
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
                      "assets/request.png",
                      height: 100,
                    ),
                    const Text(
                      "Request For Bus change",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BusChange(),
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
