import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/media/giphy/giphy_uri.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giphy_get/giphy_get.dart';

class GifPicker extends StatelessWidget {
  const GifPicker({
    super.key,
    required this.handleSelection,
    required this.disabled,
  });

  final ValueSetter<String> handleSelection;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: disabled
          ? null
          : () async {
              GiphyGif? gif = await GiphyGet.getGif(
                context: context,
                apiKey: dotenv.env["GIPHY_API_KEY"]!,
                randomID: (context.read<UserBloc>().state as UserCompleteState)
                    .username,
                tabColor: currTheme.primary,
                debounceTimeInMilliseconds: 500,
              );

              String? uri = getValidGiphyURI(gif);
              if (uri == null || uri.isEmpty) {
                return;
              }

              handleSelection(uri);
            },
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.all(Constants.padding * 0.5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        Icons.gif_box_outlined,
        color: currTheme.primary,
      ),
    );
  }
}
