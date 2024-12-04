import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController bioController;

  late final CompleteUserEntity user;

  @override
  void initState() {
    super.initState();

    String username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    UserGraph graph = UserGraph();
    String key = generateUserNodeKey(username);

    user = graph.getValueByKey(key)! as CompleteUserEntity;

    nameController = TextEditingController(
      text: user.name,
    );
    bioController = TextEditingController(
      text: user.bio,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit profile"),
        actions: [
          TextButton(
            onPressed: () {},
            child: true
                ? const SmallLoadingIndicator.appBar()
                : const Text("Save"),
          ),
        ],
      ),
      body: ElevatedButton(
        onPressed: () {
          String key = generateUserNodeKey(user.username);
          UserGraph graph = UserGraph();
          CompleteUserEntity compUser =
              graph.getValueByKey(key)! as CompleteUserEntity;

          compUser.name = "trial";
          compUser.bio = "okii working";
          graph.addEntity(key, compUser);
          context.read<UserActionBloc>().add(TrialEvent());
        },
        child: const Text("trial"),
      ),
    );
  }
}
