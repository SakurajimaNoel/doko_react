import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({super.key});

  @override
  State<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  final TextEditingController questionController = TextEditingController();
  final List<PollOptionInput> options =
      List<PollOptionInput>.generate(2, (int index) => PollOptionInput());

  final List<String> info = [
    "You can long press on any option to reorder.",
    "You can add at most ${Constants.pollOptionsLimit} options.",
  ];

  int activeDuration = 1;

  @override
  void dispose() {
    for (var option in options) {
      option.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new poll"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Constants.padding),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Constants.gap * 0.5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Poll active duration:",
                          style: TextStyle(
                            fontSize: Constants.fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownMenu<int>(
                          initialSelection: activeDuration,
                          onSelected: (int? newDuration) {
                            activeDuration = newDuration ?? 1;
                          },
                          dropdownMenuEntries: [
                            ...List<DropdownMenuEntry<int>>.generate(
                                Constants.pollMaxActiveDuration, (int index) {
                              int val = index + 1;
                              return DropdownMenuEntry(
                                value: val,
                                label: "$val day${index > 0 ? "s" : ""}",
                              );
                            })
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: Constants.gap * 0.75,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TextField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "*Question",
                        hintText: "Question...",
                        counterText: "",
                      ),
                      maxLength: Constants.pollQuestionSizeLimit,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(
                      height: Constants.gap * 2.5,
                      thickness: Constants.height * 0.1,
                    ),
                  ),
                  SliverReorderableList(
                    itemBuilder: (BuildContext context, int index) {
                      return Material(
                        key: Key(options[index].key),
                        child: ListTile(
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 0,
                          minVerticalPadding: Constants.gap * 0.625,
                          title: TextField(
                            controller: options[index].controller,
                            onChanged: (String? value) {
                              value ??= "";

                              setState(() {
                                options[index].updateValue(value!);
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Option ${index + 1}",
                              hintText: "Option ${index + 1}...",
                              counterText: "",
                              suffixIcon: options.length > 2
                                  ? IconButton(
                                      onPressed: () {
                                        options[index].controller.dispose();
                                        setState(() {
                                          options.removeAt(index);
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: currTheme.error,
                                      ),
                                    )
                                  : null,
                            ),
                            maxLength: Constants.pollOptionSizeLimit,
                            maxLines: 3,
                            minLines: 1,
                          ),
                          trailing: ReorderableDragStartListener(
                            key: Key(options[index].key),
                            index: index,
                            child: const Icon(Icons.drag_indicator),
                          ),
                        ),
                      );
                    },
                    itemCount: options.length,
                    onReorder: (int prevIndex, int newIndex) {
                      setState(() {
                        if (prevIndex < newIndex) {
                          newIndex -= 1;
                        }
                        var option = options.removeAt(prevIndex);
                        options.insert(newIndex, option);
                      });
                    },
                  ),
                  if (options.length < 5)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Constants.gap,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                options.add(PollOptionInput());
                              });
                            },
                            child: const Text("Add option"),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Constants.padding),
            child: FilledButton(
              onPressed: () {
                final question = questionController.text.trim();
                if (question.isEmpty) {
                  showError("You need to add question to create a Poll.");
                  return;
                }

                List<String> optionValues = [];

                for (var option in options) {
                  if (option.value.isNotEmpty) {
                    optionValues.add(option.value);
                  }
                }

                if (optionValues.length < 2) {
                  showError(
                      "You need to add minimum of 2 options to create a Poll.");
                  return;
                }

                Map<String, dynamic> data = {
                  "pollDetails": PollPublishPageData(
                    question: question,
                    activeFor: activeDuration,
                    options: optionValues,
                  ),
                };

                context.pushNamed(
                  RouterConstants.pollPublish,
                  extra: data,
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  Constants.buttonWidth,
                  Constants.buttonHeight,
                ),
              ),
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
