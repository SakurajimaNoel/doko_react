import 'dart:io';
import 'dart:typed_data';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/media/image-filter/image_filter_provider.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/constrained-box/expanded_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

part 'image_filter_page_utils.dart';

class ImageFilterPage extends StatefulWidget {
  const ImageFilterPage({
    super.key,
    required this.image,
  });

  final String image;

  @override
  State<ImageFilterPage> createState() => _ImageFilterPageState();
}

class _ImageFilterPageState extends State<ImageFilterPage> {
  late TextureSource texture;

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    TextureSource.fromFile(File(widget.image))
        .then((value) => texture = value)
        .whenComplete(() {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    final height = 1 * width;

    final currTheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (context) {
        return ImageFilterProvider(
          configuration: _filterConfigurations.first,
          selected: 0,
        );
      },
      child: Builder(
        builder: (context) {
          final configProvider = context.read<ImageFilterProvider>();

          return Scaffold(
            appBar: AppBar(
              title: const Text("Add filter"),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: Constants.padding,
              ),
              actions: [
                Builder(
                  builder: (context) {
                    final exporting = context.select(
                        (ImageFilterProvider provider) => provider.exporting);

                    return IconButton(
                      onPressed: exporting
                          ? null
                          : () async {
                              final pop = context.pop;
                              if (configProvider.selected == 0) {
                                pop("");
                              } else {
                                /// pop with filtered image
                                configProvider.export();
                                final image = await configProvider.configuration
                                    .export(texture, texture.size);

                                final bytes = await image.toByteData();
                                if (bytes == null) {
                                  pop();
                                  return;
                                }

                                RootIsolateToken rootIsolateToken =
                                    RootIsolateToken.instance!;
                                String path = await compute(
                                    getImageWithFilter,
                                    ImageWithFilterInput(
                                      token: rootIsolateToken,
                                      data: bytes.buffer,
                                      height: image.height,
                                      width: image.width,
                                    ));

                                pop(path);
                              }
                            },
                      icon: exporting
                          ? const LoadingWidget.small()
                          : const Icon(Icons.done),
                    );
                  },
                ),
              ],
            ),
            body: loaded
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(Constants.padding),
                      child: Column(
                        spacing: Constants.gap * 2,
                        children: [
                          ExpandedBox(
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: Builder(
                                builder: (context) {
                                  final configuration = context.select(
                                      (ImageFilterProvider provider) =>
                                          provider.configuration);

                                  return AnimatedSwitcher(
                                    duration: const Duration(
                                      milliseconds: 500,
                                    ),
                                    child: ImageShaderPreview(
                                      key: ObjectKey(configuration),
                                      configuration: configuration,
                                      texture: texture,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: Constants.gap,
                              children: [
                                for (int i = 0;
                                    i < _filterConfigurations.length;
                                    i++)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Constants.radius),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    width: 100,
                                    height: 100,
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            configProvider.updateConfiguration(
                                                _filterConfigurations[i], i);
                                          },
                                          child: Center(
                                            child: ImageShaderPreview(
                                              configuration:
                                                  _filterConfigurations[i],
                                              texture: texture,
                                            ),
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            final selected = context.select(
                                                    (ImageFilterProvider
                                                            provider) =>
                                                        provider.selected) ==
                                                i;

                                            return selected
                                                ? Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    color: currTheme
                                                        .primaryContainer
                                                        .withValues(
                                                      alpha: 0.5,
                                                    ),
                                                    child: Icon(
                                                      Icons.done,
                                                      color: currTheme
                                                          .onPrimaryContainer,
                                                    ),
                                                  )
                                                : const SizedBox.shrink();
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: LoadingWidget(),
                  ),
          );
        },
      ),
    );
  }
}
