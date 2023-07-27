import 'package:flutter/material.dart';
import 'dart:async';
import 'package:richflyer_sdk_flutter/richflyer_settings.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter.dart';
import 'constant/strings.dart';
import 'view/tab_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _richflyerSdkFlutterPlugin = RichflyerSdkFlutter();
  final int colorCode = 0xFF009485;

  @override
  void initState() {
    super.initState();
    setOpenNotificationCallback();

    RFInitialize();
  }

  Future<void> setForegroundNotification() async {
    _richflyerSdkFlutterPlugin.setForegroundNotification(true, true, true);
  }

  // RichFlyerの初期化
  Future<void> RFInitialize() async {

    RichFlyerSettings settings = RichFlyerSettings();
    settings.serviceKey = "";
    settings.launchMode = [LaunchMode.gif, LaunchMode.movie];
    settings.iosGroupId = "group.net.richflyer.app";
    settings.prompt = RichFlyerPrompt("お得な情報", "通知を許可するとお得な情報が届きます！！", "Information");
    settings.iosSandbox = true;
    settings.androidThemeColor = "#468ACE";

    await _richflyerSdkFlutterPlugin.RFInitialize(settings, (result) => {
          if (result.result)
            {
              debugPrint("${Strings.tag}RichFlyer初期化成功"),
              setForegroundNotification(),
              // resetBadgeNumber(true),
            }
          else
            {
              debugPrint(
                  "${Strings.tag} ${result.message}code:${result.errorCode.toString()}")
            }
        });
  }

  // バッジの非表示
  Future<void> resetBadgeNumber() async {
    await _richflyerSdkFlutterPlugin.resetBadgeNumber();
  }

  // プッシュ通知開封時の処理
  Future<void> setOpenNotificationCallback() async {
    await _richflyerSdkFlutterPlugin.addOpenNotificationCallbacks(
        (notificationId, rfAction) => {
          // アクションボタンタップ
              debugPrint("${Strings.tag}Action Button Tapped!!"),
              debugPrint("${Strings.tag} notificationId: $notificationId"),
              debugPrint("${Strings.tag} actionTitle: ${rfAction.actionTitle}"),
              debugPrint("${Strings.tag} actionValue: ${rfAction.actionValue}"),
            },
        (notificationId, extendedProperty) => {
          // アプリ起動
              debugPrint("${Strings.tag}App Launched!!"),
              debugPrint("${Strings.tag} notificationId: $notificationId"),
              debugPrint("${Strings.tag} extendedProperty: $extendedProperty"),
            });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          colorCode,
          <int, Color>{
            50: Color(0xFFE0F7F5),
            100: Color(0xFFB3ECE8),
            200: Color(0xFF80E0D9),
            300: Color(0xFF4DC4C2),
            400: Color(0xFF26B3B0),
            500: Color(0xFF009485),
            600: Color(0xFF008277),
            700: Color(0xFF006B6C),
            800: Color(0xFF00575F),
            900: Color(0xFF003E48),
          },
        ),
        brightness: Brightness.light,
      ),
      home: Scaffold(body: TabPage()),
    );
  }
}
