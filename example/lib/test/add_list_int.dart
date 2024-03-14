import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/page/user_input.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/page/log.dart';
import 'package:fhel_example/page/settings.dart';

SingleChildScrollView listIntAdd(BuildContext context) {
  final session = Provider.of<SessionChanges>(context);
  final xP = GlobalKey<FormFieldState>();
  final yP = GlobalKey<FormFieldState>();

  return SingleChildScrollView(
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Encrypt and Add List of Integers'),
        ),
        PromptNumber('x', xP),
        PromptNumber('y', yP),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      session.clearLogs();
                      final x = parseForUnsafeListInt(xP.currentState?.value);
                      final y = parseForUnsafeListInt(yP.currentState?.value);
                      final expected = x + y;
                      final actual = addVector(session, x, y);
                      List<int> actualList = parseForUnsafeListInt(actual);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: actualList == expected
                              ? Text('Correct: $actual')
                              : Text(actual),
                        ),
                      );
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
                      session.clearLogs();
                      final x = parseForUnsafeInt(xP.currentState?.value);
                      final y = parseForUnsafeInt(yP.currentState?.value);
                      final expected = x + y;
                      final actual = addAsHex(session, x, y, addPlain: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: int.tryParse(actual) == expected
                              ? Text('Correct: $actual')
                              : Text(actual),
                        ),
                      );
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
  );
}
