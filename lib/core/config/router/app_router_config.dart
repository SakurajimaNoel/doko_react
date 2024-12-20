import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/error/error_unknown_route.dart';
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
import 'package:doko_react/features/settings/presentation/pages/settings_page.dart';
import 'package:doko_react/features/user-profile/user-features/nearby/nearby_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/post/create_post_page.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/pages/post/post_publish_page.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/pages/post/post_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/edit-profile/edit_profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-friends/pending_request_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile-friends/user_friends_list_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile/profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/profile/user_profile_page.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/pages/search/search_page.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/user_feed_page.dart';
import 'package:doko_react/features/user-profile/user_layout.dart';
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
          return Scaffold(
            appBar: AppBar(
              title: const Text("dokii"),
            ),
            body: const Center(
              child: Text("generic error page"),
            ),
          );
        },
      ),
      GoRoute(
        path: "/error/graph",
        name: RouterConstants.graphError,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("dokii"),
            ),
            body: const Center(
              child: Text("graph error page"),
            ),
          );
        },
      ),
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
      GoRoute(
        path: "/settings",
        name: RouterConstants.settings,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            name: RouterConstants.mfaSetup,
            path: "mfa-setup",
            builder: (context, state) => const SetupMfaPage(),
            routes: [
              GoRoute(
                name: RouterConstants.verifyMfa,
                path: "verify-mfa",
                builder: (context, state) => const VerifyMfaPage(),
              ),
              GoRoute(
                name: RouterConstants.updatePassword,
                path: "change-password",
                builder: (context, state) => const UpdatePasswordPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: RouterConstants.userSearch,
        path: "/search",
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        name: RouterConstants.createPost,
        path: "/create-post",
        builder: (context, state) => const CreatePostPage(),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            name: RouterConstants.postPublish,
            path: "publish",
            builder: (context, state) {
              final Map<String, dynamic> data =
                  state.extra as Map<String, dynamic>;
              final PostPublishPageData postDetails = data["postDetails"];

              return PostPublishPage(
                postDetails: postDetails,
              );
            },
          ),
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
                    name: RouterConstants.editProfile,
                    path: "edit-profile",
                    builder: (context, state) {
                      return const EditProfilePage();
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
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
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.pendingRequests,
                    path: "pending-requests",
                    builder: (context, state) => const PendingRequestPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
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
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.profileFriends,
                        path: "friends",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return UserFriendsListPage(
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
