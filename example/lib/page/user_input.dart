import 'package:fhel_example/page/utils.dart';
import 'package:flutter/material.dart';
import 'package:fhel_example/globals.dart';

// Create a Form widget.
// ignore: must_be_immutable
class PromptNumber extends StatefulWidget {
  bool allowDouble = false;
  bool showHex = false;
  String label = 'not set';
  var ref = GlobalKey<FormFieldState>();

  PromptNumber(this.label, this.ref, {super.key});

  PromptNumber.double(this.label, this.ref, {super.key}) {
    allowDouble = true;
  }

  PromptNumber.hex(this.label, this.ref, {super.key}) {
    showHex = true;
  }

  @override
  PromptNumberRow createState() {
    // ignore: no_logic_in_create_state
    return PromptNumberRow(ref, label, showHex, allowDouble);
  }
}

class PromptNumberRow extends State<PromptNumber> {
  final GlobalKey<FormFieldState> _key;
  String label;
  bool showHex;
  bool allowDouble;

  PromptNumberRow(this._key, this.label, this.showHex, this.allowDouble);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
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
              return allowDouble
                  ? validateUnsafeDouble(value!)
                  : validateUnsafeInt(value!);
            },
            onChanged: (value) => setState(() {}),
          )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _key.currentState != null && showHex
              ? parseForUnsafeInt(_key.currentState?.value).toRadixString(16)
              : '',
        ),
      )
    ]);
  }
}

// ignore: must_be_immutable
class PromptList extends StatefulWidget {
  String label = 'not set';
  var ref = GlobalKey<FormFieldState>();

  PromptList(this.label, this.ref, {super.key});

  @override
  PromptListRow createState() {
    // ignore: no_logic_in_create_state
    return PromptListRow(ref, label);
  }
}

class PromptListRow extends State<PromptList> {
  final GlobalKey<FormFieldState> _key;
  String label;

  PromptListRow(this._key, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('$label: '),
      ),
      SizedBox(
          width: WIDTH * 1.75,
          child: TextFormField(
            key: _key,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter a comma-delimited list of integers',
            ),
            validator: (value) {
              return validateUnsafeListInt(value!);
            },
            onChanged: (value) => setState(() {}),
          )),
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Text(
      //     _key.currentState != null
      //         ? parseForUnsafeListInt(_key.currentState!.value).toString()
      //         : '',
      //   ),
      // )
    ]);
  }
}
