import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fhel/seal.dart';
import 'dart:math';
import 'package:fhel_example/page/utils.dart';
import 'package:fhel_example/globals.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Settings build');
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Parameters'),
                ContextForm(),
                Text('Keys'),
                KeyDerivation()
              ],
            ),
          ),
        ));
  }
}

class SessionChanges extends ChangeNotifier {
  Session _session = globalSession;

  Map get context => _session.ctx;
  String get status => _session.ctxStatus;
  Seal get fhe => _session.fhe;

  String get publicKey => _session.publicKey;
  String get secretKey => _session.secretKey;
  String get relinKeys => _session.relinKeys;

  void validate(String scheme, Map context) {
    _session = Session(scheme, context);
    notifyListeners();
  }
}

// Create a Form widget.
class ContextForm extends StatefulWidget {
  const ContextForm({super.key});

  @override
  ParameterForm createState() {
    return ParameterForm();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class ParameterForm extends State<ContextForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _polyModDegree = GlobalKey<FormFieldState>();
  final _scalar = GlobalKey<FormFieldState>();
  final _coeffMod = GlobalKey<FormFieldState>();
  final _plainMod = GlobalKey<FormFieldState>();
  final _secLevel = GlobalKey<FormFieldState>();

  var _scheme = globalSession.scheme; // Copy initial scheme
  var _context = globalSession.ctx; // Copy initial context

  bool isBatchingEnabled = true;
  bool isDefaultParams = false;

  void defaultContext() {
    Map defaults = switch (_scheme) {
      'ckks' => ckks,
      // BFV / BGV
      _ => isBatchingEnabled ? batching : plainModulus
    };

    print("$_scheme defaults? $defaults");

    _polyModDegree.currentState?.setState(() {
      isDefaultParams
          ? _polyModDegree.currentState!
              .didChange(defaults['polyModDegree'].toString())
          : _polyModDegree.currentState!.didChange('');
    });
    int defaultScalar =
        _scheme != 'ckks' ? -1 : log(defaults['encodeScalar']) ~/ log(2);
    _scalar.currentState?.setState(() {
      isDefaultParams && _scheme == 'ckks'
          ? _scalar.currentState!.didChange(defaultScalar.toString())
          : _scalar.currentState!.didChange('');
    });
    String defaultQSizes =
        _scheme != 'ckks' ? '' : defaults['qSizes']?.join(',');
    _coeffMod.currentState?.setState(() {
      isDefaultParams && _scheme == 'ckks'
          ? _coeffMod.currentState!.didChange(defaultQSizes)
          : _coeffMod.currentState!.didChange('');
    });
    _plainMod.currentState?.setState(() {
      isDefaultParams && _scheme != 'ckks'
          ? isBatchingEnabled
              ? _plainMod.currentState!
                  .didChange(defaults['ptModBit'].toString())
              : _plainMod.currentState!.didChange(defaults['ptMod'].toString())
          : _plainMod.currentState!.didChange('');
    });
    _secLevel.currentState?.setState(() {
      isDefaultParams && _scheme != 'ckks'
          ? _secLevel.currentState!.didChange(defaults['secLevel'].toString())
          : _secLevel.currentState!.didChange('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionChanges>(context);
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: WIDTH,
            child: CheckboxListTile(
                title: const Text('Use Default'),
                value: isDefaultParams,
                onChanged: (_) {
                  setState(() {
                    isDefaultParams = !isDefaultParams;
                  });
                  defaultContext();
                }),
          ),
          SizedBox(
            width: WIDTH, // Set the desired width value
            child: DropdownButtonFormField(
              value: _scheme,
              items: const [
                DropdownMenuItem(
                  value: 'bfv',
                  child: Text('BFV'),
                ),
                DropdownMenuItem(
                  value: 'bgv',
                  child: Text('BGV'),
                ),
                DropdownMenuItem(
                  value: 'ckks',
                  child: Text('CKKS'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _scheme = value.toString();
                  isDefaultParams = false;
                  defaultContext();
                });
              },
            ),
          ),
          Visibility(
            visible: _scheme == 'bfv' || _scheme == 'bgv',
            child: SizedBox(
              width: WIDTH,
              child: CheckboxListTile(
                  enabled: !isDefaultParams,
                  title: const Text('Batching'),
                  value: isBatchingEnabled,
                  onChanged: (value) {
                    setState(() {
                      isBatchingEnabled = !isBatchingEnabled;
                    });
                  }),
            ),
          ),
          SizedBox(
            width: WIDTH, // Set the desired width value
            child: TextFormField(
              key: _polyModDegree,
              enabled: !isDefaultParams,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: "Poly Modulus Degree"),
              validator: (value) {
                if (isDefaultParams) return null;
                return validateUnsafeInt(value!);
              },
              onSaved: (newValue) =>
                  _context['polyModDegree'] = int.parse(newValue!),
            ),
          ),
          Visibility(
            visible: _scheme == 'ckks',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _scalar,
                enabled: !isDefaultParams,
                decoration: const InputDecoration(
                    hintText: 'Encoder Scalar', prefixText: '2^'),
                validator: (value) {
                  if (isDefaultParams) return null;
                  return validateUnsafeInt(value!);
                },
                onSaved: (newValue) =>
                    _context['encodeScalar'] = pow(2, int.parse(newValue!)),
              ),
            ),
          ),
          Visibility(
            visible: _scheme == 'ckks',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _coeffMod,
                enabled: !isDefaultParams,
                decoration:
                    const InputDecoration(hintText: 'Coeff Mod Bit Sizes'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isDefaultParams) return null;
                  return validateUnsafeListInt(value!);
                },
                onSaved: (value) => _context['qSizes'] =
                    value!.split(',').map(int.parse).toList(),
              ),
            ),
          ),
          Visibility(
            visible: _scheme == 'bfv' || _scheme == 'bgv',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _plainMod,
                enabled: !isDefaultParams,
                decoration: InputDecoration(
                  hintText: isBatchingEnabled == true
                      ? "Plain Modulus Bit Size"
                      : "Plain Modulus Size",
                  // prefixText: "Plain Modulus Bit Size: "
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!isDefaultParams) return null;
                  return validateUnsafeInt(value!);
                },
                onSaved: (value) {
                  if (isBatchingEnabled) {
                    _context['ptModBit'] = int.parse(value!);
                  } else {
                    _context['ptMod'] = int.parse(value!);
                  }
                },
              ),
            ),
          ),
          Visibility(
            visible: _scheme == 'bfv' || _scheme == 'bgv',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _secLevel,
                enabled: !isDefaultParams,
                decoration: const InputDecoration(
                  hintText: 'Security Level',
                  // prefixText: "Security Level: "
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isDefaultParams) return null;
                  return validateUnsafeInt(value!);
                },
                onSaved: (value) {
                  _context['secLevel'] = int.parse(value!);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  _formKey.currentState!.save();
                  // Update session
                  session.validate(_scheme, _context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(session.status)),
                  );
                }
              },
              child: const Text('Validate'),
            ),
          ),
        ],
      ),
    );
  }
}

// Create a Form widget.
class KeyDerivation extends StatefulWidget {
  const KeyDerivation({super.key});

  @override
  KeyDerivationState createState() {
    return KeyDerivationState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class KeyDerivationState extends State<KeyDerivation> {
  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionChanges>(context);
    return SizedBox(
      width: WIDTH,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Public Key'),
                subtitle: Text(session.publicKey),
              ),
              ListTile(
                title: const Text('Secret Key'),
                subtitle: Text(session.secretKey),
              ),
              ListTile(
                title: const Text('Relin Keys'),
                subtitle: Text(session.relinKeys),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                session.fhe.genKeys();
                session.fhe.genRelinKeys();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Keys generated')),
              );
            },
            child: const Text('Generate Keys'),
          ),
        ],
      ),
    );
  }
}
