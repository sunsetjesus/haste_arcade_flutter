import 'dart:convert';
import 'package:haste_arcade_flutter/consts/app_error.dart';
import 'package:http/http.dart' as http;

class HttpService {
  Future<dynamic> post(
      {required String uri,
      required Map<String, dynamic> jsonBody,
      required Map<String, String> headers}) async {
    Map<String, dynamic>? returnVal;
    try {
      var url = Uri.parse(uri);

      var response =
          await http.post(url, headers: headers, body: jsonEncode(jsonBody));
      var responseJson = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        returnVal = {"error": false, "data": responseJson};
      } else {
        returnVal = {
          "error": true,
          "code": responseJson["code"],
          "message": responseJson["message"]
        };
      }
    } catch (e) {
      returnVal = {
        "error": true,
        "code": AppError.undefined.code,
        "message": AppError.undefined.message
      };
    } finally {
      return returnVal;
    }
  }

  Future<dynamic> get(
      {required String uri, required Map<String, String> headers}) async {
    Map<String, dynamic>? returnVal;
    try {
      var url = Uri.parse(uri);

      var response = await http.get(url, headers: headers);
      var resJSON = jsonDecode(response.body);
      if (resJSON['error']) {
        returnVal = {
          "error": true,
          "code": AppError.undefined.code,
          "message": AppError.undefined.message
        };
      } else {
        returnVal = resJSON;
      }
    } catch (e) {
      returnVal = {
        "error": true,
        "code": AppError.undefined.code,
        "message": AppError.undefined.message
      };
    } finally {
      return returnVal;
    }
  }
}
