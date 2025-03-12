import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPostsListPage extends StatefulWidget {
  const UserPostsListPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<UserPostsListPage> createState() => _UserPostsListPageState();
}

class _UserPostsListPageState extends State<UserPostsListPage> {
  late final String username;
  late final String currentUsername;
  late final bool self;

  late final String graphKey;
  final graph = UserGraph();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    username = widget.username;
    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;

    self = username == currentUsername;
    graphKey = generateUserNodeKey(username);
  }

  Widget buildPostItems(BuildContext context, int index) {
    final user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
    final Nodes userPost = user.posts;

    if (index >= userPost.items.length) {
      /// fetch more posts if exits
      if (!userPost.pageInfo.hasNextPage) {
        return const SizedBox.shrink();
      }

      // fetch more post
      if (!loading) {
        loading = true;
        context.read<ProfileBloc>().add(GetUserPostsEvent(
              userDetails: UserProfileNodesInput(
                username: username,
                cursor: userPost.pageInfo.endCursor!,
                currentUsername: currentUsername,
              ),
            ));
      }

      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    // show user post
    return CompactBox(
      child: PostWidget(
        postKey: userPost.items[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProfileNodesInput details = UserProfileNodesInput(
      username: username,
      currentUsername: currentUsername,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("$username posts"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<ProfileBloc>()
          ..add(GetUserPostsEvent(
            userDetails: details,
          )),
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: Constants.padding,
          ),
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (previousState, state) {
              return state is ProfileNodeLoadResponse;
            },
            listener: (context, state) {
              loading = false;

              if (state is ProfileNodeLoadError) {
                showError(state.message);
                return;
              }

              // handle posts load success
              final user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
              final Nodes userPosts = user.posts;

              context
                  .read<UserToUserActionBloc>()
                  .add(UserToUserActionNodesLoadEvent(
                    itemCount: userPosts.items.length,
                    username: username,
                    nodeType: DokiNodeType.post,
                  ));
            },
            buildWhen: (previousState, state) {
              return state is! ProfileNodeLoadResponse;
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is ProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StyledText.error(state.message),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(GetUserPostsEvent(
                                userDetails: details,
                              ));
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              return PullToRefresh(
                onRefresh: () async {
                  Future profileBloc = context.read<ProfileBloc>().stream.first;

                  context.read<ProfileBloc>().add(GetUserPostsRefreshEvent(
                        userDetails: details,
                      ));

                  final ProfileState state = await profileBloc;
                  if (state is ProfileRefreshError) {
                    showError(state.message);
                  }
                },
                child: BlocBuilder<UserActionBloc, UserActionState>(
                  buildWhen: (previousState, state) {
                    return (state is UserActionNewPostState &&
                        state.username == username);
                  },
                  builder: (context, userActionState) {
                    return BlocBuilder<UserToUserActionBloc,
                        UserToUserActionState>(
                      buildWhen: (previousState, state) {
                        return (state is UserToUserActionLoadNodesState &&
                            state.username == username &&
                            state.nodeType == DokiNodeType.post);
                      },
                      builder: (context, state) {
                        final user = graph.getValueByKey(graphKey)!
                            as CompleteUserEntity;
                        final Nodes userPosts = user.posts;

                        if (userPosts.items.isEmpty) {
                          return CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                child: Center(
                                  child: Text(
                                    "${user.name} has not uploaded any posts.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }

                        return ListView.separated(
                          itemCount: userPosts.items.length + 1,
                          itemBuilder: buildPostItems,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: Constants.gap * 1.75,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
