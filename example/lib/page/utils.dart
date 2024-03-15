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

/// Parse a string to a list of integers
String? validateUnsafeListInt(String value, {String delimeter = ","}) {
  try {
    parseForUnsafeListInt(value, delimeter: delimeter);
    return null;
  } catch (e) {
    return "Invalid list";
  }
}
