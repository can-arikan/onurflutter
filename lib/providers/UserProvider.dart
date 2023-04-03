import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "../services/AuthService.dart" as auth;
import "../models/User.dart";

class UserProvider with ChangeNotifier {
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;

  Future<bool> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    _user = await auth.login(username, password);
    _loading = false;
    notifyListeners();
    return _user != null;
  }

  Future<bool> logout() async {
    _user = null;
    _loading = true;
    notifyListeners();
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("refreshToken");
    _loading = false;
    notifyListeners();
    return _user == null;
  }

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> update() async {
    _user = await auth.getUserInfo();
    notifyListeners();
  }
  void likeNFT(){
    _user!.nftLikes += 1;
    notifyListeners();
  }
  void dislikeNFT(){
    _user!.nftLikes -= 1;
    notifyListeners();
  }
}