
import 'model/rf_action.dart';
import 'model/rf_contents.dart';
import 'model/rf_result.dart';
import 'richflyer_sdk_flutter_method_channel.dart';

abstract class RichflyerSdkFlutterPlatform {

  static RichflyerSdkFlutterPlatform _instance = MethodChannelRichflyerSdkFlutter();
  static RichflyerSdkFlutterPlatform get instance => _instance;

  static set instance(RichflyerSdkFlutterPlatform instance) {
    _instance = instance;
  }

  // 初期化
  Future<void> RFInitialize(Map<String, dynamic> settings, Function(RFResult result) callback) {
    throw UnimplementedError('RFInitialize() has not been implemented.');
  }

  // セグメントの登録
  Future<void> registerSegments(Map<String,String> segments, Function(RFResult result) callback){
    throw UnimplementedError('registerSegments() has not been implemented.');
  }

  // セグメントの取得
  Future<Map<String,String>> getSegments(){
    throw UnimplementedError('registerSegments() has not been implemented.');
  }

  // 受信履歴を取得
  Future<List<RFContent>> getReceivedData(){
    throw UnimplementedError('getReceivedData() has not been implemented.');
  }

  // 最新のプッシュ通知を取得
  Future<RFContent?> getLatestReceivedData(){
    throw UnimplementedError('getLatestReceivedData() has not been implemented.');
  }

  // 受信した通知の表示
  Future<void> showReceivedData(String notificationId){
    throw UnimplementedError('showReceivedData() has not been implemented.');
  }

  // バッジの非表示
  Future<void> resetBadgeNumber() {
    throw UnimplementedError('resetBadgeNumber() has not been implemented.');
  }

  // 受信した通知の表示
  Future<void> addOpenNotificationCallbacks(Function(String notificationId, RFAction rfAction) onActionButtonTapped, Function(String notificationId, String extendedProperty) onAppLaunched) async {
    throw UnimplementedError('addOpenNotificationCallbacks() has not been implemented.');
  }

  Future<void> setForegroundNotification(bool badge,bool alert,bool sound) async {
    throw UnimplementedError('setForegroundNotification() has not been implemented.');
  }

  // イベント駆動型プッシュリクエスト
  Future<void> postMessage(List<String> events, Map<String,String>? variables, int? standbyTime, Function(RFResult result, List<String> evnetPostIds) callback){
    throw UnimplementedError('postMessage() has not been implemented.');
  }

  // イベント駆動型プッシュリクエストのキャンセル
  Future<void> cancelPosting(String eventPostId, Function(RFResult result) callback){
    throw UnimplementedError('cancelPosting() has not been implemented.');
  }

}
