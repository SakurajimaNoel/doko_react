import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/user-quick-action-widget/user_quick_action_widget.dart';
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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.radius * 10),
        ),
        avatar: UserWidget.avtar(
          userKey: userKey,
        ),
        label: Text(
          "@$user",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
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
        Center(
          child: FilledButton.tonalIcon(
            onPressed: () {
              UserQuickActionWidget.showUserModal(
                context: context,
                onDone: (selected) async {
                  setState(() {
                    usersTagged = selected;
                  });
                  widget.onSelected(selected);
                  return true;
                },
                selected: usersTagged,
                limit: Constants.userTagLimit,
                limitReachedLabel:
                    "You can tag up to ${Constants.userTagLimit} users.",
              );
            },
            icon: const Icon(Icons.person),
            label: const Text("Tag friends"),
          ),
        ),
        createSelectedUserWidget(),
      ],
    );
  }
}
