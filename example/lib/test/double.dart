import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_calculator/globals.dart';
import 'package:fhel_calculator/addition.dart';
import 'package:fhel_calculator/multiplication.dart';
import 'package:fhel_calculator/subtraction.dart';
import 'package:fhel_calculator/page/user_input.dart';
import 'package:fhel_calculator/page/utils.dart';
import 'package:fhel_calculator/page/log.dart';
import 'package:fhel_calculator/page/settings.dart';

Form doubleOp(BuildContext context, TextEditingController xP, TextEditingController yP,
  GlobalKey<FormFieldState> xEncrypted, GlobalKey<FormFieldState> yEncrypted) {
  final session = Provider.of<SessionChanges>(context);
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
                          final x = parseForUnsafeDouble(xP.value.text);
                          final y = parseForUnsafeDouble(yP.value.text);
                          final actual = addDouble(session, x, y,
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          // Calculate the expected result with the highest precision
                          final xPrecise = x.toString().split('.').last.length;
                          final yPrecise = y.toString().split('.').last.length;
                          final precision = xPrecise > yPrecise ? xPrecise : yPrecise;
                          final expected = (x + y).toStringAsFixed(precision);
                          final roundActual = double.parse(actual).toStringAsFixed(precision);
                          statusBanner(context, session, roundActual == expected, 
                            'Correct: $expected', 'Failed: $roundActual != $expected');
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
                          final x = parseForUnsafeDouble(xP.value.text);
                          final y = parseForUnsafeDouble(yP.value.text);
                          final actual = multiplyDouble(session, x, y, 
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          // Calculate the expected result with the highest precision
                          final xPrecise = x.toString().split('.').last.length;
                          final yPrecise = y.toString().split('.').last.length;
                          final precision = xPrecise > yPrecise ? xPrecise : yPrecise;
                          final expected = (x * y).toStringAsFixed(precision);
                          final roundActual = double.parse(actual).toStringAsFixed(precision);
                          statusBanner(context, session, roundActual == expected, 
                            'Correct: $expected', 'Failed: $roundActual != $expected');
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
                          final x = parseForUnsafeDouble(xP.value.text);
                          final y = parseForUnsafeDouble(yP.value.text);
                          final actual = subtractDouble(session, x, y, 
                            xEncrypted.currentState!.value, 
                            yEncrypted.currentState!.value);
                          // Calculate the expected result with the highest precision
                          final xPrecise = x.toString().split('.').last.length;
                          final yPrecise = y.toString().split('.').last.length;
                          final precision = xPrecise > yPrecise ? xPrecise : yPrecise;
                          final expected = (x - y).toStringAsFixed(precision);
                          final roundActual = double.parse(actual).toStringAsFixed(precision);
                          statusBanner(context, session, roundActual == expected, 
                            'Correct: $expected', 'Failed: $roundActual != $expected');
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
