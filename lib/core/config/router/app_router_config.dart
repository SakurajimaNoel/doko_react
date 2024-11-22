import 'package:doko_react/archive/core/helpers/media_type.dart';
import 'package:doko_react/archive/features/User/CompleteProfile/Presentation/complete_profile_info_page.dart';
import 'package:doko_react/archive/features/User/CompleteProfile/Presentation/complete_profile_picture_page.dart';
import 'package:doko_react/archive/features/User/CompleteProfile/Presentation/complete_profile_username_page.dart';
import 'package:doko_react/archive/features/User/Feed/presentation/search/user_search_page.dart';
import 'package:doko_react/archive/features/User/Feed/presentation/user_feed_page.dart';
import 'package:doko_react/archive/features/User/Nearby/presentation/nearby_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/friends/friends_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/friends/pending_request_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/post/create_post_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/post/create_post_publish_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/post/post_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/profile/edit_profile_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/profile/profile_page.dart';
import 'package:doko_react/archive/features/User/Profile/presentation/profile/user_profile_page.dart';
import 'package:doko_react/archive/features/User/data/model/post_model.dart';
import 'package:doko_react/archive/features/User/data/model/user_model.dart';
import 'package:doko_react/archive/features/User/user_layout.dart';
import 'package:doko_react/archive/features/application/settings/presentation/change_password_page.dart';
import 'package:doko_react/archive/features/application/settings/presentation/mfa_setup_page.dart';
import 'package:doko_react/archive/features/application/settings/presentation/settings_page.dart';
import 'package:doko_react/archive/features/application/settings/presentation/verify_mfa_page.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/error/error_unknown_route.dart';
import 'package:doko_react/features/authentication/presentation/pages/login/confirm_login_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/login/login_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/password/confirm_reset_password_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/password/reset_password_page.dart';
import 'package:doko_react/features/authentication/presentation/pages/sign-up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouterConfig {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _sectionNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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

      if (user is UserLoading) return onLoading ? null : loading;

      if (user is UserAuthError) return onAuthError ? null : authError;

      if (user is UserGraphError) return onGraphError ? null : graphError;

      if (user is UserUnauthenticated) return onAuthPages ? null : authRoute;

      if (user is UserIncomplete) {
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
      // loading
      GoRoute(
        path: "/loading",
        name: RouterConstants.loading,
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
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
        // parentNavigatorKey: _rootNavigatorKey,
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
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.userSearch,
                    path: "search",
                    builder: (context, state) => const UserSearchPage(),
                  )
                ],
              ),
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
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.userPost,
                    path: "post/:postId",
                    builder: (context, state) {
                      Map<String, dynamic>? data;
                      if (state.extra != null) {
                        data = state.extra as Map<String, dynamic>;
                      }

                      final PostModel? post = data?["post"];
                      String postId = state.pathParameters["postId"]!;

                      return PostPage(
                        postId: postId,
                        post: post,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.pendingRequests,
                    path: "pending-requests",
                    builder: (context, state) => const PendingRequestPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.createPost,
                    path: "create-post",
                    builder: (context, state) => const CreatePostPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.postPublish,
                        path: "publish",
                        builder: (context, state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          final List<PostContent> postContent =
                              data["postContent"];
                          final String postId = data["postId"];

                          return CreatePostPublishPage(
                            postContent: postContent,
                            postId: postId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.settings,
                    path: "settings",
                    builder: (context, state) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.mfaSetup,
                        path: "mfa-setup",
                        builder: (context, state) => const MfaSetupPage(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigatorKey,
                            name: RouterConstants.verifyMfa,
                            path: "verify-mfa",
                            builder: (context, state) => const VerifyMfaPage(),
                          ),
                        ],
                      ),
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.changePassword,
                        path: "change-password",
                        builder: (context, state) => const ChangePasswordPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.editProfile,
                    path: "edit-profile",
                    builder: (context, state) {
                      final Map<String, dynamic> data =
                          state.extra as Map<String, dynamic>;
                      final CompleteUserModel user = data["user"];

                      return EditProfilePage(
                        user: user,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.userProfile,
                    path: "user/:username",
                    builder: (context, state) {
                      String username = state.pathParameters["username"]!;
                      return UserProfilePage(username: username);
                    },
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.profileFriends,
                        path: "friends",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return FriendsPage(
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
