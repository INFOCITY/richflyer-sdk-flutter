class RFAction{
  final String notificationId;
  final String actionTitle;
  final String actionType;
  final String actionValue;
  final String notifyAction;

  RFAction(this.notificationId, this.actionTitle, this.actionType, this.actionValue, this.notifyAction);

  RFAction.fromJson(Map<String, dynamic> json)
      : notificationId = json['notificationId'],
        actionTitle = json['actionTitle'],
        actionType = json['actionType'],
        actionValue = json['actionValue'],
        notifyAction = json['notifyAction'];

  Map<String, dynamic> toJson() => {
    'notificationId': notificationId,
    'actionTitle': actionTitle,
    'actionType': actionType,
    'actionValue': actionValue,
    'notifyAction': notifyAction,
  };
}