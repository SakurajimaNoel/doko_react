import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompleteProfileInfoPage extends StatefulWidget {
  final String username;

  const CompleteProfileInfoPage({
    super.key,
    required this.username,
  });

  @override
  State<CompleteProfileInfoPage> createState() =>
      _CompleteProfileInfoPageState();
}

class _CompleteProfileInfoPageState extends State<CompleteProfileInfoPage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  static const int _years13 = 4748;
  late final String _username;
  String _name = "";
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;

  DateTime? _date;
  final TextEditingController _dobController =
      TextEditingController(text: "Select date of birth");

  void _next() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    if (_date == null) return;

    context.goNamed(
      RouterConstants.completeProfilePicture,
      pathParameters: {
        "username": _username,
        "name": _name,
        "dob": _date.toString(),
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _usernameController = TextEditingController(
      text: _username,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _dobController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete profile"),
        actions: [
          TextButton(
            onPressed: () {
              auth.signOutUser();
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: currTheme.error,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeading("Profile Information"),
            const Text(
                "Let's get started! Please fill in the information below to complete your profile. We're excited to have you join Doki."),
            const SizedBox(
              height: Constants.gap * 1.5,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        TextFormField(
                          enabled: false,
                          controller: _usernameController,
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
                        const SizedBox(
                          height: Constants.gap * 1.25,
                        ),
                        TextFormField(
                          validator: (value) {
                            var nameStatus = ValidateInput.validateName(value);

                            if (!nameStatus.isValid) {
                              return nameStatus.message;
                            }

                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onSaved: (value) {
                            if (value == null || value.isEmpty) {
                              return;
                            }

                            _name = value.trim();
                          },
                          onChanged: (value) {},
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Name*",
                            hintText: "Name...",
                          ),
                        ),
                        const SizedBox(
                          height: Constants.gap * 1.25,
                        ),
                        GestureDetector(
                          onTap: _selectDate,
                          child: TextFormField(
                            enabled: false,
                            controller: _dobController,
                            validator: (value) {
                              if (_date == null) {
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
                    FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: const Text("Next"),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime currDate = DateTime.now().subtract(const Duration(
      days: _years13,
    ));
    final DateTime selected = await showDatePicker(
          context: context,
          initialDate: currDate,
          firstDate: DateTime(1924),
          lastDate: currDate,
        ) ??
        _date ??
        currDate;

    if (selected != _date) {
      setState(() {
        _date = selected;
        _dobController.text = DisplayText.dateString(selected);
        _formKey.currentState?.validate();
      });
    }
  }
}
