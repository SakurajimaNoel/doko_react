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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new poll"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(Constants.padding),
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Constants.gap,
                      children: [
                        Wrap(
                          spacing: Constants.gap,
                          children: [
                            const Text("Poll active duration: "),
                            DropdownMenu<int>(
                              initialSelection: activeDuration,
                              onSelected: (int? newDuration) {
                                activeDuration = newDuration ?? 1;
                              },
                              dropdownMenuEntries: [
                                ...List<DropdownMenuEntry<int>>.generate(
                                    Constants.pollMaxActiveDuration,
                                    (int index) {
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
                        TextField(
                          controller: questionController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "*Question",
                            hintText: "Question...",
                          ),
                        ),
                        ReorderableListView(
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < options.length; i++)
                              ListTile(
                                key: Key(options[i].key),
                                title: TextField(
                                  onChanged: (String? value) {
                                    value ??= "";

                                    setState(() {
                                      options[i].updateValue(value!);
                                    });
                                  },
                                  onTapOutside: (_) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Option ${i + 1}",
                                    hintText: "Option ${i + 1}...",
                                  ),
                                ),
                                leading: options.length > 2
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            options.removeAt(i);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      )
                                    : null,
                                trailing: ReorderableDragStartListener(
                                  key: Key(options[i].key),
                                  index: i,
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ),
                          ],
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
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                options.add(PollOptionInput());
                              });
                            },
                            child: const Text("Add option"),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Constants.padding),
            child: FilledButton(
              onPressed: () {
                final question = questionController.text.trim();
                if (question.isEmpty) {
                  showError("required question missing");
                  return;
                }

                List<String> optionValues = [];

                for (var option in options) {
                  if (option.value.isNotEmpty) {
                    optionValues.add(option.value);
                  }
                }

                if (optionValues.length < 2) {
                  showError("required minimum of 2 options");
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
