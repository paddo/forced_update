import 'package:forced_update/src/store_info.dart';
import 'package:forced_update/src/version_part.dart';
import 'package:package_info/package_info.dart';

class ForcedUpdate {
  String _packageName;
  final VersionPart _updateOnChangeTo;
  StoreInfo _storeInfo;

  ForcedUpdate(
      {VersionPart updateOnChangeTo = VersionPart.major, String packageName})
      : _updateOnChangeTo = updateOnChangeTo,
        _packageName = packageName;

  Future<Null> _cachePackageName() async {
    if (_packageName == null)
      _packageName = (await PackageInfo.fromPlatform()).packageName;
  }

  Future<StoreInfo> getStoreInfo({bool useCache = true}) async {
    await _cachePackageName();
    if (!useCache || _storeInfo == null)
      _storeInfo = await StoreInfo.fromPackageName(_packageName);
    return _storeInfo;
  }

  Future<String> getRunningVersion() async {
    return (await PackageInfo.fromPlatform()).version;
  }

  Future<bool> shouldUpdate({bool useCache = true}) async {
    StoreInfo storeInfo = await getStoreInfo(useCache: useCache);
    String runningVersion = await getRunningVersion();

    RegExp versionRegex = RegExp('^(\\d+)\\.(\\d+)\\.(\\d+)');
    Match storeVersionMatch = versionRegex.firstMatch(storeInfo.storeVersion);
    Match runningVersionMatch = versionRegex.firstMatch(runningVersion);

    int majorStoreVersion = int.parse(storeVersionMatch.group(1));
    int majorRunningVersion = int.parse(runningVersionMatch.group(1));
    if (majorStoreVersion > majorRunningVersion) return true;
    if (majorStoreVersion < majorRunningVersion) return false;

    if (_updateOnChangeTo == VersionPart.minor ||
        _updateOnChangeTo == VersionPart.any) {
      int minorStoreVersion = int.parse(storeVersionMatch.group(2));
      int minorRunningVersion = int.parse(runningVersionMatch.group(2));
      if (minorStoreVersion > minorRunningVersion) return true;
      if (minorStoreVersion < minorRunningVersion) return false;
    }

    if (_updateOnChangeTo == VersionPart.any) {
      int patchStoreVersion = int.parse(storeVersionMatch.group(3));
      int patchRunningVersion = int.parse(runningVersionMatch.group(3));
      if (patchStoreVersion > patchRunningVersion) return true;
    }

    return false;
  }
}
