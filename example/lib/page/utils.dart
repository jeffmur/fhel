/// Parse a string to an integer
String? validateUnsafeInt(String value) {
  try {
    int.parse(value);
  } catch (e) {
    return 'Invalid number';
  }
  return null;
}

/// Parse a string to an integer
int parseForUnsafeInt(String value) {
  try {
    return int.parse(value);
  } catch (e) {
    return 0;
  }
}

List<int> parseForUnsafeListInt(String value, {String delimeter = ","}) {
  try {
    return value.split(delimeter).map((e) => int.parse(e)).toList();
  } catch (e) {
    return [];
  }
}

String? validateUnsafeListInt(String value, {String delimeter = ","}) {
  try {
    parseForUnsafeListInt(value, delimeter: delimeter);
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
