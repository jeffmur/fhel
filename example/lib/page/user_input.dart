import 'package:fhel_example/page/utils.dart';
import 'package:flutter/material.dart';
import 'package:fhel_example/globals.dart';

// Create a Form widget.
class PromptNumber extends StatefulWidget {
  String label = 'not set';
  var ref = GlobalKey<FormFieldState>();

  PromptNumber(this.label, this.ref, {super.key});

  @override
  PromptNumberRow createState() {
    // ignore: no_logic_in_create_state
    return PromptNumberRow(ref, label);
  }

  int? get value => parseForUnsafeInt(ref.currentState?.value);
}

class PromptNumberRow extends State<PromptNumber> {
  GlobalKey<FormFieldState> _key;
  String label;

  PromptNumberRow(this._key, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('$label: '),
      ),
      SizedBox(
          width: WIDTH,
          child: TextFormField(
            key: _key,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter a number',
            ),
            validator: (value) {
              return validateUnsafeInt(value!);
            },
            onChanged: (value) => setState(() {}),
          )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _key.currentState != null
              ? parseForUnsafeInt(_key.currentState?.value).toRadixString(16)
              : '',
        ),
      )
    ]);
  }
}
