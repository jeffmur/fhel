import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/subtraction.dart';
import 'package:fhel_example/multiplication.dart';
import 'package:fhel_example/page/user_input.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/page/log.dart';
import 'package:fhel_example/page/settings.dart';

int precision(List<double> x, List<double> y) {
  int precision = 0;
  for (int i = 0; i < x.length; i++) {
    // Find the largestPrecision
    var xP = x[i].toString().split('.').last.length;
    var yP = y[i].toString().split('.').last.length;
    if (xP > precision) {
      precision = xP;
    }
    if (yP > precision) {
      precision = yP;
    }
  }
  return precision;
}

Form listDoubleAdd(BuildContext context) {
  final session = Provider.of<SessionChanges>(context);
  final xP = GlobalKey<FormFieldState>();
  final yP = GlobalKey<FormFieldState>();
  final formKey = GlobalKey<FormState>();
  final xEncrypted = GlobalKey<FormFieldState>();
  final yEncrypted = GlobalKey<FormFieldState>();

  return Form(key: formKey,
    child: SingleChildScrollView(child: Column(
      children: [
        PromptList.double('x', xP, xEncrypted),
        PromptList.double('y', yP, yEncrypted),
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.currentState!.value);
                      final y = parseForUnsafeListDouble(yP.currentState!.value);
                      List<double> expected = [];
                      int prec = precision(x, y);
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] + y[i]);
                      }
                      final actual = addVectorDouble(session, x, y,
                        xEncrypted.currentState!.value, 
                        yEncrypted.currentState!.value);
                      session.log("Precision: $prec");
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      // round all elements to the largest precision
                      for (int i = 0; i < actualList.length; i++) {
                        actualList[i] = double.parse(actualList[i].toStringAsFixed(prec));
                      }
                      
                      if (actualList.join(',') != expected.join(',')) {
                        session.log('Failed: $actualList != $expected');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: actualList.join(',') == expected.join(',')
                              ? Text('Correct: $actualList')
                              : Text(actual),
                        ),
                      );
                    }
                  },
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.currentState!.value);
                      final y = parseForUnsafeListDouble(yP.currentState!.value);
                      List<double> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] * y[i]);
                      }
                      int prec = precision(x, y);
                      final actual = multiplyVecDouble(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      session.log("Precision: $prec");
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      // round all elements to the largest precision
                      for (int i = 0; i < actualList.length; i++) {
                        actualList[i] = double.parse(actualList[i].toStringAsFixed(prec));
                      }
                      if (actualList.join(',') != expected.join(',')) {
                        session.log('Failed: $actualList != $expected');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: actualList.join(',') == expected.join(',')
                              ? Text('Correct: $actualList')
                              : Text(actual),
                        ),
                      );
                    }
                  },
                  child: const Text('x'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.currentState!.value);
                      final y = parseForUnsafeListDouble(yP.currentState!.value);
                      List<double> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] - y[i]);
                      }
                      int prec = precision(x, y);
                      final actual = subtractVecDouble(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      session.log("Precision: $prec");
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      // round all elements to the largest precision
                      for (int i = 0; i < actualList.length; i++) {
                        actualList[i] = double.parse(actualList[i].toStringAsFixed(prec));
                      }
                      if (actualList.join(',') != expected.join(',')) {
                        session.log('Failed: $actualList != $expected');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: actualList.join(',') == expected.join(',')
                              ? Text('Correct: $actualList')
                              : Text(actual),
                        ),
                      );
                    }
                  },
                  child: const Text('-'),
                ),
              ],
            ),
          ),
        ],
      ),
      const Text('Logs'),
      const LogScreen(),
    ],
  )));
}
