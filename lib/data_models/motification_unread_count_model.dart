class NotificationUnreadCount {
  String? message;
  int? unreadCount;

  NotificationUnreadCount({this.message, this.unreadCount});

  NotificationUnreadCount.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    unreadCount = json['unread_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['unread_count'] = this.unreadCount;
    return data;
  }
}
