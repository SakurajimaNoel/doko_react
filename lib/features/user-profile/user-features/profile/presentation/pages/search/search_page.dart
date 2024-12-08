import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: Row(
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
                      onChanged: (String value) {},
                      decoration: const InputDecoration(
                        labelText: "Search",
                        hintText: "Search user by username or name.",
                      ),
                    ),
                    // const SmallLoadingIndicator(),
                    Icon(
                      Icons.check,
                      color: currTheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
