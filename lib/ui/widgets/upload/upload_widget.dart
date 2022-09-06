import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import 'upload_model.dart';

class UploadWidget extends StatelessWidget {
  const UploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Upload(),
      child: const _UploadWidget(),
    );
  }
}

class _UploadWidget extends StatelessWidget {
  const _UploadWidget();

  @override
  Widget build(BuildContext context) {
    final image = context.select((Upload model) => model.image);

    return SizedBox(
      height: 250,
      child: Center(
        child: image != null
            ? Padding(
                padding: const EdgeInsets.all(buttonsSpacing),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(image),
                  child: Image(
                    image: image,
                    filterQuality: FilterQuality.medium,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(buttonsSpacing * 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Waiting for image from phone',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const LinearProgressIndicator()
                  ],
                ),
              ),
      ),
    );
  }
}
