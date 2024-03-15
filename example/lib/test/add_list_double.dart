import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/page/user_input.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/page/log.dart';
import 'package:fhel_example/page/settings.dart';

Form listDoubleAdd(BuildContext context) {
  final session = Provider.of<SessionChanges>(context);
  final xP = GlobalKey<FormFieldState>();
  final yP = GlobalKey<FormFieldState>();
  final _formKey = GlobalKey<FormState>();

  return Form(key: _formKey,
    child: SingleChildScrollView(child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Encrypt and Add List of Doubles'),
        ),
        PromptList('x', xP),
        PromptList('y', yP),
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.currentState!.value);
                      final y = parseForUnsafeListDouble(yP.currentState!.value);
                      List<double> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] + y[i]);
                      }
                      final actual = addVectorDouble(session, x, y, addPlain: true);
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: actual == expected.join(',')
                              ? Text('Correct: $actualList')
                              : Text(actual),
                        ),
                      );
                    }
                  },
                  child: const Text('Cipher(x) + Cipher(y)'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      session.clearLogs();
                      final x = parseForUnsafeListDouble(xP.currentState!.value);
                      final y = parseForUnsafeListDouble(yP.currentState!.value);
                      List<double> expected = [];
                      for (int i = 0; i < x.length; i++) {
                        expected.add(x[i] + y[i]);
                      }
                      final actual = addVectorDouble(session, x, y, addPlain: true);
                      List<double> actualList = parseForUnsafeListDouble(actual);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: actual == expected.join(',')
                              ? Text('Correct: $actualList')
                              : Text(actual),
                        ),
                      );
                    }
                  },
                  child: const Text('Cipher(x) + Plain(y)'),
                ),
              ],
            ),
          )
        ],
      ),
      const Text('Logs'),
      const LogScreen(),
    ],
  )));
}
