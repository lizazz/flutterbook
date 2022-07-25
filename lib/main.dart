import "dart:io";
import 'package:flutter/material.dart';
import "package:path_provider/path_provider.dart";
import "appointments/Appointments.dart";
import 'contacts/Contacts.dart';
import 'notes/Notes.dart';
import 'tasks/Tasks.dart';
import 'utils.dart' as utils;

Future<void> main() async {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory docsDir =
        await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    runApp(FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  Widget build(BuildContext inContext) {
    return MaterialApp(
      title: 'Flutter book',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: DefaultTabController(
          length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("FlutterBook"),
            bottom: const TabBar(
              tabs: [
                // Tab(
                //   icon: Icon(Icons.date_range),
                //   text: "Appointments",
                // ),
                // Tab(
                //   icon: Icon(Icons.contacts),
                //   text: "Contacts",
                // ),
                Tab(
                  icon: Icon(Icons.note),
                  text: "Notes",
                ),
                Tab(
                  icon: Icon(Icons.assignment_turned_in),
                  text: "Tasks",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Appointments(),
              // Contacts(),
              Notes(),
              Tasks()
            ],
          ),
        ),
      ),
    );
  }
}
