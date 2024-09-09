import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/widgets/error_text.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';

import '../../../core/data/storage.dart';
import '../../../core/helpers/enum.dart';

class ProfileWidget extends StatefulWidget {
  final CompleteUserModel? user;
  final bool self;
  final Future<void> Function() refreshUser;

  const ProfileWidget({
    super.key,
    required this.user,
    this.self = false,
    required this.refreshUser,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late final CompleteUserModel? _user;
  late final bool _self;
  late final Future<void> Function() _refreshUser;
  String _profile = "";

  @override
  void initState() {
    super.initState();

    _user = widget.user;
    _self = widget.self;
    _refreshUser = widget.refreshUser;

    _getProfile();
  }

  Future<void> _getProfile() async {
    if (_user == null) return;

    String path = _user.profilePicture;
    if (path.isEmpty) return;

    var result = await StorageActions.getDownloadUrl(path);

    if (result.status == ResponseStatus.success) {
      if (mounted) {
        setState(() {
          _profile = result.value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _user == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ErrorText(
                  "Oops! Something went wrong.",
                  fontSize: Constants.fontSize,
                ),
                const SizedBox(
                  height: Constants.gap * 0.5,
                ),
                ElevatedButton(
                  onPressed: _refreshUser,
                  child: const Text("Refresh"),
                ),
              ],
            ),
          )
        : ListView(
            children: [
              _profile.isEmpty
                  ? const Text("loading")
                  : Image(
                      image: NetworkImage(_profile),
                      height: Constants.appBarHeight + 300,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
              Container(
                height: 320,
                color: Colors.pinkAccent,
              ),
              Container(
                height: 320,
                color: Colors.pinkAccent,
              ),
              Container(
                height: 320,
                color: Colors.pinkAccent,
              ),
              Container(
                height: 320,
                color: Colors.pinkAccent,
              ),
            ],
          );
  }
}
