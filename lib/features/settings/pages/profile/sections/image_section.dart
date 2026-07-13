part of '../page.dart';

class _ImageSection extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _ImageSection({
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegularText.medium('Upload Logo'),
        Dimens.dp8.height,
        const RegularText(
          'Maks. ukuran 3 MB',
          style: TextStyle(fontSize: Dimens.dp12),
        ),
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: context.theme.primaryColor.withOpacity(0.1),
                  backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                  child: imagePath == null
                      ? Icon(
                          Icons.storefront,
                          size: 48,
                          color: context.theme.colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
