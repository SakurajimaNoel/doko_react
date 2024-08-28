import 'package:flutter/material.dart';

enum ProfileStatus { complete, incomplete, loading }

class UserProvider extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.loading;
  String _name = "";
  String _username = "";
  String _profilePicture = "";

  ProfileStatus get status => _status;

  String get name => _name;

  String get username => _username;

  String get profilePicture => _profilePicture;

  void incompleteUser() {
    _status = ProfileStatus.incomplete;
    notifyListeners();
  }

  void addUser(String name, String username, String profilePicture) {
    _status = ProfileStatus.complete;
    _name = name;
    _username = username;
    _profilePicture = profilePicture;

    notifyListeners();
  }
}
