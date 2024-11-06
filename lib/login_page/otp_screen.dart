import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vit_bus_tracking/login_page/auth_service.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';
import 'package:pinput/pinput.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.verificationId,
  });

  final String verificationId;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? otpCode;

  bool isLoading = false;

  Future<void> verifyCode(BuildContext context, String userOTP) async {
    setState(() {
      isLoading = true;
    });
    AccessLevel accessLevel = await AuthService().verifyOTP(
      context: context,
      verificationId: widget.verificationId,
      userOTP: userOTP,
    );
    log("access level found in verify code");
    if (accessLevel != AccessLevel.error) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SplashPage(),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ShowSnackBar().showSnackBar(
        message: "Wrong OTP",
        context: context,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 35),
                    child: Column(
                      children: [
                        // image
                        Container(
                          height: 200,
                          width: 200,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple.shade50,
                          ),
                          child: Image.asset("assets/image2.png"),
                        ),
                        const SizedBox(height: 20),

                        // register
                        Text(
                          "Verification",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        // text after register
                        const SizedBox(height: 10),
                        Text(
                          "Enter the OTP sent to your phone",
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.6),
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        // pin input space
                        const SizedBox(height: 10),
                        Pinput(
                          length: 6,
                          showCursor: true,
                          defaultPinTheme: PinTheme(
                            height: MediaQuery.of(context).size.width * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                          onChanged: (value) {
                            otpCode = value;
                          },
                        ),

                        // submit code
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            log("this is the otp code -> $otpCode");
                            if (otpCode != null && otpCode!.isNotEmpty) {
                              await verifyCode(context, otpCode!);
                              log("code verified");
                            } else {
                              ShowSnackBar().showSnackBar(
                                message: "Enter 6 Digit OTP code",
                                context: context,
                              );
                            }
                          },
                          icon: Icon(
                            Icons.verified_sharp,
                            color: Theme.of(context).colorScheme.background,
                          ),
                          label: Text(
                            "Verify",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          "Didn't recive any code?",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.6),
                                  ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Resend New Code",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Theme.of(context).colorScheme.primary,
                                  decorationThickness: 2,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
