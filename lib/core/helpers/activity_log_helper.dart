import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/shop_provider.dart';

class ActivityLogHelper {
  static Future<void> logAndReward(BuildContext context, ActivityLog log) async {
    await context.read<ActivityProvider>().addLog(
          petId: log.petId,
          type: log.type,
          timestamp: log.timestamp,
          data: log.data,
          note: log.note,
        );
    await context.read<ShopProvider>().rewardForLogActivity();
    if (log.type == ActivityType.grooming || log.type == ActivityType.health) {
      await context.read<ShopProvider>().rewardForCare();
    }
    if (context.mounted) Navigator.pop(context);
  }
}
