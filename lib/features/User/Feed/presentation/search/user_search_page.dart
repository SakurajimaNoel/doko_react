import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/debounce.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:doko_react/features/User/Profile/widgets/friends/friend_widget.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final UserGraphqlService userGraphqlService =
      UserGraphqlService(client: GraphqlConfig.getGraphQLClient());

  final Debounce searchDebounce = Debounce(
    const Duration(
      milliseconds: 500,
    ),
  );

  late final UserProvider userProvider;

  // when null than there is no search query and if empty than there is query but no result for that query
  List<FriendUserModel>? searchResult;
  bool searching = false;

  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserProvider>();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(
          milliseconds: 1500,
        ),
      ),
    );
  }

  Future<void> searchUser(String query) async {
    setState(() {
      searching = true;
    });
    String userId = userProvider.id;

    SearchResponse searchResponse =
        await userGraphqlService.searchUserByUsernameOrName(userId, query);

    if (searching == false) return;

    setState(() {
      searching = false;
      searchResult = searchResponse.users;
    });

    if (searchResponse.status == ResponseStatus.error) {
      showMessage(Constants.errorMessage);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
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
                            if (value.isEmpty) {
                              setState(() {
                                searchResult = null;
                                searching = false;
                              });
                              searchDebounce.dispose();
                              return;
                            }

                            searchDebounce(() => searchUser(value));
                          },
                          decoration: const InputDecoration(
                            labelText: "Search",
                            hintText: "Search user by username or name.",
                          ),
                        ),
                        if (searching)
                          const LoaderButton()
                        else if (searchResult != null)
                          Icon(
                            Icons.check,
                            color: currScheme.primary,
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: Constants.gap,
              ),
              Flexible(
                child: searchResult == null
                    ? const Center(
                        child:
                            Text("Type to search users by username or name."),
                      )
                    : searchResult!.isEmpty
                        ? const Center(
                            child: Text("No user found with given query"),
                          )
                        : ListView.builder(
                            itemCount: searchResult!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return FriendWidget(
                                friend: searchResult![index],
                                widgetLocation: FriendWidgetLocation.search,
                                key: ObjectKey(searchResult![index]),
                              );
                            },
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
