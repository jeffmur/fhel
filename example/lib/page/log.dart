import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'settings.dart';

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
  return log.contains('Exception') || log.contains('Failed') || log.contains('Error');
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
