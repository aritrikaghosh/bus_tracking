import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vit_bus_tracking/login_page/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_bus_tracking/login_page/signup_page.dart';
import 'package:vit_bus_tracking/login_page/splash_page.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

enum AccessLevel { student, coordinator, driver, error }

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AccessLevel accessLevel = AccessLevel.error;

  Future<void> uploadStudentData({
    required String studentName,
    required String studentId,
    required String studentEmail,
    required String parentPhone,
    required String studentPhone,
    required String routeTravelled,
    required String uid,
  }) async {
    log("name -> $studentName");
    log("email -> $studentEmail");
    log("id -> $studentId");
    log("parent phone -> $parentPhone");
    log("student phone -> $studentPhone");
    log("route travelled -> $routeTravelled");
    log("uid -> $uid");

    await _db
        .collection("users")
        .doc("students")
        .collection("users")
        .doc(uid)
        .set(
      {
        "access_level": AccessLevel.student.toString(),
        "email": studentEmail,
        "name": studentName,
        "studentPhone": studentPhone,
        "parentPhone": parentPhone,
        "studentId": studentId,
        "routeTravelled": routeTravelled,
        "uid": uid,
      },
    );

    await setAccessLevelInPref(AccessLevel.student);
  }

  Future<AccessLevel> getAccessLevelFromPrefs() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // now get the string
    final accessLevelFromPref = sp.getString("access_level");
    if (accessLevelFromPref == "coordinator") {
      accessLevel = AccessLevel.coordinator;
    } else if (accessLevelFromPref == "student") {
      accessLevel = AccessLevel.student;
    } else if (accessLevelFromPref == "driver") {
      accessLevel = AccessLevel.driver;
    } else {
      accessLevel = AccessLevel.error;
    }
    return accessLevel;
  }

  Future<bool> sentOTPPhoneSignIn({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException error) {
          log("error has occured ${error.message}");
          log(phoneNumber);
          throw Exception(error.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(minutes: 1),
      );
      return true;
    } catch (e) {
      log("error in signin with phone");
      return false;
    }
  }

  Future<void> upgradeAccessLevel(User user) async {
    final doc = await _db.collection("bus_driver").doc("drivers").get();
    Map<String, dynamic> routeMapping =
        doc.data()!["route_mapping"] ?? {} as Map<String, dynamic>;

    Iterable<MapEntry<String, dynamic>> entries = routeMapping.entries;

    for (final entry in entries) {
      final key = entry.key;
      final driverDoc = await _db.collection("bus_driver").doc(key).get();
      dynamic data = driverDoc.data() ?? {};
      String phoneNumber =
          data == null ? "-1" : data["Driver Mobile Number"] ?? "-1";
      if (phoneNumber != "-1" && phoneNumber == user.phoneNumber) {
        await setAccessLevelInPref(AccessLevel.driver);
      }
    }
  }

  Future<AccessLevel> verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      UserCredential user = await _auth.signInWithCredential(credential);
      log("signed in with credential");
      accessLevel = await getAccessLevelFromFirebase(user.user!);
      log("calling update access level");
      await upgradeAccessLevel(user.user!);
      return accessLevel;
    } catch (e) {
      log("error occured -> $e");
      accessLevel = AccessLevel.error;
      return accessLevel;
    }
  }

  Future<void> handelGoogleSignIn({required context}) async {
    try {
      log("signing in thru google sign in");
      log("awaiting sign in");
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        log("getting user credential");
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        log("found user credential");
        if (userCredential.additionalUserInfo!.isNewUser) {
          log("new user found");
          // push to sign up page
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignUpPage(
                email: googleUser.email,
                uid: userCredential.user!.uid,
              ),
            ),
          );
        } else {
          log("exisiting user found");
          log("getting access level");
          accessLevel = await getAccessLevelFromFirebase(userCredential.user!);
          log("found access level $accessLevel");
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SplashPage(),
            ),
          );
        }
      }
    } catch (e) {
      log("Error Sign in with google $e");
      accessLevel = AccessLevel.error;
      ShowSnackBar().showSnackBar(
        message: "Error in sign in try again",
        context: context,
      );
    }
  }

  Future<void> handelSignOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.clear();
    } catch (e) {
      log("issue in log out with google $e");
    }
  }

  Future<AccessLevel> getAccessLevelFromFirebase(User user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    log("in access level");
    log(user.uid);

    AccessLevel? level = await _db
        .collection("users")
        .doc("coordinators")
        .collection("users")
        .doc(user.uid)
        .get()
        .then(
      (value) async {
        if (value.exists) {
          log("got coordinator");
          await sp.setString("access_level", "coordinator");
          log("set the access level as coordinator");
          accessLevel = AccessLevel.coordinator;
          return accessLevel;
        }
        return null;
      },
    );

    if (level != null) return accessLevel;

    level = await _db
        .collection("users")
        .doc("drivers")
        .collection("users")
        .doc(user.uid)
        .get()
        .then(
      (value) async {
        if (value.exists) {
          log("got driver access level");
          await sp.setString("access_level", "driver");
          log("set the access level to driver");
          accessLevel = AccessLevel.driver;
          return accessLevel;
        }
        return null;
      },
    );
    if (level != null) return accessLevel;

    level = await _db
        .collection("users")
        .doc("students")
        .collection("users")
        .doc(user.uid)
        .get()
        .then(
      (value) async {
        if (value.exists) {
          log("got the student access level");
          await sp.setString("access_level", "student");
          log("set the access level to student");
          accessLevel = AccessLevel.student;
          return accessLevel;
        }
        return null;
      },
    );
    if (level != null) return accessLevel;

    log("no access level found");

    // TODO: Change this during signup page

    await _db
        .collection("users")
        .doc("students")
        .collection("users")
        .doc(user.uid)
        .set(
      {
        "uid": user.uid,
        "name": user.displayName,
        "email": user.email,
        "phone": user.phoneNumber,
        "access_level": AccessLevel.student.toString(),
      },
    );

    await sp.setString("access_level", "student");
    log("set the acess level to student");
    accessLevel = AccessLevel.student;
    return accessLevel;
  }

  Future<void> setAccessLevelInPref(AccessLevel accessLevel) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    log("Setting access level $accessLevel");
    await sp.setString(
      "access_level",
      accessLevel.toString().split(".")[1],
    );
    log("Access level set");
  }

  Future<String?> getValueFromPref(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? data = sp.getString(key);
    return data;
  }

  Future<void> detailsPresent() async {
    accessLevel = await getAccessLevelFromPrefs();
    if (accessLevel == AccessLevel.student) {
      if (await getValueFromPref("name") == null ||
          await getValueFromPref("email") == null ||
          await getValueFromPref("studentId") == null) {
        log("details not found in shared pref getting it again");
        await getDetails();
      }
    } else if (accessLevel == AccessLevel.coordinator) {
      if (await getValueFromPref("name") == null ||
          await getValueFromPref("email") == null ||
          await getValueFromPref("empID") == null) {
        log("details not found in shared pref getting it again");
        await getDetails();
      }
    } else if (accessLevel == AccessLevel.driver) {
      if (await getValueFromPref("name") == null ||
          await getValueFromPref("email") == null ||
          await getValueFromPref("empID") == null) {
        log("details not found in shared pref getting it again");
        await getDetails();
      }
    } else {
      await getDetails();
    }
  }

  Future<void> getDetails() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    accessLevel = await getAccessLevelFromPrefs();

    // we already have the access level
    if (accessLevel == AccessLevel.student) {
      // get the document from the firebase
      final docRef = await _db
          .collection("users")
          .doc("students")
          .collection("users")
          .doc(uid)
          .get();

      final data = docRef.data() as Map<String, dynamic>;

      final studentName = data["name"];
      final studentEmail = data["email"];
      final studentId = data["studentId"];
      final routeTravelled = data["routeTravelled"];

      await setValues("name", studentName);
      await setValues("email", studentEmail);
      await setValues("uid", uid);
      await setValues("studentId", studentId);
      await setValues("routeTravelled", routeTravelled);
    } else if (accessLevel == AccessLevel.coordinator) {
      final docRef = await _db
          .collection("users")
          .doc("coordinators")
          .collection("users")
          .doc(uid)
          .get();

      final data = docRef.data() as Map<String, dynamic>;

      final coordinatorName = data["coordinatorName"];
      final coordinatorEmail = data["email"];
      final empId = data["empID"];

      await setValues("name", coordinatorName);
      await setValues("email", coordinatorEmail);
      await setValues("uid", uid);
      await setValues("empID", empId);
    } else if (accessLevel == AccessLevel.driver) {
      final docRef = await _db
          .collection("users")
          .doc("drivers")
          .collection("users")
          .doc(uid)
          .get();

      final data = docRef.data() ?? {} as Map<String, dynamic>;

      final driverName = data["driverName"];
      final driverEmail = data["email"] ?? "";
      final empId = data["empID"];

      await setValues("name", driverName);
      await setValues("email", driverEmail);
      await setValues("uid", uid);
      await setValues("empID", empId);
    }
  }

  Future<void> setValues(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    log("setting key -> $key value -> $value");
    await sp.setString(
      key,
      value,
    );
    log("key -> $key value -> $value set");
  }
}
