import 'package:flutter/material.dart';
import 'package:untitled/utilities/const.dart';

class DemoOnlyScreen extends StatelessWidget {
  const DemoOnlyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBlack,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 60,
                  color: cWhite,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'DEMO VERSION ONLY',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cWhite,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: cDarkBG,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'This is a demo version of the application.',
                      style: TextStyle(
                        fontSize: 16,
                        color: cLightText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The code structure is visible for review purposes only. This application cannot be run without proper backend configuration, Firebase setup, and third-party service credentials.',
                      style: TextStyle(
                        fontSize: 14,
                        color: cLightText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: cLightText.withOpacity(0.2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'For questions about the full implementation or licensing, please contact the project owner.',
                      style: TextStyle(
                        fontSize: 12,
                        color: cLightText,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: cPrimary,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
