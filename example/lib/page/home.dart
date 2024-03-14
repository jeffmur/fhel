import 'package:provider/provider.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:flutter/material.dart';
import 'package:fhel_example/addition.dart';
import 'user_input.dart';
import 'bottom_bar.dart';
import 'settings.dart';

class HomePage extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: HexadecimalAddition(),
          icon: Icons.home,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: SettingsPage(),
          icon: Icons.settings,
          title: 'Settings',
          navigatorkey: _tab3navigatorKey,
        ),
      ],
    );
  }
}

class LogView extends ChangeNotifier {
  List<String> logs = [];

  void log(String log) {
    logs.add(log);
    notifyListeners();
  }
}

class LogScreen extends StatefulWidget {
  // final Function(String) addLogCallback;

  const LogScreen({super.key});

  @override
  LogListScreen createState() {
    return LogListScreen();
  }
}

bool isException(String log) {
  return log.contains('Exception');
}

class LogListScreen extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    var logs = Provider.of<SessionChanges>(context).logs;
    // in reverse order
    logs = logs.reversed.toList();
    return SizedBox(
      height: 365,
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              logs[index],
              style: TextStyle(
                // fontSize: 14,
                color: isException(logs[index]) ? Colors.red : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}

class TestSelection extends StatelessWidget {
  const TestSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Hexadecimal Addition'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const HexadecimalAddition(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

// Create a Form widget.
class HexadecimalAddition extends StatefulWidget {
  const HexadecimalAddition({super.key});

  @override
  HexadecimalAdditionWidget createState() {
    return HexadecimalAdditionWidget();
  }
}

class HexadecimalAdditionWidget extends State<HexadecimalAddition> {
  final _x = GlobalKey<FormFieldState>();
  final _y = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionChanges>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hexadecimal Addition')),
      drawer: TestSelection(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Encrypt and Add two integers'),
            ),
            PromptNumber('x', _x),
            PromptNumber('y', _y),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: ButtonBar(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          session.clearLogs();
                          final x = parseForUnsafeInt(_x.currentState?.value);
                          final y = parseForUnsafeInt(_y.currentState?.value);
                          final expected = x + y;
                          final actual = addAsHex(session, x, y);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: int.tryParse(actual) == expected
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
                          final x = parseForUnsafeInt(_x.currentState?.value);
                          final y = parseForUnsafeInt(_y.currentState?.value);
                          final expected = x + y;
                          final actual =
                              addAsHex(session, x, y, addPlain: true);
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
      ),
    );
  }
}