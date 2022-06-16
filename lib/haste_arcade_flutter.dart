library haste_arcade_flutter;

import 'package:haste_arcade_flutter/consts/haste_configs.dart';
import 'package:haste_arcade_flutter/services/http.dart';
import 'package:haste_arcade_flutter/services/local_get_storage.dart';
import 'package:haste_arcade_flutter/services/locator.dart';
import 'package:nonce/nonce.dart';
import 'package:url_launcher/url_launcher.dart';

class HasteArcadeFlutter {
  late final HttpService _httpService;
  late final LocalGetStorage _localGetStorage;

  HasteArcadeFlutter() {
    initLocator();
  }

  Future<dynamic> init(
      {required String clientId, required String clientSecret}) async {
    _httpService = locator.get<HttpService>();
    _localGetStorage = locator.get<LocalGetStorage>();

    await _localGetStorage.initGetStorage();

    Map<String, String> body = {
      "clientId": clientId,
      "clientSecret": clientSecret,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var response = await _httpService.post(
        uri: "$apiServerUri/oauth/writetoken",
        jsonBody: body,
        headers: headers);
    if (!response['error']) {
      await _localGetStorage.set(
          key: "accessTokenArcadeApi", val: response['data']['access_token']);
      await _localGetStorage.set(
          key: "developerId", val: response['data']['developerId']);
      await _localGetStorage.set(
          key: "gameId", val: response['data']['gameId']);
      await _localGetStorage.set(
          key: "arcadeId", val: response['data']['arcadeId']);
    }

    return response;
  }

  Future<void> doSignIn() async {
    Map<String, String> body = {
      "description": Nonce.generate(),
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var response = await _httpService.post(
        uri: "$authServerUri/cli", jsonBody: body, headers: headers);
    if (!response['error']) {
      await _localGetStorage.set(
          key: "browserUrl", val: response['data']['browserUrl']);
      await _localGetStorage.set(
          key: "requestorId", val: response['data']['requestorId']);
      final Uri url = Uri.parse(response['data']['browserUrl']);
      if (!await launchUrl(url)) throw 'Could not launch $url';
    }
  }

  Future<dynamic> getLeaderboards() async {
    String accessTokenArcadeApi =
        _localGetStorage.get(key: "accessTokenArcadeApi");
    String arcadeId = _localGetStorage.get(key: "arcadeId");
    String gameId = _localGetStorage.get(key: "gameId");

    Map<String, String> body = {
      "arcadeId": arcadeId,
      "gameId": gameId,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessTokenArcadeApi',
    };
    var response = await _httpService.post(
        uri: "$apiServerUri/arcades/$arcadeId/developergames/$gameId",
        jsonBody: body,
        headers: headers);
    if (!response['error']) {
      await _localGetStorage.set(
          key: "playerId", val: response['data']['playerId']);
    }

    return response;
  }

  Future<dynamic> initPlay({required String leaderboardId}) async {
    String arcadeId = _localGetStorage.get(key: "arcadeId");
    String gameId = _localGetStorage.get(key: "gameId");
    String playerId = _localGetStorage.get(key: "playerId");
    String accessTokenArcadeApi =
        _localGetStorage.get(key: "accessTokenArcadeApi");
    Map<String, String> body = {
      "playerId": playerId,
      "leaderboardId": leaderboardId,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessTokenArcadeApi',
    };
    var response = await _httpService.post(
        uri: "$apiServerUri/arcades/$arcadeId/games/$gameId/play",
        jsonBody: body,
        headers: headers);
    if (!response['error']) {
      await _localGetStorage.set(key: "playId", val: response['data']['id']);
      await _localGetStorage.set(
          key: "activeLeaderboardId", val: leaderboardId);
    }
    return response;
  }

  Future<dynamic> submitScore({required int score}) async {
    String arcadeId = _localGetStorage.get(key: "arcadeId");
    String gameId = _localGetStorage.get(key: "gameId");
    String playId = _localGetStorage.get(key: "playId");
    String leaderboardId = _localGetStorage.get(key: "activeLeaderboardId");
    String accessTokenArcadeApi =
        _localGetStorage.get(key: "accessTokenArcadeApi");
    Map<String, String> body = {
      "score": score.toString(),
      "playId": playId,
      "leaderboardId": leaderboardId,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessTokenArcadeApi',
    };
    var response = await _httpService.post(
        uri: "$apiServerUri/arcades/$arcadeId/games/$gameId/score",
        jsonBody: body,
        headers: headers);
    return response;
  }

  Future<void> getLeaders({required String leaderboardId}) async {
    String arcadeId = _localGetStorage.get(key: "arcadeId");
    String gameId = _localGetStorage.get(key: "gameId");
    String accessTokenArcadeApi =
        _localGetStorage.get(key: "accessTokenArcadeApi");
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessTokenArcadeApi',
    };
    var response = await _httpService.get(
        uri:
            "$apiServerUri/arcades/$arcadeId/games/$gameId/leaders/$leaderboardId",
        headers: headers);
    if (!response['error']) {
      await _localGetStorage.set(
          key: "browserUrl", val: response['data']['browserUrl']);
      await _localGetStorage.set(
          key: "requestorId", val: response['data']['requestorId']);
      final Uri url = Uri.parse(response['data']['browserUrl']);
      if (!await launchUrl(url)) throw 'Could not launch $url';
    }
  }
}
