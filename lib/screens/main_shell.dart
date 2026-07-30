import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/home_style.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';
import 'shop/shop_screen.dart';
import 'statistics/statistics_screen.dart';
import 'tips/tips_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static final GlobalKey<MainShellState> shellKey = GlobalKey<MainShellState>();

  static MainShellState? get instance => shellKey.currentState;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void openShop({ShopRewardsTab tab = ShopRewardsTab.all}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ShopScreen(initialTab: tab)));
  }

  void _onTabChanged(int i) {
    if (i == 3) {
      _openMore(context);
      return;
    }
    setState(() => _index = i);
  }

  void _openMore(BuildContext context, {ShopRewardsTab openShopTab = ShopRewardsTab.all}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.pastelLavender.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.primaryDark, size: 20),
                ),
                title: Text(AppStrings.t(context, 'navShop'), style: HomeStyle.gridLabel()),
                onTap: () {
                  Navigator.pop(ctx);
                  openShop(tab: openShopTab);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.pastelOrange.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.settings_outlined, color: AppColors.primaryDark, size: 20),
                ),
                title: Text(AppStrings.t(context, 'navSettings'), style: HomeStyle.gridLabel()),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int i) {
    return switch (i) {
      0 => const RepaintBoundary(child: HomeScreen()),
      1 => const TipsScreen(embedded: true),
      2 => const StatisticsScreen(embedded: true),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeStyle.pageBg,
      body: _buildTab(_index),
      bottomNavigationBar: _BottomNav(index: _index, onChanged: _onTabChanged),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: EdgeInsets.fromLTRB(8, 10, 8, bottom > 0 ? bottom : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: HomeStyle.softShadow(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: AppStrings.t(context, 'navHome'),
            active: index == 0,
            icon: Icons.home_rounded,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            label: AppStrings.t(context, 'navTips'),
            active: index == 1,
            icon: Icons.lightbulb_outline_rounded,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            label: AppStrings.t(context, 'navLogs'),
            active: index == 2,
            icon: Icons.insights_rounded,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            label: AppStrings.t(context, 'navMore'),
            active: false,
            icon: Icons.grid_view_rounded,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.active, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.pastelLavender.withValues(alpha: 0.45) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: active ? AppColors.primaryDark : AppColors.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: HomeStyle.badgeText(highlight: active).copyWith(
                  fontSize: 10,
                  color: active ? AppColors.primaryDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
