import 'package:fhel_calculator/page/log.dart';
import 'package:flutter/material.dart';
import 'package:fhel_calculator/globals.dart';
import 'package:fhel_calculator/page/settings.dart';

/// Display a status banner
/// 
/// If the operation is correct, display the actual result.
/// Otherwise, display the failure message.
ScaffoldFeatureController statusBanner(BuildContext context, SessionChanges session, bool isCorrect, String onSuccess, String onFailure) {
  // Log the last exception once
  if (!isCorrect && !isException(session.logs.last)) {
    session.log(onFailure);
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: isCorrect
        ? Text(onSuccess)
        : Text(onFailure),
      backgroundColor: isCorrect
        ? successColor
        : errorColor,
    )
  );
}

/// Parse a string to an integer
int parseForUnsafeInt(String value) {
  try {
    return int.parse(value);
  } catch (e) {
    return 0;
  }
}

/// Parse a string to an integer
String? validateUnsafeInt(String value) {
  try {
    int.parse(value);
  } catch (e) {
    return 'Invalid integer';
  }
  return null;
}

/// Parse a string to a double
double parseForUnsafeDouble(String value) {
  try {
    return double.parse(value);
  } catch (e) {
    return 0;
  }
}

/// Parse a string to a double
String? validateUnsafeDouble(String value) {
  try {
    double.parse(value);
  } catch (e) {
    return 'Invalid double';
  }
  return null;
}

List<int> parseForUnsafeListInt(String value, {String delimeter = ","}) {
  try {
    return value.split(delimeter).map((e) => int.parse(e)).toList();
  } catch (e) {
    return [];
  }
}

/// Parse a string to a list of integers
String? validateUnsafeListInt(String value, {String delimeter = ","}) {
  try {
    value.split(delimeter).map((e) => double.parse(e)).toList();
    return null;
  } catch (e) {
    return "Invalid list";
  }
}

List<double> parseForUnsafeListDouble(String value, {String delimeter = ","}) {
  try {
    return value.split(delimeter).map((e) => double.parse(e)).toList();
  } catch (e) {
    return [];
  }
}

String? validateUnsafeListDouble(String value, {String delimeter = ","}) {
  try {
    parseForUnsafeListDouble(value, delimeter: delimeter);
    return null;
  } catch (e) {
    return "Invalid list";
  }
}
