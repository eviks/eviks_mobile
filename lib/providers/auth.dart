import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import '../models/user.dart';

enum AuthMode { login, register }

class Auth with ChangeNotifier {
  String _token = '';
  User? _user;

  User? get user {
    return _user;
  }

  bool get isAuth {
    return token != '';
  }

  String get token {
    return _token;
  }

  Future<void> login(String email, String password) async {
    try {
      final url = Uri.parse('http://192.168.1.8:5000/api/auth');
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
          }),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        return;
      }
      final data = (json.decode(response.body) as Map<String, dynamic>)
          .cast<String, String>();
      _token = data['token'] == null ? '' : data['token']!;
      await loadUser();
      print(_token);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> register(String username, String displayName, String email,
      String password) async {
    try {
      final url = Uri.parse('http://192.168.1.8:5000/api/users');
      final response = await http.post(url,
          body: json.encode({
            'username': username,
            'displayName': displayName,
            'email': email,
            'password': password,
            'pinMode': true,
          }),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        return;
      }
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> verifyUser(String activationToken) async {
    try {
      final url = Uri.parse(
          'http://192.168.1.8:5000/api/auth/verification/$activationToken');
      final response =
          await http.post(url, headers: {'Authorization': 'JWT $token'});
      if (response.statusCode != 200) {
        return;
      }
      final data = (json.decode(response.body) as Map<String, dynamic>)
          .cast<String, String>();
      _token = data['token'] == null ? '' : data['token']!;
      await loadUser();
      print(_token);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> loadUser() async {
    try {
      final url = Uri.parse('http://192.168.1.8:5000/api/auth');
      final response =
          await http.get(url, headers: {'Authorization': 'JWT $token'});
      if (response.statusCode != 200) {
        return;
      }
      final dynamic data = json.decode(response.body);
      _user = User.fromJson(data);
      print(_user);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  bool postIsFavorite(int postId) {
    return user?.favorites?.containsKey(postId.toString()) ?? false;
  }
}
