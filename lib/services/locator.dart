import 'package:get_it/get_it.dart';
import 'package:haste_arcade_flutter/services/http.dart';
import 'package:haste_arcade_flutter/services/local_get_storage.dart';

GetIt locator = GetIt.instance;

initLocator() {
  locator.registerSingleton<HttpService>(HttpService());
  locator.registerSingleton<LocalGetStorage>(LocalGetStorage());
}
