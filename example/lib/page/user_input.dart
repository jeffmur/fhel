import 'package:fhel_example/page/utils.dart';
import 'package:flutter/material.dart';
import 'package:fhel_example/globals.dart';


class BooleanFormField extends FormField<bool> {
  BooleanFormField({super.key, 
    super.onSaved,
    super.validator,
    bool super.initialValue = false,
    String labelText = "Checkbox",
  }) : super(
          autovalidateMode: AutovalidateMode.always,
          builder: (FormFieldState<bool> state) {
            return CheckboxListTile(
              value: state.value,
              onChanged: state.didChange,
              subtitle: state.hasError
                  ? Builder(
                      builder: (BuildContext context) => Text(
                        state.errorText!,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    )
                  : null,
                title: Text(labelText),
            );
          },
        );
}

// Create a Form widget.
// ignore: must_be_immutable
class PromptNumber extends StatefulWidget {
  bool allowDouble = false;
  bool showHex = false;
  String label = 'not set';
  var ref = GlobalKey<FormFieldState>();
  var isEncrypted = GlobalKey<FormFieldState>();

  PromptNumber(this.label, this.ref, this.isEncrypted, {super.key});

  PromptNumber.double(this.label, this.ref, this.isEncrypted, {super.key}) {
    allowDouble = true;
  }

  PromptNumber.hex(this.label, this.ref, this.isEncrypted, {super.key}) {
    showHex = true;
  }

  @override
  PromptNumberRow createState() {
    // ignore: no_logic_in_create_state
    return PromptNumberRow(label, ref, isEncrypted, showHex, allowDouble);
  }
}

class PromptNumberRow extends State<PromptNumber> {
  final GlobalKey<FormFieldState> _key;
  final GlobalKey<FormFieldState> isEncrypted;
  String label;
  bool showHex;
  bool allowDouble;

  PromptNumberRow(this.label, this._key, this.isEncrypted, this.showHex, this.allowDouble);

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
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              _key.currentState != null && showHex
                  ? parseForUnsafeInt(_key.currentState?.value).toRadixString(16)
                  : '',
            )
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 160,
              child: BooleanFormField(
                key: isEncrypted,
                initialValue: true,
                labelText: 'Encrypt',
                onSaved: (value) => setState(() {}), 
              )
              // Bool(
              //   title: const Text('Encrypt'),
              //   value: isEncrypted,
              //   onChanged: (value) {
              //     setState(() {
              //       isEncrypted = !isEncrypted; // update visual value
              //   });
              // }
            )
          )
        ],
      )
    ]);
  }
}

// ignore: must_be_immutable
class PromptList extends StatefulWidget {
  String label = 'not set';
  var ref = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> isEncrypted;
  bool isDouble = false;

  PromptList(this.label, this.ref, this.isEncrypted, {super.key});

  PromptList.double(this.label, this.ref, this.isEncrypted, {super.key}) {
    isDouble = true;
  }

  @override
  PromptListRow createState() {
    // ignore: no_logic_in_create_state
    return PromptListRow(ref, label, isEncrypted, isDouble);
  }
}

class PromptListRow extends State<PromptList> {
  final GlobalKey<FormFieldState> _key;
  final GlobalKey<FormFieldState> isEncrypted;
  String label;
  bool isDouble;

  PromptListRow(this._key, this.label, this.isEncrypted, this.isDouble);

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
            decoration: InputDecoration(
              labelText: 'Comma-delimited list of ${isDouble ? 'doubles' : 'integers'}',
            ),
            validator: (value) {
              return isDouble
                ? validateUnsafeListDouble(value!)
                : validateUnsafeListInt(value!);
            },
            onChanged: (value) => setState(() {}),
          )),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 160,
              child: BooleanFormField(
                key: isEncrypted,
                initialValue: true,
                labelText: 'Encrypt',
                onSaved: (value) => setState(() {}), 
              )
            )
          ),
    ]);
  }
}
