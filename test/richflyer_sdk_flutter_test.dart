import 'package:flutter_test/flutter_test.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter_platform_interface.dart';
import 'package:richflyer_sdk_flutter/richflyer_sdk_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRichflyerSdkFlutterPlatform
    with MockPlatformInterfaceMixin
    implements RichflyerSdkFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RichflyerSdkFlutterPlatform initialPlatform = RichflyerSdkFlutterPlatform.instance;

  test('$MethodChannelRichflyerSdkFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRichflyerSdkFlutter>());
  });

  test('getPlatformVersion', () async {
    RichflyerSdkFlutter richflyerSdkFlutterPlugin = RichflyerSdkFlutter();
    MockRichflyerSdkFlutterPlatform fakePlatform = MockRichflyerSdkFlutterPlatform();
    RichflyerSdkFlutterPlatform.instance = fakePlatform;

    expect(await richflyerSdkFlutterPlugin.getPlatformVersion(), '42');
  });
}
