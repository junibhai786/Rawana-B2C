//Message Data

class MessageData {
  final String avatar, name, message, time;
  final int newMsg;

  MessageData({
    required this.avatar,
    required this.name,
    required this.message,
    required this.time,
    required this.newMsg,
  });
}

List<MessageData> messageDatas = [
  MessageData(
    avatar: "assets/haven/avatar_2.jpg",
    name: "Jawire",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "12:24 PM",
    newMsg: 1,
  ),
  MessageData(
    avatar: "assets/haven/avatar_3.jpg",
    name: "Lennart Cesario",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "09:56 PM",
    newMsg: 3,
  ),
  MessageData(
    avatar: "assets/haven/avatar_4.jpg",
    name: "Brian F",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "04:12 PM",
    newMsg: 10,
  ),
  MessageData(
    avatar: "assets/haven/avatar_5.jpg",
    name: "Ano Design",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "02:29 PM",
    newMsg: 0,
  ),
  MessageData(
    avatar: "assets/haven/avatar_6.jpg",
    name: "Avto Natanaele",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "01:33 PM",
    newMsg: 6,
  ),
  MessageData(
    avatar: "assets/haven/avatar_7.jpg",
    name: "Parvati Anna",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "09:56 PM",
    newMsg: 0,
  ),
  MessageData(
    avatar: "assets/haven/avatar_8.jpg",
    name: "Paula Marge",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "11:34 PM",
    newMsg: 0,
  ),
  MessageData(
    avatar: "assets/haven/avatar_9.jpg",
    name: "Asabe Saida",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "1 weeks ago",
    newMsg: 0,
  ),
  MessageData(
    avatar: "assets/haven/avatar_10.jpg",
    name: "Patricie Khadijah",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "2 weeks ago",
    newMsg: 0,
  ),
  MessageData(
    avatar: "assets/haven/avatar_11.jpg",
    name: "Maria Grazia",
    message: "Lorem ipsum dolor sit amet, consec tetur adipiscing elit",
    time: "2 weeks ago",
    newMsg: 0,
  ),
];
