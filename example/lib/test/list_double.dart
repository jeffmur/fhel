import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_calculator/globals.dart';
import 'package:fhel_calculator/addition.dart';
import 'package:fhel_calculator/subtraction.dart';
import 'package:fhel_calculator/multiplication.dart';
import 'package:fhel_calculator/page/user_input.dart';
import 'package:fhel_calculator/page/utils.dart';
import 'package:fhel_calculator/page/log.dart';
import 'package:fhel_calculator/page/settings.dart';

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

Form listDoubleAdd(BuildContext context, TextEditingController xP, TextEditingController yP,
  GlobalKey<FormFieldState> xEncrypted, GlobalKey<FormFieldState> yEncrypted) {
  final session = Provider.of<SessionChanges>(context);
  final formKey = GlobalKey<FormState>();

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
                      final x = parseForUnsafeListDouble(xP.value.text);
                      final y = parseForUnsafeListDouble(yP.value.text);
                      List<double> expected = [];
                      int prec = precision(x, y);
                      for (int i = 0; i < x.length; i++) {
                        expected.add(double.parse((x[i] + y[i])
                          .toStringAsFixed(prec)));
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
                      statusBanner(context, session, actualList.join(',') == expected.join(','), 
                        'Correct: $expected', 'Failed: $actualList != $expected');
                    }
                  },
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.value.text);
                      final y = parseForUnsafeListDouble(yP.value.text);
                      List<double> expected = [];
                      int prec = precision(x, y);
                      for (int i = 0; i < x.length; i++) {
                        expected.add(double.parse((x[i] * y[i])
                          .toStringAsFixed(prec)));
                      }
                      final actual = multiplyVecDouble(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      session.log("Precision: $prec");
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      // round all elements to the largest precision
                      for (int i = 0; i < actualList.length; i++) {
                        actualList[i] = double.parse(actualList[i].toStringAsFixed(prec));
                      }
                      statusBanner(context, session, actualList.join(',') == expected.join(','), 
                        'Correct: $expected', 'Failed: $actualList != $expected');
                    }
                  },
                  child: const Text('x'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.value.text);
                      final y = parseForUnsafeListDouble(yP.value.text);
                      List<double> expected = [];
                      int prec = precision(x, y);
                      for (int i = 0; i < x.length; i++) {
                        expected.add(double.parse((x[i] - y[i])
                          .toStringAsFixed(prec)));
                      }
                      final actual = subtractVecDouble(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      session.log("Precision: $prec");
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      // round all elements to the largest precision
                      for (int i = 0; i < actualList.length; i++) {
                        actualList[i] = double.parse(actualList[i].toStringAsFixed(prec));
                      }
                      statusBanner(context, session, actualList.join(',') == expected.join(','), 
                        'Correct: $expected', 'Failed: $actualList != $expected');
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
