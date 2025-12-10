//chat screen data model

class ChatScreenData {
  final String messageContent, messageType, time;

  ChatScreenData({
    required this.messageContent,
    required this.messageType,
    required this.time,
  });
}

List<ChatScreenData> demoChatScreenData = [
  ChatScreenData(
    messageContent: "Hello, Jawire",
    messageType: "sender",
    time: "11:04 AM",
  ),
  ChatScreenData(
    messageContent: "How have you been?",
    messageType: "receiver",
    time: "11:06 AM",
  ),
  ChatScreenData(
    messageContent: "Hey Nina Rosi, I am doing fine.",
    messageType: "sender",
    time: "11:11 AM",
  ),
  ChatScreenData(
    messageContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    messageType: "receiver",
    time: "11:14 AM",
  ),
  ChatScreenData(
    messageContent: "Ut enim ad minim veniam?",
    messageType: "sender",
    time: "11:17 AM",
  ),
  ChatScreenData(
    messageContent:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
    messageType: "receiver",
    time: "11:20 AM",
  ),
  ChatScreenData(
    messageContent:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, Ut enim ad minim veniam?",
    messageType: "sender",
    time: "11:21 AM",
  ),
  ChatScreenData(
    messageContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    messageType: "receiver",
    time: "11:23 AM",
  ),
  ChatScreenData(
    messageContent: "Ut enim ad minim veniam?",
    messageType: "sender",
    time: "11:35 AM",
  ),
];
