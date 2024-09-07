import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';

enum ProfileStatus { complete, incomplete, loading, error }

class UserProvider extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.loading;
  String _name = "";
  String _username = "";
  String _profilePicture = "";
  String _id = "";

  ProfileStatus get status => _status;

  String get id => _id;

  String get name => _name;

  String get username => _username;

  String get profilePicture => _profilePicture;

  void incompleteUser() {
    _status = ProfileStatus.incomplete;
    notifyListeners();
  }

  void addUser({required UserModel user}) {
    _status = ProfileStatus.complete;
    _name = user.name;
    _username = user.username;
    _profilePicture = user.profilePicture;
    _id = user.id;

    notifyListeners();
  }

  void apiError() {
    _status = ProfileStatus.error;
    notifyListeners();
  }
}
