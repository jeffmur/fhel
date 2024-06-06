import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_calculator/addition.dart';
import 'package:fhel_calculator/multiplication.dart';
import 'package:fhel_calculator/subtraction.dart';
import 'package:fhel_calculator/page/user_input.dart';
import 'package:fhel_calculator/page/utils.dart';
import 'package:fhel_calculator/page/log.dart';
import 'package:fhel_calculator/page/settings.dart';

Form listIntAdd(BuildContext context, TextEditingController xP, TextEditingController yP,
  GlobalKey<FormFieldState> xEncrypted, GlobalKey<FormFieldState> yEncrypted) {
  final session = Provider.of<SessionChanges>(context);
  final formKey = GlobalKey<FormState>();

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
                      final x = parseForUnsafeListInt(xP.value.text);
                      final y = parseForUnsafeListInt(yP.value.text);
                      List<int> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] + y[i]);
                      }
                      final actual = addVectorInt(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      statusBanner(context, session, actual == expected.join(','), 
                        'Correct: $actualList',
                        isException(actual) 
                          ? actual 
                          : 'Failed: $actual != $expected');
                    }
                  },
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListInt(xP.value.text);
                      final y = parseForUnsafeListInt(yP.value.text);
                      List<int> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] * y[i]);
                      }
                      final actual = multiplyVecInt(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      statusBanner(context, session, actual == expected.join(','), 
                        'Correct: $actualList',
                        isException(actual) 
                          ? actual 
                          : 'Failed: $actual != $expected');
                    }
                  },
                  child: const Text('x'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListInt(xP.value.text);
                      final y = parseForUnsafeListInt(yP.value.text);
                      List<int> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] - y[i]);
                      }
                      final actual = subtractVecInt(session, x, y,
                        xEncrypted.currentState!.value,
                        yEncrypted.currentState!.value);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      statusBanner(context, session, actual == expected.join(','), 
                        'Correct: $actualList',
                        isException(actual) 
                          ? actual 
                          : 'Failed: $actual != $expected');
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
