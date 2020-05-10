import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Network {
  final String url = "http://192.168.8.161:8000/api/v1";
  final String todoApiURL = "http://192.168.8.161:8000/api";
  //if you are using android studio emulator, change localhost to 10.0.2.2
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
    // print(token);
  }

  authData(data, apiUrl) async {
    var fullUrl = url + apiUrl;
    return await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiUrl) async {
    var fullUrl = url + apiUrl;
    await _getToken();
    return await http.get(fullUrl, headers: _setHeaders()).catchError((e) {
      print(e);
    });
  }

  getTodoData(apiUrl) async {
    var fullUrl = todoApiURL + apiUrl;
    await _getToken();
    var myResponse = await http.get(fullUrl, headers: _setHeaders());

    return myResponse.body;
  }

  sendSignalTodo(int id, int userId, String adress) async {
    await _getToken();
    await http.post(todoApiURL + adress,
        headers: _setHeaders(),
        body: jsonEncode({'id': '$id', 'userId': '$userId'})).catchError((e) {
      print(e);
      return false;
    });
    return true;
  }

  addTodo(String title, int userId) async {
    await _getToken();
    final fullUrl = todoApiURL + '/add';
    var body = {
      'title': '$title',
      'userId': '$userId'
    };
    await http.post(fullUrl, headers: _setHeaders(), body: jsonEncode(body));
  }

  _setHeaders() =>
      {'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'};
}
