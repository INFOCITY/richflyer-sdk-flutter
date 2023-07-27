import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter_method_channel.dart';

void main() {
  MethodChannelRichflyerSdkFlutter platform = MethodChannelRichflyerSdkFlutter();
  const MethodChannel channel = MethodChannel('jp.co.infocity/richflyer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
