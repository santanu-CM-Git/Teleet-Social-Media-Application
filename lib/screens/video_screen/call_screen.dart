import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image for caller
          Positioned.fill(
            child: Image.network(
              'https://via.placeholder.com/400', // replace with caller's profile image URL
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay to improve contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          // Caller information and controls
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Caller info at the top
                Column(
                  children: [
                    Text(
                      'Audio Calling…',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150', // replace with caller's profile image URL
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'John Doe', // Replace with caller's name
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'WhatsApp Audio', // Static label or dynamic based on call type
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Call control buttons at the bottom
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Mute button
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'mute_button',
                            backgroundColor: Colors.white,
                            onPressed: () {
                              // Add mute functionality
                            },
                            child: Icon(
                              Icons.mic_off,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Mute',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Speaker button
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'speaker_button',
                            backgroundColor: Colors.white,
                            onPressed: () {
                              // Add speaker functionality
                            },
                            child: Icon(
                              Icons.volume_up,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Speaker',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // End Call button
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'end_call_button',
                            backgroundColor: Colors.red,
                            onPressed: () {
                              // End call action
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'End',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
