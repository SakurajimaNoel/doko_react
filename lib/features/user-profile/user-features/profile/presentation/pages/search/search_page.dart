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
  const SearchPage({super.key});

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
                padding: const EdgeInsets.all(Constants.padding),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: const Icon(Icons.arrow_back_outlined),
                        ),
                        const SizedBox(
                          width: Constants.gap,
                        ),
                        Expanded(
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
                                  hintText: "Search user by username or name.",
                                ),
                              ),
                              if (loading) const SmallLoadingIndicator(),
                              if (!loading && state is! ProfileInitial)
                                Icon(
                                  Icons.check,
                                  color: currTheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: Constants.gap * 2,
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
                              : tempResults.isEmpty
                                  ? Center(
                                      child:
                                          Text("No user found with \"$query\""),
                                    )
                                  : ListView.separated(
                                      itemCount: tempResults.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return FriendWidget(
                                          userKey: tempResults[index],
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const SizedBox(
                                          height: Constants.gap,
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
