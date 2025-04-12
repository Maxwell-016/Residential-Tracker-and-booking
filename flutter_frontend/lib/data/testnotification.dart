import 'package:flutter/material.dart';
import 'notifications.dart';

class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Web Notification Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            trigernotification(context, "This is a test notification!","Hello 👋");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Notification attempted!")),
            );
          },
          child: const Text("Trigger Notification"),
        ),
      ),
    );
  }
}
