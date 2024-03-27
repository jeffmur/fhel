import 'package:fhel_example/subtraction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/multiplication.dart';
import 'package:fhel_example/page/user_input.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/page/log.dart';
import 'package:fhel_example/page/settings.dart';

Form doubleOp(BuildContext context) {
  final session = Provider.of<SessionChanges>(context);
  final xP = GlobalKey<FormFieldState>();
  final yP = GlobalKey<FormFieldState>();
  final xEncrypted = GlobalKey<FormFieldState>();
  final yEncrypted = GlobalKey<FormFieldState>();

  final formKey = GlobalKey<FormState>();

  return Form(
    key: formKey,
    child: SingleChildScrollView(
      child: Column(
        children: [
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text('Convert to Hexadecimal and Calculate.'),
          // ),
          PromptNumber.double('X', xP, xEncrypted),
          PromptNumber.double('Y', yP, yEncrypted),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Calculate the sum of the two integers
                          session.clearLogs();
                          final x = parseForUnsafeDouble(xP.currentState!.value);
                          final y = parseForUnsafeDouble(yP.currentState!.value);
                          final expected = x + y;
                          final actual = addDouble(session, x, y,
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: actual == expected.toString()
                                  ? Text('Correct: $actual')
                                  : Text(actual),
                            ),
                          );
                        }
                      },
                      child: const Text('+'),
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
                        if (formKey.currentState!.validate()) {
                          // Calculate the sum of the two integers
                          session.clearLogs();
                          final x = parseForUnsafeDouble(xP.currentState!.value);
                          final y = parseForUnsafeDouble(yP.currentState!.value);
                          final expected = x * y;
                          final actual = multiplyDouble(session, x, y, 
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: actual == expected.toString()
                                  ? Text('Correct: $actual')
                                  : Text(actual),
                            ),
                          );
                        }
                      },
                      child: const Text('x'),
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
                        if (formKey.currentState!.validate()) {
                          // Calculate the sum of the two integers
                          session.clearLogs();
                          final x = parseForUnsafeDouble(xP.currentState!.value);
                          final y = parseForUnsafeDouble(yP.currentState!.value);
                          final expected = x - y;
                          final actual = subtractDouble(session, x, y, 
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: actual == expected.toString()
                                  ? Text('Correct: $actual')
                                  : Text(actual),
                            ),
                          );
                        }
                      },
                      child: const Text('-', style: TextStyle(fontSize: 20)),
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
