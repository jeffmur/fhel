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

/// Parse a string to a list of integers
String? validateUnsafeListInt(String value, {String delimeter = ","}) {
  try {
    value.split(delimeter).map((e) => int.parse(e)).toList();
    return "Invalid list";
  } catch (e) {
    return null;
  }
}

