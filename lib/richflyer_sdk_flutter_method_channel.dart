import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/rf_action.dart';
import 'model/rf_contents.dart';
import 'model/rf_result.dart';
import 'richflyer_sdk_flutter_platform_interface.dart';

class MethodChannelRichflyerSdkFlutter extends RichflyerSdkFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('jp.co.infocity/richflyer');

  Function(RFResult result)? onCallbackResult;
  Function(RFResult result, List<String> eventPostIds)? onCallbackPostMessage;
  static Function(String notificationId, RFAction rfAction)? onActionButtonTapped;
  static Function(String notificationId, String extendedProperty)? onAppLaunched;

  // ネイティブからのコールバック関数の呼び出しをハンドル
  MethodChannelRichflyerSdkFlutter() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onCallbackResult':
          // RFResultを受け取る
          dynamic rfResult = call.arguments;
          RFResult result = toRFResult(rfResult);
          onCallbackResult?.call(result);
          break;

        case 'onCallbackPostMessage':
        // RFResultを受け取る
          dynamic rfResult = call.arguments;
          RFResult result = toRFResult(rfResult);

          final String jsonData = rfResult as String;
          Map<String, dynamic> mapData = jsonDecode(jsonData);
          List<String>? eventPostIds = mapData['eventPostIds'].cast<String>();
          if (eventPostIds == null) {
            onCallbackPostMessage?.call(result, [""]);
          } else {
            onCallbackPostMessage?.call(result, eventPostIds);
          }

          break;

        case 'openNotificationStartApp':
          // 通知ドロワーで通知をタップ or 詳細ダイアログで「アプリ起動」ボタンを押下した時：Android
          String data = call.arguments;
          openNotificationStartApp(data);
          break;

        case 'openNotificationButtonAndroid':
          // 詳細ダイアログでカスタムアクションボタンを押下した時：Android
          String data = call.arguments;
          openNotificationButtonAndroid(data);
          break;

        case 'openNotificationButtonIOS':
          // 通知センターから起動された(通知タップ or カスタムアクションボタン):iOS
          String data = call.arguments;
          openNotificationButtonIOS(data);
          break;

        case 'onRFEventLaunchAppIOS':
          // 通知ダイアログで、カスタムアクションボタンが押された時：iOS
          String data = call.arguments;
          openNotificationButtonIOS(data);
          break;

        default:
          break;
      }
    });
  }

  // 詳細ダイアログでカスタムアクションボタンを押下した時：Android
  void openNotificationButtonAndroid(String data) {
    RFAction action = toRFAction(data);
    onActionButtonTapped?.call(action.notificationId, action);
  }

  // 通知センターから起動された(通知タップ or カスタムアクションボタン):iOS
  void openNotificationButtonIOS(String data){
    RFAction action = RFAction("", "", "", "", "");
    String extendedProperty = "";
    String notificationId = "";
    Map<String, dynamic> mapData;
    Map<String, String> mapActionData;
    mapData = jsonDecode(data); // actionと拡張プロパティを分離

    if (mapData.containsKey("extendedProperty") &&
        mapData["extendedProperty"] != null) {
      extendedProperty = mapData["extendedProperty"]!;
    }
    if (mapData.containsKey("notificationId") &&
        mapData["notificationId"] != null) {
      notificationId = mapData["notificationId"]!;
    }

    if (mapData.containsKey("action")) {
      Map<String, dynamic> tappedAction = mapData["action"];
      if (tappedAction != null && tappedAction.isNotEmpty) {
        String json = jsonEncode(mapData["action"]!);
        action = toRFAction(json);
        onActionButtonTapped?.call(notificationId, action);
        return;
      }
    }

    onAppLaunched?.call(notificationId,extendedProperty);
  }

  // RFActionオブジェクトに変換する
  RFAction toRFAction(String json) {
    Map<String, dynamic> mapData = {};
    try {
      mapData = jsonDecode(json);
      if (mapData.isNotEmpty) {
        RFAction rfAction = RFAction.fromJson(mapData);
        return rfAction;
      }
    }catch(e){
      debugPrint("$e");
    }
    return RFAction("", "", "", "", "");
  }

  // 通知ドロワーで通知をタップ or 詳細ダイアログで「アプリ起動」ボタンを押下した時：Android
  void openNotificationStartApp(String json){
    String notificationId = "";
    String extendedProperty = "";
    Map<String, dynamic> mapData;

    mapData = jsonDecode(json);
    if (mapData["notificationId"] != null) {
      notificationId = mapData["notificationId"]!;
    }
    if (mapData["extendedProperty"] != null) {
      extendedProperty = mapData["extendedProperty"]!;
    }
    onAppLaunched?.call(notificationId,extendedProperty);
  }

  // RFResultオブジェクトに変換する
  RFResult toRFResult(dynamic result) {
    Map<String, dynamic> mapData = {};
    try {
      if (result != null) {
        final String jsonData = result as String;
        mapData = jsonDecode(jsonData);
        if (mapData.containsKey('code')) {
          mapData['errorCode'] = mapData['code'];
          mapData.remove('code');
        }
        RFResult rfResult = RFResult.fromJson(mapData);
        return rfResult;
      }
    }catch(e){
      debugPrint("$e");
    }

    return RFResult(false, 500, "");
  }

  // 初期化
  @override
  Future<void> RFInitialize(
      Map<String, dynamic> settings, Function(RFResult result) callback) async {
    onCallbackResult = callback;
    await methodChannel.invokeMethod('RFInitialize', {'settings': settings});
  }

  // セグメントの登録
  @override
  Future<void> registerSegments(
      Map<String, String> segments, Function(RFResult result) callback) async {
    onCallbackResult = callback;
    await methodChannel
        .invokeMethod('registerSegments', {'segments': segments});
  }

  // セグメントの取得
  @override
  Future<Map<String,String>> getSegments() async {
    final dynamic segments =
        await methodChannel.invokeMethod('getSegments');
    Map<String, String> convertedMap = {};
    if(segments != null){
      convertedMap = segments.map<String, String>(
            (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return convertedMap;
  }

  // 受信履歴を取得
  @override
  Future<List<RFContent>> getReceivedData() async {
    final String? receivedData =
        await methodChannel.invokeMethod('getReceivedData');
    List<RFContent> rfContentList = [];
    if (receivedData != null) {
        final List<dynamic> jsonList = jsonDecode(receivedData);
        rfContentList = jsonList
            .map((json) => RFContent.fromJson(json as Map<String, dynamic>))
            .toList();
    }
    return rfContentList;
  }

  // 最新のプッシュ通知を取得
  @override
  Future<RFContent?> getLatestReceivedData() async {
    final String? latestData =
        await methodChannel.invokeMethod('getLatestReceivedData');
    if (latestData != null) {
      final dynamic jsonData = jsonDecode(latestData);
      RFContent rfContent = RFContent.fromJson(jsonData);
      return rfContent;
    }
    return null;
  }

  // 受信した通知の表示 invoke void専用
  @override
  Future<void> showReceivedData(String notificationId) async {
      await methodChannel.invokeMethod('showReceivedData', notificationId);
  }

  //  開封イベントコールバック
  @override
  Future<void> addOpenNotificationCallbacks(
      Function(String notificationId, RFAction rfAction) onActionButtonTapped,
      Function(String notificationId, String extendedProperty)
          onAppLaunched) async {
    MethodChannelRichflyerSdkFlutter.onActionButtonTapped = onActionButtonTapped;
    MethodChannelRichflyerSdkFlutter.onAppLaunched = onAppLaunched;
  }

  // バッジの非表示
  @override
  Future<void> resetBadgeNumber() async {
    await methodChannel.invokeMethod('resetBadgeNumber');
  }

  @override
  Future<void> setForegroundNotification(bool badge,bool alert,bool sound) async {
    Map<String,bool> options = {"badge":badge,"alert":alert,"sound":sound};
    await methodChannel.invokeMethod('setForegroundNotification',options);
  }

  // イベント駆動型プッシュリクエスト
  @override
  Future<void> postMessage(List<String> events, Map<String,String>? variables, int? standbyTime,
      Function(RFResult result, List<String> evnetPostIds) callback) async {
    onCallbackPostMessage = callback;
    final Map params = <String, dynamic>{
      'events': events
    };

    if (variables != null) {
      params['variables'] = variables;
    }
    if (standbyTime != null) {
      params['standbyTime'] = standbyTime;
    }

    await methodChannel.invokeMethod('postMessage', params);
  }

  // イベント駆動型プッシュリクエストのキャンセル
  @override
  Future<void> cancelPosting(String eventPostId, Function(RFResult result) callback) async {
    onCallbackResult = callback;
    await methodChannel
        .invokeMethod('cancelPosting', {'eventPostId': eventPostId});
  }



}
