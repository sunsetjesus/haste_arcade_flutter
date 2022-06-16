import 'package:get_storage/get_storage.dart';

class LocalGetStorage {
  late GetStorage _getStorage;

  Future<void> initGetStorage() async {
    await GetStorage.init();
    _getStorage = GetStorage();
  }

  dynamic get({required String key}) {
    return _getStorage.read(key);
  }

  Future<dynamic> set({required String key, required dynamic val}) async {
    await _getStorage.write(key, val);
  }
}
