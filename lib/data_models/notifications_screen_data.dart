// Notification Data

class NotificationData {
  final String image, notifTitle, notifContent, notifTime;
  final bool read;

  NotificationData({
    required this.image,
    required this.notifTitle,
    required this.notifContent,
    required this.notifTime,
    required this.read,
  });
}

List<NotificationData> notificationsDatas = [
  NotificationData(
    image: "assets/haven/resort_1.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    notifTime: "2h ago",
    read: false,
  ),
  NotificationData(
    image: "assets/haven/resort_2.jpg",
    notifTitle: "Lorem Consec tetur adipiscing elit",
    notifContent: "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
    notifTime: "10h ago",
    read: false,
  ),
  NotificationData(
    image: "assets/haven/resort_3.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent:
        "Duis aute irure dolor in reprehenderit in voluptate velit esse",
    notifTime: "1d ago",
    read: false,
  ),
  NotificationData(
    image: "assets/haven/resort_4.jpg",
    notifTitle: "Adipiscing consec tetur adipiscing elit",
    notifContent: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    notifTime: "2d ago",
    read: false,
  ),
  NotificationData(
    image: "assets/haven/resort_5.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent: "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
    notifTime: "May 10",
    read: true,
  ),
  NotificationData(
    image: "assets/haven/resort_6.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent:
        "Duis aute irure dolor in reprehenderit in voluptate velit esse",
    notifTime: "May 08",
    read: true,
  ),
  NotificationData(
    image: "assets/haven/resort_7.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent: "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
    notifTime: "May 07",
    read: true,
  ),
  NotificationData(
    image: "assets/haven/resort_8.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    notifTime: "Apr 30",
    read: true,
  ),
  NotificationData(
    image: "assets/haven/resort_9.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent: "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
    notifTime: "Apr 27",
    read: true,
  ),
  NotificationData(
    image: "assets/haven/resort_10.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent:
        "Duis aute irure dolor in reprehenderit in voluptate velit esse",
    notifTime: "Apr 26",
    read: true,
  ),
  NotificationData(
    image: "assets/haven/resort_4.jpg",
    notifTitle: "Consec tetur adipiscing elit",
    notifContent: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    notifTime: "Apr 25",
    read: true,
  ),
];
