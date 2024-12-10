import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/bloc/post_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/widgets/comment/comment_list.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/posts.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final UserGraph graph = UserGraph();
  late final postKey = generatePostNodeKey(widget.postId);
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<PostBloc>()
          ..add(PostLoadEvent(
            details: GetPostInput(
              postId: widget.postId,
              username: username,
            ),
          )),
        child: BlocConsumer<PostBloc, PostState>(
          listenWhen: (previousState, state) {
            return state is LoadErrorState;
          },
          listener: (context, state) {
            if (state is LoadErrorState) showMessage(state.message);
          },
          buildWhen: (previousState, state) {
            return state is PostInitial;
          },
          builder: (context, state) {
            bool loading = state is PostLoadingState;
            bool commentsLoading = state is CommentLoadingState;

            bool postError = state is PostErrorState;
            bool commentError = state is CommentErrorState;

            if (loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (postError) {
              return Center(
                child: StyledText.error(state.message),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Posts(
                          postKey: postKey,
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap * 2,
                        ),
                      ),
                      if (commentError) ...[
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: Constants.height * 5,
                            child: StyledText.error(state.message),
                          ),
                        ),
                      ] else
                        commentsLoading
                            ? SliverToBoxAdapter(
                                child: SizedBox(
                                  height: Constants.height * 5,
                                  child: Center(
                                    child: SmallLoadingIndicator(),
                                  ),
                                ),
                              )
                            : CommentList(
                                postId: widget.postId,
                                key: ValueKey(widget.postId),
                              ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap * 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
