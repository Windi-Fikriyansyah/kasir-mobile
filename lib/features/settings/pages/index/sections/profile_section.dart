part of '../page.dart';

class _ProfileSection extends StatefulWidget {
  const _ProfileSection();

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  String? _imagePath;
  String _name = 'Kasir SUPER';
  String _email = 'superpos@gmail.com';
  String _phone = '+6282117499922';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? 'Kasir SUPER';
      _email = prefs.getString('profile_email') ?? 'superpos@gmail.com';
      _phone = prefs.getString('profile_phone') ?? '+6282117499922';
      _imagePath = prefs.getString('profile_image');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.defaultSize),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: QuickPOSColors.surfaceContainerHigh,
            backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
            child: _imagePath == null
                ? const Icon(
                    Icons.storefront,
                    size: 32,
                    color: QuickPOSColors.primary,
                  )
                : null,
          ),
          Dimens.dp16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RegularText.semiBold(_name),
                Dimens.dp4.height,
                RegularText(
                  _email,
                  style: const TextStyle(
                    fontSize: Dimens.dp12,
                  ),
                ),
                Dimens.dp4.height,
                RegularText(
                  _phone,
                  style: const TextStyle(
                    fontSize: Dimens.dp12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, ProfilePage.routeName);
              if (result == true) {
                _loadProfile();
              }
            },
            icon: Icon(
              AppIcons.edit,
              color: context.theme.primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
