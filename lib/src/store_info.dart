import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class StoreInfo {
  static const String _playStoreVersionRegex = 'Current Version.+?>(\\d+.+?)<';
  static const String _appStoreVersionRegex = '"version":"(.+?)"';
  static const String _appStoreUrlRegex = '"trackViewUrl":"(.+?)"';

  String _storeUrl;
  String _storeVersion;

  String get storeUrl => _storeUrl;
  String get storeVersion => _storeVersion;

  static String _playStoreUrl(String packageName) =>
      'https://play.google.com/store/apps/details?id=$packageName';
  static String _appStoreLookupUrl(String packageName) =>
      'http://itunes.apple.com/lookup?bundleId=$packageName';
    
  StoreInfo._();

  static Future<StoreInfo> fromPackageName(String packageName) async {
    StoreInfo storeInfo = StoreInfo._();

    if (!(Platform.isIOS || Platform.isAndroid)) return storeInfo;

    String url = Platform.isAndroid
        ? _playStoreUrl(packageName)
        : _appStoreLookupUrl(packageName);
    http.Response storeLookupResponse = await http.get(url);
    RegExp versionRegex = RegExp(
        Platform.isAndroid ? _playStoreVersionRegex : _appStoreVersionRegex);
    Match match = versionRegex.firstMatch(storeLookupResponse.body);
    storeInfo._storeVersion = match?.group(1);

    if (Platform.isAndroid)
      storeInfo._storeUrl = url;
    else {
      RegExp appStoreUrlRegex = RegExp(StoreInfo._appStoreUrlRegex);
      match = appStoreUrlRegex.firstMatch(storeLookupResponse.body);
      storeInfo._storeUrl = match?.group(1);
    }

    return storeInfo;
  }
}
