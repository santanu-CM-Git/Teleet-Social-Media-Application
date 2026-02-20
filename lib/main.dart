import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/screens/demo_only_screen.dart';
import 'package:untitled/utilities/const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run app with demo-only screen
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: cPrimary,
        scaffoldBackgroundColor: cBlack,
      ),
      home: const DemoOnlyScreen(),
    );
  }
}
