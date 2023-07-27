
enum LaunchMode {text, image, gif, movie}

class RichFlyerSettings{
  // SDK Key
  String serviceKey = '';
  // Type of notification to enable launch mode feature.
  List<LaunchMode> launchMode = [LaunchMode.gif, LaunchMode.movie];

  // (iOS)App Group Id
  String iosGroupId = '';
  // (iOS)Show a dialog box to confirm receipt of user push notifications
  RichFlyerPrompt? prompt;

  // (iOS)notification environment. false is production environment.
  bool iosSandbox = false;

  // (Android)theme color of notification dialog
  String androidThemeColor = '#468ACE';
}

class RichFlyerPrompt{
  // Title
  final String title;
  // Message
  final String message;
  // Image name that added to xcode assets.
  final String imageName;

  RichFlyerPrompt(this.title, this.message, this.imageName);
}