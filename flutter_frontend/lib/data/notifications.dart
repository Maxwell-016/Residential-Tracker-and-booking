import 'dart:html' as html;


void trigernotification(String? n,String title, String body) async {
  if (html.Notification.supported) {
    final permission = await html.Notification.requestPermission();

    if (permission == 'granted') {
      html.Notification(title, body: body, icon: 'https://res.cloudinary.com/dk10knkfh/image/upload/v1743967762/file-1743967737959_ww5yf3.png');
    } else {
      print("Notification permission not granted");
    }
  } else {
    print("Browser does not support notifications");
  }
}

