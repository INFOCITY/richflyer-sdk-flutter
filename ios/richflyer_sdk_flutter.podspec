#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint richflyer_sdk_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'richflyer_sdk_flutter'
  s.version          = '1.0.2'
  s.summary          = 'By embedding this SDK in your Flutter app, you will be able to receive push notifications delivered by RichFlyer.RichFlyer is a multifunctional push notification delivery ASP service that offers ultra-fast delivery, push notification delivery with rich content, and more.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://richflyer.net'
  s.license          = { :file => '../LICENSE' }
  s.author           = { "INFOCITY, Inc." => "richflyer@infocity.co.jp" }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
   # ローカルフレームワークとしてRichFlyerフレームワークを格納
  s.vendored_frameworks = 'framework/*.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
