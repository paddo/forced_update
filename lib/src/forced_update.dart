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
    if (storeInfo.storeVersion.startsWith(runningVersion)) return false;

    if (_updateOnChangeTo == VersionPart.any) return true;

    RegExp storeVersionRegex =
        RegExp(_updateOnChangeTo == VersionPart.major ? '^\d+\.' : '^\d+\.\d+');

    if (!storeVersionRegex.hasMatch(runningVersion)) return true;

    return false;
  }
}