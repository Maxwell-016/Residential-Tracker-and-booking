import 'package:awesome_notifications/awesome_notifications.dart';

trigernotification(String? fileName,String status,String title){
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 8,
          channelKey: "app_status",
          title: title,
          body: "$fileName $status"
      )

  );
}

