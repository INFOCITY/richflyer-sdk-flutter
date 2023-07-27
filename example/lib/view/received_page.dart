import 'package:flutter/material.dart';
import 'package:richflyer_sdk_flutter/model/rf_contents.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter.dart';

import '../constant/strings.dart';

class ReceivedPage extends StatefulWidget {
  const ReceivedPage({Key? key}) : super(key: key);

  @override
  State<ReceivedPage> createState() => _ReceivedPageState();
}

class _ReceivedPageState extends State<ReceivedPage> {
  final _richflyerSdkFlutterPlugin = RichflyerSdkFlutter();

  @override
  void initState() {
    super.initState();
  }

  // プッシュ通知受信履歴の取得
  Future<List<RFContent>> getReceivedData() async {
    final receivedData = await _richflyerSdkFlutterPlugin.getReceivedData();
    for (RFContent content in receivedData) {
      if (content.message != null) {
        debugPrint("${Strings.tag}notificationId:${content.notificationId}");
        debugPrint("${Strings.tag}title:${content.title}");
        debugPrint("${Strings.tag}message:${content.message}");
      }
    }
    return receivedData;
  }

  // 最新のプッシュ通知の取得
  Future<RFContent?> getLatestReceivedData() async {
    final latestReceivedData =
        await _richflyerSdkFlutterPlugin.getLatestReceivedData();
    if (latestReceivedData != null) {
      if (latestReceivedData.message != null) {
        debugPrint(
            "${Strings.tag}notificationId:${latestReceivedData.notificationId}");
        debugPrint("${Strings.tag}title:${latestReceivedData.title}");
        debugPrint("${Strings.tag}message:${latestReceivedData.message}");
      }
    }
    return latestReceivedData;
  }

  // 通知の表示
  Future<void> showReceivedData() async {
    final content = await getLatestReceivedData();
    if (content != null) {
      await _richflyerSdkFlutterPlugin.showReceivedData(content.notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Received'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      showReceivedData();
                    },
                    child: Text('受信した通知を表示'),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    )),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
