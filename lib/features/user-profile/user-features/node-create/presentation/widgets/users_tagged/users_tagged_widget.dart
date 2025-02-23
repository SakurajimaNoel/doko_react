import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/get-user-modal/get_user_modal.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';

class UsersTaggedWidget extends StatefulWidget {
  const UsersTaggedWidget({
    super.key,
    required this.onRemove,
    required this.onSelected,
  });

  final ValueSetter<String> onRemove;
  final ValueSetter<List<String>> onSelected;

  @override
  State<UsersTaggedWidget> createState() => _UsersTaggedWidgetState();
}

class _UsersTaggedWidgetState extends State<UsersTaggedWidget> {
  List<String> usersTagged = [];

  Widget createSelectedUserWidget() {
    if (usersTagged.isEmpty) {
      return const SizedBox(
        height: Constants.height * 5,
        child: Center(
          child: Text(
            "No users tagged.",
          ),
        ),
      );
    }

    List<Widget> widgets = [];
    for (String user in usersTagged) {
      String userKey = generateUserNodeKey(user);

      final userWidget = Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.radius * 10),
        ),
        avatar: UserWidget.avtar(
          userKey: userKey,
        ),
        label: UserWidget.name(
          userKey: userKey,
        ),
        onDeleted: () {
          setState(() {
            usersTagged.remove(user);
          });
          widget.onRemove(user);
        },
      );

      widgets.add(userWidget);
    }

    return Wrap(
      spacing: Constants.gap,
      runSpacing: Constants.gap * 0.5,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Constants.gap * 0.5,
      children: [
        FilledButton.tonalIcon(
          onPressed: () {
            GetUserModal.getUserModal(
              context: context,
              onDone: (selected) {
                setState(() {
                  usersTagged = selected;
                });
                widget.onSelected(selected);
              },
              selected: usersTagged,
            );
          },
          icon: const Icon(Icons.person),
          label: const Text("Tag friends"),
        ),
        createSelectedUserWidget(),
      ],
    );
  }
}
