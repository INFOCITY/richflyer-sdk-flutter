class RFResult{
  final bool result;
  final int errorCode;
  final String message;

  RFResult(this.result, this.errorCode, this.message);

  RFResult.fromJson(Map<String, dynamic> json)
      : result = json['result'],
        errorCode = json['errorCode'],
        message = json['message'];

  Map<String, dynamic> toJson() => {
    'result': result,
    'errorCode': errorCode,
    'message': message
  };

}