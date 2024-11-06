import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/coordinator_home_page.dart';
import 'package:vit_bus_tracking/login_page/driver_home_page.dart';
import 'package:vit_bus_tracking/login_page/student_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<AccessLevel> futureFunction() async {
    final accessLevel = await AuthService().getAccessLevelFromPrefs();

    await AuthService().detailsPresent();
    log("details found");

    return accessLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: futureFunction(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const CircularProgressIndicator.adaptive();
            } else if (snapshot.data == AccessLevel.driver) {
              return const DriverHomePage();
            } else if (snapshot.data == AccessLevel.coordinator) {
              return const CoordinatorHomePage();
            } else {
              return const StudentHomePage();
            }
          },
        ),
      ),
    );
  }
}
