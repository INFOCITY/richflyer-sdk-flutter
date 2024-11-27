class RFContent{
  final int contentType;
  final String? gifPath;
  final String? imagePath;
  final String? message;
  final String? moviePath;
  final int notificationDate;
  final String notificationId;
  final int receivedDate;
  final String title;
  final String extendedProperty;

  RFContent(this.contentType, this.gifPath, this.imagePath, this.message, this.moviePath, this.notificationDate, this.notificationId, this.receivedDate, this.title, this.extendedProperty);

  RFContent.fromJson(Map<String, dynamic> json)
      : contentType = json['contentType'],
        gifPath = json['gifPath'],
        imagePath = json['imagePath'],
        message = json['message'],
        moviePath = json['moviePath'],
        notificationDate = json['notificationDate'],
        notificationId = json['notificationId'],
        receivedDate = json['receivedDate'],
        title = json['title'],
        extendedProperty = json['extendedProperty'];

  Map<String, dynamic> toJson() => {
    'contentType': contentType,
    'gifPath': gifPath,
    'imagePath': imagePath,
    'message': message,
    'moviePath': moviePath,
    'notificationDate': notificationDate,
    'notificationId': notificationId,
    'receivedDate': receivedDate,
    'title': title,
    'extendedProperty': extendedProperty
  };

}