import 'dart:math';
import 'package:geoflutterfire/src/point.dart';

//haversine distance fn source: geofireflutter package

const double MAX_SUPPORTED_RADIUS = 8587;

// Length of a degree latitude at the equator
const double METERS_PER_DEGREE_LATITUDE = 110574;

// The equatorial circumference of the earth in meters
const double EARTH_MERIDIONAL_CIRCUMFERENCE = 40007860;

// The equatorial radius of the earth in meters
const double EARTH_EQ_RADIUS = 6378137;

// The meridional radius of the earth in meters
const double EARTH_POLAR_RADIUS = 6357852.3;

/* The following value assumes a polar radius of
     * r_p = 6356752.3
     * and an equatorial radius of
     * r_e = 6378137
     * The value is calculated as e2 == (r_e^2 - r_p^2)/(r_e^2)
     * Use exact value to avoid rounding errors
     */
const double EARTH_E2 = 0.00669447819799;

// Cutoff for floating point calculations
const double EPSILON = 1e-12;

double distance(Coordinates location1, Coordinates location2) {
return calcDistance(location1.latitude, location1.longitude,
location2.latitude, location2.longitude);
}

double calcDistance(
double lat1, double long1, double lat2, double long2) {
// Earth's mean radius in meters
final double radius = (EARTH_EQ_RADIUS + EARTH_POLAR_RADIUS) / 2;
double latDelta = _toRadians(lat1 - lat2);
double lonDelta = _toRadians(long1 - long2);

double a = (sin(latDelta / 2) * sin(latDelta / 2)) +
(cos(_toRadians(lat1)) *
cos(_toRadians(lat2)) *
sin(lonDelta / 2) *
sin(lonDelta / 2));
double distance = radius * 2 * atan2(sqrt(a), sqrt(1 - a)) / 1000;
return double.parse(distance.toStringAsFixed(3));
}

double _toRadians(double num) {
return num * (pi / 180.0);
}
//zip fn source: quiver package
Iterable zip(Iterable<Iterable> iterables) {
  var minLength = iterables.map((a) => a.length).reduce((a, b) => a < b ? a : b);
  return new Iterable.generate(minLength, (i) => iterables.map((it) => it.elementAt(i)));
}