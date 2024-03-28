import 'package:fhel_calculator/subtraction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_calculator/globals.dart';
import 'package:fhel_calculator/addition.dart';
import 'package:fhel_calculator/multiplication.dart';
import 'package:fhel_calculator/page/user_input.dart';
import 'package:fhel_calculator/page/utils.dart';
import 'package:fhel_calculator/page/log.dart';
import 'package:fhel_calculator/page/settings.dart';

Form hexOp(BuildContext context) {
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
          PromptNumber.hex('X', xP, xEncrypted),
          PromptNumber.hex('Y', yP, yEncrypted),
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
                          final x = parseForUnsafeInt(xP.currentState!.value);
                          final y = parseForUnsafeInt(yP.currentState!.value);
                          final expected = x + y;
                          final actual = addAsHex(session, x, y,
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          statusBanner(context, session, actual == expected.toString(), 
                            'Correct: $expected', 'Failed: $actual != $expected');
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
                          final x = parseForUnsafeInt(xP.currentState!.value);
                          final y = parseForUnsafeInt(yP.currentState!.value);
                          final expected = x * y;
                          final actual = multiplyAsHex(session, x, y, 
                            xEncrypted.currentState!.value,
                            yEncrypted.currentState!.value);
                          statusBanner(context, session, actual == expected.toString(), 
                            'Correct: $expected', 'Failed: $actual != $expected');
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
                          final x = parseForUnsafeInt(xP.currentState!.value);
                          final y = parseForUnsafeInt(yP.currentState!.value);
                          final expected = x - y;
                          final actual = subtractAsHex(session, x, y,
                            xEncrypted.currentState!.value,
                            yEncrypted.currentState!.value);
                          statusBanner(context, session, actual == expected.toString(), 
                            'Correct: $expected', 'Failed: $actual != $expected');
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
