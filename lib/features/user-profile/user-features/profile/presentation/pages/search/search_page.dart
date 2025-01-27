import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/friend_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
  }) : inbox = false;

  const SearchPage.message({
    super.key,
  }) : inbox = true;

  final bool inbox;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    String query = "";
    List<String> tempResults = [];

    return Scaffold(
      body: BlocProvider(
        create: (context) => serviceLocator<ProfileBloc>(),
        child: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              bool loading = state is ProfileUserSearchLoadingState;
              bool error = state is ProfileUserSearchErrorState;
              bool searchResult = state is ProfileUserSearchSuccessState;
              if (searchResult) {
                tempResults = state.searchResults;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Constants.padding,
                ),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      spacing: Constants.gap,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Constants.padding,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: const Icon(Icons.arrow_back_outlined),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: Constants.padding,
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                TextField(
                                  onChanged: (String value) {
                                    UserSearchInput searchDetails =
                                        UserSearchInput(
                                      username: username,
                                      query: value,
                                    );

                                    query = value;

                                    context
                                        .read<ProfileBloc>()
                                        .add(UserSearchEvent(
                                          searchDetails: searchDetails,
                                        ));
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Search",
                                    hintText:
                                        "Search user by username or name.",
                                  ),
                                ),
                                if (loading) const SmallLoadingIndicator(),
                                if (!loading && state is! ProfileInitial)
                                  Icon(
                                    Icons.check,
                                    color: currTheme.primary,
                                  ),
                                if (error)
                                  Icon(
                                    Icons.error_outline,
                                    color: currTheme.error,
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: Constants.gap * 1.5,
                    ),
                    Flexible(
                      child: error
                          ? Center(
                              child: StyledText.error(state.message),
                            )
                          : state is ProfileInitial
                              ? const Center(
                                  child: Text(
                                      "Type to search users by username or name."),
                                )
                              : (tempResults.isEmpty && !loading)
                                  ? Center(
                                      child:
                                          Text("No user found with \"$query\""),
                                    )
                                  : ListView.separated(
                                      itemCount: tempResults.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (inbox) {
                                          return FriendWidget.message(
                                            userKey: tempResults[index],
                                          );
                                        }

                                        return FriendWidget(
                                          userKey: tempResults[index],
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const SizedBox(
                                          height: Constants.gap * 0.5,
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
