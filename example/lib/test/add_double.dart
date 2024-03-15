import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/page/user_input.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/page/log.dart';
import 'package:fhel_example/page/settings.dart';

Form doubleAdd(BuildContext context) {
  final session = Provider.of<SessionChanges>(context);
  final xP = GlobalKey<FormFieldState>();
  final yP = GlobalKey<FormFieldState>();
  final _formKey = GlobalKey<FormState>();

  return Form(
    key: _formKey,
    child: SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Encrypt and Add two integers'),
          ),
          PromptNumber.double('x', xP),
          PromptNumber.double('y', yP),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Calculate the sum of the two integers
                          session.clearLogs();
                          final x = parseForUnsafeDouble(xP.currentState!.value);
                          final y = parseForUnsafeDouble(yP.currentState!.value);
                          final expected = x + y;
                          final actual = addDouble(session, x, y);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: actual == expected.toString()
                                  ? Text('Correct: $actual')
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
                          // Calculate the sum of the two integers
                          session.clearLogs();
                          final x = parseForUnsafeDouble(xP.currentState!.value);
                          final y = parseForUnsafeDouble(yP.currentState!.value);
                          final expected = x + y;
                          final actual = addDouble(session, x, y, addPlain: true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: actual == expected.toString()
                                  ? Text('Correct: $actual')
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
      ),
    ),
  );
}
