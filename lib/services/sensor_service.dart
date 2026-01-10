import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class SensorService {
  late Stream<AccelerometerEvent> _accelerometerEvents;
  int _stepCount = 0;
  double _lastMagnitude = 0;
  final double _stepThreshold = 15.0;
  final List<double> _magnitudes = [];

  SensorService() {
    _accelerometerEvents = accelerometerEvents;
  }

  Stream<AccelerometerEvent> getAccelerometerStream() {
    return _accelerometerEvents;
  }

  int detectSteps(AccelerometerEvent event) {
    double x = event.x;
    double y = event.y;
    double z = event.z;

    double magnitude = sqrt(x * x + y * y + z * z);
    _magnitudes.add(magnitude);

    if (_magnitudes.length > 10) {
      _magnitudes.removeAt(0);
    }

    if (_magnitudes.length >= 10) {
      double average = _magnitudes.reduce((a, b) => a + b) / _magnitudes.length;
      if (magnitude > average + _stepThreshold && _lastMagnitude < average) {
        _stepCount++;
      }
    }

    _lastMagnitude = magnitude;
    return _stepCount;
  }

  void resetStepCount() {
    _stepCount = 0;
  }

  void setStepCount(int count) {
    _stepCount = count;
  }

  int getStepCount() {
    return _stepCount;
  }

  double calculateCalories(int steps) {
    // Średnia wartość: 0.05 kcal na krok
    return steps * 0.05;
  }

  double calculateIntensity(double magnitude) {
    // Normalizacja intensywności (0-1)
    return (magnitude.clamp(5, 25) - 5) / 20;
  }
}
