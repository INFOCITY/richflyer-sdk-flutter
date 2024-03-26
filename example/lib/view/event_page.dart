import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter.dart';
import 'package:richflyer_sdk_flutter_example/constant/strings.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  final _richflyerSdkFlutterPlugin = RichflyerSdkFlutter();

  TextEditingController _textFieldEvent = TextEditingController();
  TextEditingController _textFieldVariableName = TextEditingController();
  TextEditingController _textFieldVariableValue = TextEditingController();
  TextEditingController _textFieldStandbyTime = TextEditingController();

  @override
  void dispose() {
    _textFieldEvent.dispose();
    _textFieldVariableName.dispose();
    _textFieldVariableValue.dispose();
    _textFieldStandbyTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _textFieldEvent,
              decoration: InputDecoration(
                labelText: 'イベント名',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _textFieldVariableName,
              decoration: InputDecoration(
                labelText: '変数名',
              ),
            ),
            TextField(
              controller: _textFieldVariableValue,
              decoration: InputDecoration(
                labelText: '値',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _textFieldStandbyTime,
              decoration: InputDecoration(
                labelText: '待機時間',
              ),
            ),
            SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () {
                // ボタンが押された時の処理を記述
                String event = _textFieldEvent.text;
                String variableName = _textFieldVariableName.text;
                String variableValue = _textFieldVariableValue.text;
                int standbyTime = int.tryParse(_textFieldStandbyTime.text) ?? 0;
                // ここで入力されたテキストを利用するなどの処理を行う
                var variables = {
                  variableName : variableValue,
                };
                List<String> events = [];
                events.add(event);
                _richflyerSdkFlutterPlugin.postMessage(events, variables, standbyTime, (result, evnetPostIds) {
                  debugPrint("${Strings.tag} ${result.message} code:${result.errorCode.toString()} eventPostId:${evnetPostIds}");
                  String message = "";
                  if (result.result) {
                    message += 'メッセージ配信リクストが完了しました。\ncode:${result.errorCode}\neventPostId:${evnetPostIds}';
                  } else {
                    message += 'メッセージ配信リクエストに失敗しました。\ncode:${result.errorCode}\nmessage:${result.message}';
                  }
                  _showMessageDialog(context, message);
                });
              },
              child: Text('メッセージ配信'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMessageDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('イベント'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }
}
