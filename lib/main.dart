import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vit_bus_tracking/firebase_options.dart';
import 'package:vit_bus_tracking/bus_driver/driver_routes_bloc.dart';
import 'package:vit_bus_tracking/current_location/current_location_bloc.dart';
import 'package:vit_bus_tracking/delete_route/delete_routes_bloc.dart';
import 'package:vit_bus_tracking/firebase_api/firebase_api.dart';
import 'package:vit_bus_tracking/login_page/auth_page.dart';
import 'package:vit_bus_tracking/login_page/login_bloc.dart';
import 'package:vit_bus_tracking/show_drives/show_drivers_bloc.dart';
import 'package:vit_bus_tracking/show_drives/show_routes_bloc.dart';
import 'package:vit_bus_tracking/show_routes/show_all_routes_bloc.dart';
import 'package:vit_bus_tracking/utils/notification_util.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> backgroundMessageHandeler(RemoteMessage remoteMessage) async {
  log("background helper");
  final title = remoteMessage.notification!.title.toString();
  final body = remoteMessage.notification!.body.toString();
  String category = "(update)";
  if (remoteMessage.data.values.isNotEmpty) {
    category = remoteMessage.data.values.toString();
  }

  if (category == "(update)") {
    await HelperNotification.showNormalBigNotification(
      id: 0,
      title: title,
      body: body,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  } else {
    await HelperNotification.showEmergencyBigNotification(
      id: 0,
      title: title,
      body: body,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: "VIT Bus Tracking APP",
  );

  await FirebaseApi().initNotifications();

  // adding foreground and background messages with custom sound and icon
  try {
    await HelperNotification.initialize(flutterLocalNotificationsPlugin);
  } catch (e) {
    log("error in file -> main");
    log("error -> $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade500,
          background: Colors.white,
          error: Colors.red.shade300,
          onBackground: Colors.black,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 40,
            fontFamily: GoogleFonts.readexPro().fontFamily,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontSize: 23,
            fontFamily: GoogleFonts.readexPro().fontFamily,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontFamily: GoogleFonts.readexPro().fontFamily,
            color: Colors.black,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontFamily: GoogleFonts.readexPro().fontFamily,
            color: Colors.black,
          ),
          displayMedium: TextStyle(
            fontSize: 18,
            fontFamily: GoogleFonts.readexPro().fontFamily,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontFamily: GoogleFonts.readexPro().fontFamily,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontFamily: GoogleFonts.readexPro().fontFamily,
          ),
        ),
      ),
      title: 'VIT Bus Tracking',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CurrentLocationBloc()),
          BlocProvider(create: (_) => ShowDriversBloc()),
          BlocProvider(create: (_) => ShowRoutesBloc()),
          BlocProvider(create: (_) => CurrentLocationBloc()),
          BlocProvider(create: (_) => DriverRoutesBloc()),
          BlocProvider(create: (_) => DeleteRoutesBloc()),
          BlocProvider(create: (_) => PlannedRoutesBloc()),
          BlocProvider(create: (_) => LoginBloc()),
        ],
        child: const AuthPage(),
      ),
    );
  }
}
