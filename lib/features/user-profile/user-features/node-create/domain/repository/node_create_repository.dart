import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';

abstract class NodeCreateRepository {
  Future<bool> createNewPost(PostCreateInput postDetails);
}
