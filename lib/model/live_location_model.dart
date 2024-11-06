import 'package:mappls_gl/mappls_gl.dart';

class LiveLocationModel {
  LiveLocationModel({required this.position, required this.bearing});

  LatLng position;
  double bearing;
}
