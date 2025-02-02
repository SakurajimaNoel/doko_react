import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/sign-out-button/sign_out_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompleteProfileInfoPage extends StatefulWidget {
  const CompleteProfileInfoPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<CompleteProfileInfoPage> createState() =>
      _CompleteProfileInfoPageState();
}

class _CompleteProfileInfoPageState extends State<CompleteProfileInfoPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController usernameController;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController =
      TextEditingController(text: "Select date of birth");

  final int years13ToDays = 4748;
  DateTime? date;

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);
  }

  void handleProfileInfo() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || date == null) {
      return;
    }

    context.pushNamed(
      RouterConstants.completeProfilePicture,
      pathParameters: {
        "username": widget.username,
        "name": nameController.text.trim(),
        "dob": date.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Information"),
        actions: const [
          SignOutButton(),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(Constants.padding),
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Heading.left(
                        "Profile Information",
                        size: Constants.largeFontSize,
                      ),
                      const Text(
                          "Let's get started! Please fill in the information below to complete your profile. We're excited to have you join Doki."),
                      const SizedBox(
                        height: Constants.gap * 1.5,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          spacing: Constants.gap * 1.25,
                          children: [
                            TextFormField(
                              enabled: false,
                              controller: usernameController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Username*",
                                hintText: "Username...",
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: currTheme.outline,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: currTheme.onSurface,
                                ),
                              ),
                              style: TextStyle(
                                color: currTheme.onSurface,
                              ),
                            ),
                            TextFormField(
                              controller: nameController,
                              validator: (value) {
                                return value == null || value.isEmpty
                                    ? "Name can't be empty."
                                    : null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (value) {},
                              maxLength: Constants.nameLimit,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Name*",
                                hintText: "Name...",
                              ),
                            ),
                            GestureDetector(
                              onTap: selectDate,
                              child: TextFormField(
                                enabled: false,
                                controller: dobController,
                                validator: (value) {
                                  if (date == null) {
                                    return "Date of Birth is required.";
                                  }

                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: "Date of Birth*",
                                  hintText: "DOB...",
                                  suffixIcon: Icon(
                                    Icons.calendar_month,
                                    color: currTheme.onSurface,
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: currTheme.outline,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    color: currTheme.onSurface,
                                  ),
                                ),
                                style: TextStyle(
                                  color: currTheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(Constants.padding),
            child: FilledButton(
              onPressed: handleProfileInfo,
              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  Constants.buttonWidth,
                  Constants.buttonHeight,
                ),
              ),
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectDate() async {
    DateTime limDate = DateTime.now().subtract(Duration(
      days: years13ToDays,
    ));

    final DateTime selected = await showDatePicker(
          context: context,
          initialDate: limDate,
          firstDate: DateTime(1924),
          lastDate: limDate,
        ) ??
        date ??
        limDate;

    if (selected != date) {
      setState(() {
        date = selected;
        dobController.text = dateString(selected);
        formKey.currentState?.validate();
      });
    }
  }
}
