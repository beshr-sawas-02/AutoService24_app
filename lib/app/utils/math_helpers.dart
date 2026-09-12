import 'dart:math' as math;

class MathHelpers {
  static double sin(double value) => math.sin(value);
  static double cos(double value) => math.cos(value);
  static double sqrt(double value) => math.sqrt(value);
  static double atan2(double y, double x) => math.atan2(y, x);
  static const double pi = math.pi;

  // Convert degrees to radians
  static double toRadians(double degree) {
    return degree * (pi / 180);
  }

  // Convert radians to degrees
  static double toDegrees(double radian) {
    return radian * (180 / pi);
  }
}