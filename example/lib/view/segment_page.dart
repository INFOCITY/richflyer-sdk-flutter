import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter.dart';
import 'package:richflyer_sdk_flutter_example/constant/strings.dart';

class SegmentPage extends StatefulWidget {
  const SegmentPage({Key? key}) : super(key: key);

  @override
  State<SegmentPage> createState() => _SegmentPageState();
}

class _SegmentPageState extends State<SegmentPage> {
  final _richflyerSdkFlutterPlugin = RichflyerSdkFlutter();

  List<String> _values = [];

  final List<Map<String, dynamic>> cardList = [
    {
      'title': 'genre',
      'buttonText': ['comic', 'magazine', 'novel'],
    },
    {
      'title': 'day',
      'buttonText': ['月', '火', '水', '木', '金', '土', '日'],
    },
    {
      'title': 'age',
      'buttonText': ['10', '20', '30', '40', '50', '60', '70', '80', '90', '100'],
    },
    {
      'title': 'registered',
      'buttonText': ['YES', 'NO'],
    },
  ];

  @override
  void initState() {
    super.initState();
    // ピッカーの初期値を設定
    for (int i = 0; i < cardList.length; i++) {
      _values.add(cardList[i]['buttonText'][0]);
    }
    // getSegments();
  }

  // セグメントを取得する
  Future<void> getSegments() async {
    final getSegments = await _richflyerSdkFlutterPlugin.getSegments();
    getSegments.forEach((key, value) {
      debugPrint('$key : $value');
    });
  }

  // Scaffoldを表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Segment'),
      ),
      body: _buildCardListWidget(context),
    );
  }

  // Cardのリストを作成する関数
  List<Widget> _buildCardList(BuildContext context) {
    return cardList.asMap().entries.map((entry) {
      final sectionIndex = entry.key;
      final card = entry.value;
      return Padding(
        // padding: EdgeInsets.all(1),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Text(card['title']),
                  ),
                  TextButton(
                    onPressed: () {
                      _showPicker(context, sectionIndex);
                    },
                    child: Text(_values[sectionIndex]),
                  )
                ],
              ),
            ),
            Visibility(
              child: _showRegisterSegmentButton(),
              visible: sectionIndex == 3 ? true : false,
            )
          ],
        ),
      );
    }).toList();
  }

  // 作成したCardのリストを表示するWidget
  Widget _buildCardListWidget(BuildContext context) {
    return Column(
      children: _buildCardList(context),
    );
  }

  void _showPicker(BuildContext context, int sectionIndex) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 4,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: cardList[sectionIndex]['buttonText']
                  .map((item) => _pickerItem(item))
                  .cast<Widget>()
                  .toList(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _values[sectionIndex] =
                      cardList[sectionIndex]['buttonText'][index];
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 28),
    );
  }

  Widget _showRegisterSegmentButton() {
    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 3)),
        SizedBox(
          height: 150,
          width: 150,
          child: ElevatedButton(
            onPressed: () {
              // セグメントを登録
              Map<String, String> stringSegments = {};
              Map<String, int> intSegments = {};
              Map<String, bool> boolSegments = {};
              Map<String, DateTime> dateSegments = {};
              getSelectedPickerValue().forEach((key, value) {
                switch(value.runtimeType) {
                  case String:
                    stringSegments[key] = value;
                    break;
                  case int:
                    intSegments[key] = value;
                    break;
                  case bool:
                    boolSegments[key] = value;
                    break;
                  case DateTime:
                    dateSegments[key] = value;
                }
              });
              dateSegments['registeredDate'] = DateTime.now();

              _richflyerSdkFlutterPlugin.registerSegments(
                  stringSegments,intSegments,boolSegments,dateSegments,
                  (result) {
                    // セグメント登録後の処理
                    String message = "";
                    if (result.result) {
                      debugPrint("${Strings.tag}セグメント登録成功");
                      message += 'セグメントの登録が完了しました。\ncode:${result.errorCode}';
                    } else {
                      debugPrint("${Strings.tag}${result.message} code: ${result.errorCode.toString()}");
                      message += 'セグメントの登録に失敗しました。\ncode:${result.errorCode}\nmessage:${result.message}';
                    }
                    _showMessageDialog(context, message);
                  });
            },
            child: Text('登録'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ピッカーの設定値を返す
  Map<String, dynamic> getSelectedPickerValue() {
    Map<String, dynamic> _selectedValues = {};
    for (final card in cardList) {
      switch (card['title']) {
        case 'genre':
          _selectedValues['genre'] = _values[0];
          break;
        case 'day':
          _selectedValues['day'] = _values[1];
          break;
        case 'age':
          _selectedValues['age'] = int.parse(_values[2]);
          break;
        case 'registered':
          _selectedValues['registered'] = _values[3] == 'YES' ? true : false;
          break;
        default:
          break;
      }
    }
    return _selectedValues;
  }

  Future<void> _showMessageDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('セグメント'),
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
