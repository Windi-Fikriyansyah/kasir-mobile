import 'package:flutter/material.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/features/settings/settings.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';
import 'package:kasirsuper/features/report/pages/index/page.dart';

part 'sections/profile_section.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _SettingAppBar(),
            Expanded(
              child: Container(
                color: QuickPOSColors.surface,
                child: ListView(
                  children: [
                    const _ProfileSection(),
                    const Divider(
                      thickness: Dimens.dp8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimens.dp16),
                          child: RegularText.semiBold('Akun'),
                        ),
                        ItemMenuSetting(
                          title: 'Informasi Usaha',
                          icon: AppIcons.receipt,
                          onTap: () {},
                        ),
                        const Divider(height: 0),
                        ItemMenuSetting(
                          title: 'API  Key Xendit',
                          icon: AppIcons.creditCard,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: Dimens.dp8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimens.dp16),
                          child: RegularText.semiBold('Perangkat Tambahan'),
                        ),
                        ItemMenuSetting(
                          title: 'Printer',
                          icon: Icons.print,
                          onTap: () {},
                        ),
                        const Divider(height: 0),
                        ItemMenuSetting(
                          title: 'Atur Struk',
                          icon: AppIcons.coupon,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: Dimens.dp8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimens.dp16),
                          child: RegularText.semiBold('Laporan & Analisis'),
                        ),
                        ItemMenuSetting(
                          title: 'Laporan Penjualan',
                          icon: Icons.pie_chart,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReportPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: Dimens.dp8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimens.dp16),
                          child: RegularText.semiBold('Info Lainnya'),
                        ),
                        ItemMenuSetting(
                          title: 'Kebijakan Privasi',
                          icon: AppIcons.verified,
                          onTap: () {},
                        ),
                        const Divider(height: 0),
                        ItemMenuSetting(
                          title: 'Beri Rating',
                          icon: AppIcons.star,
                          onTap: () {},
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Dimens.dp16),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.theme.colorScheme.error,
                          side: BorderSide(color: context.theme.colorScheme.error),
                        ),
                        onPressed: () {},
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingAppBar extends StatelessWidget {
  const _SettingAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.storefront, color: QuickPOSColors.primary),
              SizedBox(width: 8),
              Text(
                'Lainnya',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: QuickPOSColors.onSurface,
                ),
              ),
            ],
          ),
          const NotificationBell(),
        ],
      ),
    );
  }
}
