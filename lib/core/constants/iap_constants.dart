class IapConstants {
  IapConstants._();

  static const String productPrefix = 'pcn';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/N217.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'pcn_pack_1',
    'pcn_pack_2',
    'pcn_pack_3',
    'pcn_pack_4',
    'pcn_pack_5',
    'pcn_pack_6',
    'pcn_pack_7',
    'pcn_pack_8',
    'pcn_pack_9',
    'pcn_pack_10',
  ];

  static const String removeAdsProductId = 'pcn_remove_ads';

  static List<String> get allProductIds => [...coinPackIds, removeAdsProductId];

  static const List<int> coinPackAmounts = [
    50, 100, 200, 350, 500, 750, 1000, 1500, 2200, 3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsProductId;

  static const int freePetLimit = 2;
  static const int premiumPetLimit = 10;
  static const int dailyLoginReward = 10;
  static const int logActivityReward = 5;
  static const int maxLogActivityRewardsPerDay = 15;
  static const int careReward = 8;
  static const int maxCareRewardsPerDay = 5;
  static const int streakReward = 15;
  static const int maxStreakRewardsPerDay = 1;
}
