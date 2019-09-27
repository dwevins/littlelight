import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';
import 'package:little_light/widgets/item_stats/base_item_stats.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_item_stat.widget.dart';

class ScreenShotItemStatsWidget extends BaseItemStatsWidget {
  final double pixelSize;

  ScreenShotItemStatsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      ItemSocketController socketController,
      this.pixelSize})
      : super(
        socketController:socketController,
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return ScreenShotItemStatsState();
  }
}

class ScreenShotItemStatsState
    extends BaseItemStatsState<ScreenShotItemStatsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: buildStats(context),
    );
  }

  buildStats(context) {
    Map<int, StatValues> statValues = getStatValues();

    return stats.map((stat) {
      var entry = statValues[stat.statTypeHash];
      return ScreenshotItemStatWidget(
        statHash: stat.statTypeHash,
        modValues: entry,
        pixelSize: widget.pixelSize,
        scaled: statGroupDefinition.scaledStats
            .firstWhere((s) => s.statHash == stat.statTypeHash, orElse: () => null),
      );
    }).toList();
  }
}
