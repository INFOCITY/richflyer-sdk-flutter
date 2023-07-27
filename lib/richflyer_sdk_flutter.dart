import 'model/rf_action.dart';
import 'model/rf_contents.dart';
import 'model/rf_result.dart';
import 'richflyer_sdk_flutter_platform_interface.dart';
import 'richflyer_settings.dart';


class RichflyerSdkFlutter {

  // RichFlyerの初期化
  Future<void> RFInitialize(RichFlyerSettings settings, Function(RFResult result) callback) async {

    Map<String, dynamic> rfSettings = {};
    rfSettings['RICHFLYER_SERVICE_KEY'] = settings.serviceKey;
    rfSettings['RICHFLYER_APP_GROUP_ID'] = settings.iosGroupId;
    rfSettings['RICHFLYER_SANDBOX'] = settings.iosSandbox;
    rfSettings['RICHFLYER_THEME_COLOR'] = settings.androidThemeColor;

    RichFlyerPrompt? prompt = settings.prompt;
    if (prompt != null) {
      Map<String, String> rfPrompt = {};
      rfPrompt['title'] = prompt.title;
      rfPrompt['message'] = prompt.message;
      rfPrompt['imageName'] = prompt.imageName;
      rfSettings['RICHFLYER_UNIQUE_DIALOG'] = rfPrompt;
    }

    settings.launchMode.forEach((element) {
      switch(element) {
        case LaunchMode.text:
          rfSettings['RICHFLYER_TEXT'] = true;
          break;
        case LaunchMode.image:
          rfSettings['RICHFLYER_IMAGE'] = true;
          break;
        case LaunchMode.gif:
          rfSettings['RICHFLYER_GIF'] = true;
          break;
        case LaunchMode.movie:
          rfSettings['RICHFLYER_MOVIE'] = true;
          break;
        default:
      }
    });

    RichflyerSdkFlutterPlatform.instance.RFInitialize(rfSettings,callback);
  }

  // セグメントの登録
  Future<void> registerSegments(
      Map<String, String> stringSegments,
      Map<String, int> intSegments,
      Map<String, bool> boolSegments,
      Map<String, DateTime> dateSegments,
      Function(RFResult result) callback){

    Map<String, String> segments = {};
    stringSegments.forEach((key, value) {
      segments[key] = value;
    });
    intSegments.forEach((key, value) {
      segments[key] = value.toString();
    });
    boolSegments.forEach((key, value) {
      segments[key] = value ? "true" : "false";
    });
    dateSegments.forEach((key, value) {
      segments[key] = (value.millisecondsSinceEpoch / 1000).floor().toString();
    });


    return RichflyerSdkFlutterPlatform.instance.registerSegments(segments,callback);
  }

  // セグメントの取得
  Future<Map<String,String>> getSegments(){
    return RichflyerSdkFlutterPlatform.instance.getSegments();
  }

  // 受信履歴を取得
  Future<List<RFContent>> getReceivedData(){
    return RichflyerSdkFlutterPlatform.instance.getReceivedData();
  }

  // 最新のプッシュ通知を取得
  Future<RFContent?> getLatestReceivedData(){
    return RichflyerSdkFlutterPlatform.instance.getLatestReceivedData();
  }

  // 受信した通知の表示
  Future<void> showReceivedData(String notificationId) {
    return RichflyerSdkFlutterPlatform.instance.showReceivedData(notificationId);
  }

  // バッジの非表示
  Future<void> resetBadgeNumber() {
    return RichflyerSdkFlutterPlatform.instance.resetBadgeNumber();
  }

  // プッシュ通知開封時のコールバック
  Future<void> addOpenNotificationCallbacks(Function(String notificationId, RFAction rfAction) onActionButtonTapped, Function(String notificationId, String extendedProperty) onAppLaunched) async {
    return RichflyerSdkFlutterPlatform.instance.addOpenNotificationCallbacks(onActionButtonTapped,onAppLaunched);
  }

  // フォアグラウンド通知の設定
  Future<void> setForegroundNotification(bool badge,bool alert,bool sound) async {
    return RichflyerSdkFlutterPlatform.instance.setForegroundNotification(badge,alert,sound);
  }
}
