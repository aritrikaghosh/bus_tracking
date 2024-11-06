import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:vit_bus_tracking/keys/keys.dart';
import 'package:vit_bus_tracking/login_page/login_page.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();

    MapmyIndiaAccountManager.setMapSDKKey(Keys().mapSdkKey);
    MapmyIndiaAccountManager.setRestAPIKey(Keys().mapRestApiKey);
    MapmyIndiaAccountManager.setAtlasClientId(Keys().clientId);
    MapmyIndiaAccountManager.setAtlasClientSecret(Keys().clientSecret);

    MapplsAccountManager.setMapSDKKey(Keys().mapSdkKey);
    MapplsAccountManager.setRestAPIKey(Keys().mapRestApiKey);
    MapplsAccountManager.setAtlasClientId(Keys().clientId);
    MapplsAccountManager.setAtlasClientSecret(Keys().clientSecret);
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return const SplashPage();
    } else {
      return const LoginPage();
    }
  }
}
