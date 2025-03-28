import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/media/image-filter/image_filter_page.dart';
import 'package:doko_react/core/utils/page/token_page.dart';
import 'package:doko_react/core/widgets/error/error_unknown_route.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/features/authentication/presentation/pages/login/confirm_login_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/login/login_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/mfa/setup_mfa_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/mfa/verify_mfa_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/password/confirm_reset_password_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/password/reset_password_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/password/update_password_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/sign-up/sign_up_page.dart';
import 'package:doko_react/features/complete-profile/presentation/pages/info/complete_profile_info_page.dart';
import 'package:doko_react/features/complete-profile/presentation/pages/profile-picture/complete_profile_picture_page.dart';
import 'package:doko_react/features/complete-profile/presentation/pages/username/complete_profile_username_page.dart';
import 'package:doko_react/features/error-pages/auth_error_page.dart';
import 'package:doko_react/features/error-pages/graph_error_page.dart';
import 'package:doko_react/features/settings/presentation/pages/settings_page.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/pages/message-archive-profile/message_archive_profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/pages/message-archive/message_archive_page.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/pages/message-inbox/message_inbox_page.dart';
import 'package:doko_react/features/user-profile/user-features/media-carousel-page/media_carousel_page.dart';
import 'package:doko_react/features/user-profile/user-features/nearby/nearby_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/discussion/create_discussion_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/discussion/discussion_publish_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/poll/create_poll_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/poll/poll_publish_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/post/create_post_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/post/post_publish_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/edit-profile/edit_profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-discussions/user_discussion_list_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-friends/pending_request_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-friends/user_friends_list_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-pages/user_pages_list_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-polls/user_polls_list_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-posts/user_posts_list_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile/profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile/user_profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/search/search_page.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/pages/comment/comment_page.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/pages/discussion/discussion_page.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/pages/poll/poll_page.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/pages/post/post_page.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/presentation/pages/user_feed_page.dart';
import 'package:doko_react/features/user-profile/user_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class AppRouterConfig {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _sectionNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    observers: [routeObserver],
    navigatorKey: rootNavigatorKey,
    initialLocation: "/loading",
    redirect: (BuildContext context, GoRouterState state) {
      String current = state.uri.toString();

      String authRoute = "/auth/login";
      String home = "/";
      String completeProfile = "/complete-profile-username";
      String loading = "/loading";
      String authError = "/error";
      String graphError = "/error/graph";

      bool onAuthPages = current.startsWith("/auth");
      bool onProfileCompletePages = current.startsWith("/complete");
      bool onLoading = current == "/loading";
      bool onAuthError = current == "/error";
      bool onGraphError = current == "/error/graph";

      final UserState user = context.read<UserBloc>().state;

      if (user is UserLoadingState) return onLoading ? null : loading;

      if (user is UserAuthErrorState) return onAuthError ? null : authError;

      if (user is UserGraphErrorState) return onGraphError ? null : graphError;

      if (user is UserUnauthenticatedState) {
        return onAuthPages ? null : authRoute;
      }

      if (user is UserIncompleteState) {
        return onProfileCompletePages ? null : completeProfile;
      }

      if (onLoading ||
          onAuthError ||
          onGraphError ||
          onAuthPages ||
          onProfileCompletePages) {
        return home;
      }

      return null;
    },
    errorBuilder: (BuildContext context, GoRouterState state) {
      return const ErrorUnknownRoute();
    },
    routes: [
      GoRoute(
        path: "/error",
        name: RouterConstants.error,
        builder: (context, state) {
          return const AuthErrorPage();
        },
      ),
      GoRoute(
        path: "/error/graph",
        name: RouterConstants.graphError,
        builder: (context, state) {
          return const GraphErrorPage();
        },
      ),
      // loading
      GoRoute(
        path: "/loading",
        name: RouterConstants.loading,
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: LoadingWidget(),
            ),
          );
        },
      ),
      // auth routes
      GoRoute(
        name: RouterConstants.login,
        path: "/auth/login",
        builder: (context, state) {
          return const LoginPage();
        },
        routes: [
          GoRoute(
            name: RouterConstants.confirmLogin,
            path: "mfa",
            builder: (context, state) {
              return const ConfirmLoginPage();
            },
          ),
        ],
      ),
      GoRoute(
        name: RouterConstants.signUp,
        path: "/auth/sign-up",
        builder: (context, state) {
          return const SignUpPage();
        },
      ),
      GoRoute(
        name: RouterConstants.passwordReset,
        path: "/auth/password-reset",
        builder: (context, state) {
          return const ResetPasswordPage();
        },
        routes: [
          GoRoute(
            name: RouterConstants.confirmPasswordReset,
            path: "password-reset-confirm/:email",
            builder: (context, state) {
              final emailValue = state.pathParameters["email"]!;
              return ConfirmResetPasswordPage(
                email: emailValue,
              );
            },
          ),
        ],
      ),
      // add filter to image
      GoRoute(
        name: RouterConstants.imageFilter,
        path: "/add-image-filter/:image",
        builder: (context, state) {
          final image = state.pathParameters["image"]!;

          return ImageFilterPage(
            image: image,
          );
        },
      ),
      // incomplete-profile routes
      GoRoute(
        name: RouterConstants.completeProfileUsername,
        path: "/complete-profile-username",
        builder: (context, state) => const CompleteProfileUsernamePage(),
        routes: [
          GoRoute(
            name: RouterConstants.completeProfileInfo,
            path: "complete-profile-info/:username",
            builder: (context, state) {
              final usernameValue = state.pathParameters["username"]!;
              return CompleteProfileInfoPage(
                username: usernameValue,
              );
            },
            routes: [
              GoRoute(
                name: RouterConstants.completeProfilePicture,
                path: "complete-profile-picture/:name/:dob",
                builder: (context, state) {
                  final usernameValue = state.pathParameters["username"]!;
                  final nameValue = state.pathParameters["name"]!;
                  final dobValue = state.pathParameters["dob"]!;

                  return CompleteProfilePicturePage(
                    username: usernameValue,
                    name: nameValue,
                    dob: dobValue,
                  );
                },
              )
            ],
          )
        ],
      ),
      // complete profile routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return UserLayout(navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _sectionNavigatorKey,
            routes: [
              GoRoute(
                  name: RouterConstants.userFeed,
                  path: "/",
                  builder: (context, state) => const UserFeedPage(),
                  routes: [
                    GoRoute(
                      parentNavigatorKey: rootNavigatorKey,
                      name: RouterConstants.userSearch,
                      path: "search",
                      builder: (context, state) => const SearchPage(),
                    ),
                  ]),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouterConstants.nearby,
                path: "/nearby",
                builder: (context, state) => const NearbyPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouterConstants.profile,
                path: "/profile",
                builder: (context, state) {
                  return const ProfilePage();
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: "message-inbox",
                    name: RouterConstants.messageInbox,
                    builder: (context, state) => const MessageInboxPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        path: "search",
                        name: RouterConstants.messageInboxSearch,
                        builder: (context, state) {
                          return const SearchPage.message();
                        },
                      ),
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        path: "message-archive/:username",
                        name: RouterConstants.messageArchive,
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;

                          return MessageArchivePage(
                            username: username,
                          );
                        },
                        routes: [
                          GoRoute(
                            parentNavigatorKey: rootNavigatorKey,
                            path: "message-archive-profile",
                            name: RouterConstants.messageArchiveProfile,
                            builder: (context, state) {
                              String username =
                                  state.pathParameters["username"]!;

                              return MessageArchiveProfilePage(
                                username: username,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: "settings",
                    name: RouterConstants.settings,
                    builder: (context, state) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.mfaSetup,
                        path: "mfa-setup",
                        builder: (context, state) => const SetupMfaPage(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: rootNavigatorKey,
                            name: RouterConstants.verifyMfa,
                            path: "verify-mfa",
                            builder: (context, state) => const VerifyMfaPage(),
                          ),
                          GoRoute(
                            parentNavigatorKey: rootNavigatorKey,
                            name: RouterConstants.updatePassword,
                            path: "change-password",
                            builder: (context, state) =>
                                const UpdatePasswordPage(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.token,
                    path: "tokens",
                    builder: (context, state) => const TokenPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.createPost,
                    path: "/create-post",
                    builder: (context, state) => const CreatePostPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.postPublish,
                        path: "publish",
                        builder: (context, state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          final PostPublishPageData postDetails =
                              data["postDetails"];

                          return PostPublishPage(
                            postDetails: postDetails,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.createDiscussion,
                    path: "/create-discussion",
                    builder: (context, state) => const CreateDiscussionPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.discussionPublish,
                        path: "publish",
                        builder: (context, state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          final DiscussionPublishPageData discussionDetails =
                              data["discussionDetails"];

                          return DiscussionPublishPage(
                            discussionDetails: discussionDetails,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.createPoll,
                    path: "/create-poll",
                    builder: (context, state) => const CreatePollPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.pollPublish,
                        path: "publish",
                        builder: (context, state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          final PollPublishPageData pollDetails =
                              data["pollDetails"];

                          return PollPublishPage(
                            pollDetails: pollDetails,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.editProfile,
                    path: "edit-profile",
                    builder: (context, state) {
                      return const EditProfilePage();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.userPost,
                    path: "post/:postId",
                    builder: (context, state) {
                      String postId = state.pathParameters["postId"]!;

                      return PostPage(
                        postId: postId,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.userDiscussion,
                    path: "discussion/:discussionId",
                    builder: (context, state) {
                      String discussionId =
                          state.pathParameters["discussionId"]!;

                      return DiscussionPage(
                        discussionId: discussionId,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.userPoll,
                    path: "poll/:pollId",
                    builder: (context, state) {
                      String pollId = state.pathParameters["pollId"]!;

                      return PollPage(
                        pollId: pollId,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.mediaCarousel,
                    path: "media/:nodeKey",
                    builder: (context, state) {
                      String nodeKey = state.pathParameters["nodeKey"]!;
                      return MediaCarouselPage(
                        nodeKey: nodeKey,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.comment,
                    path:
                        "user/:userId/:rootNodeType/:rootNodeId/:parentNodeType/:parentNodeId/comment/:commentId",
                    builder: (context, state) {
                      String rootNodeName =
                          state.pathParameters["rootNodeType"]!;
                      String rootNodeId = state.pathParameters["rootNodeId"]!;
                      String parentNodeName =
                          state.pathParameters["parentNodeType"]!;
                      String parentNodeId =
                          state.pathParameters["parentNodeId"]!;
                      String commentId = state.pathParameters["commentId"]!;
                      String userId = state.pathParameters["userId"]!;

                      return CommentPage(
                        commentId: commentId,
                        rootNodeId: rootNodeId,
                        rootNodeType: DokiNodeType.fromName(rootNodeName),
                        rootNodeBy: userId,
                        parentNodeId: parentNodeId,
                        parentNodeType: DokiNodeType.fromName(parentNodeName),
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.pendingRequests,
                    path: "pending-requests",
                    builder: (context, state) => const PendingRequestPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    name: RouterConstants.userProfile,
                    path: "user/:username",
                    builder: (context, state) {
                      String username = state.pathParameters["username"]!;
                      return UserProfilePage(
                        username: username,
                      );
                    },
                    routes: [
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.profileFriends,
                        path: "friends",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return UserFriendsListPage(
                            username: username,
                          );
                        },
                      ),
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.profilePages,
                        path: "pages",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return UserPagesListPage(
                            username: username,
                          );
                        },
                      ),
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.profilePosts,
                        path: "posts",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return UserPostsListPage(
                            username: username,
                          );
                        },
                      ),
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.profileDiscussions,
                        path: "discussions",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return UserDiscussionListPage(
                            username: username,
                          );
                        },
                      ),
                      GoRoute(
                        parentNavigatorKey: rootNavigatorKey,
                        name: RouterConstants.profilePolls,
                        path: "polls",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return UserPollsListPage(
                            username: username,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
