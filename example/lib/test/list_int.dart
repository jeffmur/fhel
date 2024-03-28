import 'package:fhel_example/globals.dart';
import 'package:fhel_example/multiplication.dart';
import 'package:fhel_example/subtraction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/page/user_input.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/page/log.dart';
import 'package:fhel_example/page/settings.dart';

Form listIntAdd(BuildContext context) {
  final session = Provider.of<SessionChanges>(context);
  final xP = GlobalKey<FormFieldState>();
  final yP = GlobalKey<FormFieldState>();
  final formKey = GlobalKey<FormState>();
  final xEncrypted = GlobalKey<FormFieldState>();
  final yEncrypted = GlobalKey<FormFieldState>();

  return Form(key: formKey,
    child: SingleChildScrollView(child: Column(
      children: [
        PromptList('x', xP, xEncrypted),
        PromptList('y', yP, yEncrypted),
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListInt(xP.currentState!.value);
                      final y = parseForUnsafeListInt(yP.currentState!.value);
                      List<int> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] + y[i]);
                      }
                      final actual = addVectorInt(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      statusBanner(context, session, actual == expected.join(','), 
                        'Correct: $actualList', 'Failed: $actualList != $expected');
                    }
                  },
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListInt(xP.currentState!.value);
                      final y = parseForUnsafeListInt(yP.currentState!.value);
                      List<int> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] * y[i]);
                      }
                      final actual = multiplyVecInt(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      statusBanner(context, session, actual == expected.join(','), 
                        'Correct: $actualList', 'Failed: $actualList != $expected');
                    }
                  },
                  child: const Text('x'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListInt(xP.currentState!.value);
                      final y = parseForUnsafeListInt(yP.currentState!.value);
                      List<int> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] - y[i]);
                      }
                      final actual = subtractVecInt(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      statusBanner(context, session, actual == expected.join(','), 
                        'Correct: $actualList', 'Failed: $actualList != $expected');
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
