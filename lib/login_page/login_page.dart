import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/phone_login_page.dart';
import 'package:wakelock/wakelock.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    authService = AuthService();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // login text
              Text(
                "Login",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 25),

              // logo of vit
              Image.asset(
                "assets/logo.png",
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 25),

              // a button for google sign in
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await authService.handelGoogleSignIn(context: context);
                  } catch (e) {
                    log("error occured in sign in $e");
                    showSnackBar("Error in sign in");
                  }
                },
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Theme.of(context).colorScheme.background,
                ),
                label: Text(
                  "Sign in with Google",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.background,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PhoneLoginPage(),
                    ),
                  );
                },
                icon: FaIcon(
                  FontAwesomeIcons.phone,
                  color: Theme.of(context).colorScheme.background,
                ),
                label: Text(
                  "Login with phone number",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.background,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // now for go back button
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  SystemNavigator.pop();
                },
                child: Text(
                  "Go Back",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).colorScheme.primary,
                        decorationThickness: 2,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
