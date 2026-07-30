import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_forest',
      nameKey: 'shopThemeForest',
      descKey: 'shopThemeForestDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.forest_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'theme_candy',
      nameKey: 'shopThemeCandy',
      descKey: 'shopThemeCandyDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.cake_outlined,
    ),
    ShopItem(
      id: 'bg_paws',
      nameKey: 'shopBgPaws',
      descKey: 'shopBgPawsDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.pets_outlined,
    ),
    ShopItem(
      id: 'bg_stars',
      nameKey: 'shopBgStars',
      descKey: 'shopBgStarsDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.star_outline,
    ),
    ShopItem(
      id: 'bg_grass',
      nameKey: 'shopBgGrass',
      descKey: 'shopBgGrassDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.grass_outlined,
    ),
    ShopItem(
      id: 'bg_bubbles',
      nameKey: 'shopBgBubbles',
      descKey: 'shopBgBubblesDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.bubble_chart_outlined,
    ),
    ShopItem(
      id: 'skin_soft',
      nameKey: 'shopSkinSoft',
      descKey: 'shopSkinSoftDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.circle_outlined,
    ),
    ShopItem(
      id: 'skin_cute',
      nameKey: 'shopSkinCute',
      descKey: 'shopSkinCuteDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.favorite_border,
    ),
    ShopItem(
      id: 'skin_playful',
      nameKey: 'shopSkinPlayful',
      descKey: 'shopSkinPlayfulDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.toys_outlined,
    ),
    ShopItem(
      id: 'feat_multi_pet',
      nameKey: 'shopFeatMultiPet',
      descKey: 'shopFeatMultiPetDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.pets_outlined,
    ),
    ShopItem(
      id: 'feat_export_data',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_stats_pro',
      nameKey: 'shopFeatStatsPro',
      descKey: 'shopFeatStatsProDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.show_chart_outlined,
    ),
    ShopItem(
      id: 'feat_vaccine_reminder',
      nameKey: 'shopFeatVaccineReminder',
      descKey: 'shopFeatVaccineReminderDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.notifications_active_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
