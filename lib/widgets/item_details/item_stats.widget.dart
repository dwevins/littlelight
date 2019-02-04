import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

const List<int> _noBarStats = [
  4284893193, // Rounds Per Minute
  3871231066, // Magazine
  2961396640, // Charge Time
  1931675084, //Inventory Size

  2996146975, // Mobility
  392767087, // Resilience
  1943323491, //recovery
];

const List<int> _hiddenStats = [
  1345609583, // Aim Assistance
  2715839340, // Recoil Direction
  3555269338, // Zoom
];

class ItemStatsWidget extends DestinyItemWidget {
  final Map<int, int> selectedPerks;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;

  ItemStatsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.selectedPerks,
      this.plugDefinitions})
      : super(item, definition, instanceInfo, key: key);

  Widget build(BuildContext context) {
    if ((stats?.length ?? 0) == 0) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Stats",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(children: buildStats(context))),
        ],
      ),
    );
  }

  buildStats(context) {
    Map<int, StatValues> statValues = getModValues();

    return stats.map((stat) {
      return ItemStatWidget(
          stat.statHash, stat.value, statValues[stat.statHash]);
    }).toList();
  }

  Map<int, StatValues> getModValues() {
    Map<int, StatValues> map = new Map();
    if (plugDefinitions == null) {
      return map;
    }
    List<int> plugHashes;
    if (socketStates != null) {
      plugHashes = socketStates.map((state) => state.plugHash).toList();
    } else {
      plugHashes = definition.sockets.socketEntries
          .map((plug) => plug.singleInitialItemHash)
          .toList();
    }

    plugHashes.forEach((plugHash) {
      int index = plugHashes.indexOf(plugHash);
      DestinyInventoryItemDefinition def = plugDefinitions[plugHash];
      if (def == null) {
        return;
      }
      DestinyInventoryItemDefinition selectedDef =
          plugDefinitions[selectedPerks[index]];

      def.investmentStats.forEach((stat) {
        StatValues values = map[stat.statTypeHash] ?? new StatValues();
        if (def.plug?.uiPlugLabel == 'masterwork') {
          values.masterwork += stat.value;
        } else {
          values.equipped += stat.value;
          if (selectedDef == null) {
            values.selected += stat.value;
          }
        }
        map[stat.statTypeHash] = values;
      });

      if (selectedDef != null) {
        selectedDef.investmentStats.forEach((stat) {
          StatValues values = map[stat.statTypeHash] ?? new StatValues();
          if (selectedDef.plug?.uiPlugLabel != 'masterwork') {
            values.selected += stat.value;
          }
          map[stat.statTypeHash] = values;
        });
      }
    });

    return map;
  }

  Iterable<DestinyInventoryItemStatDefinition> get stats {
    if (definition?.stats?.stats == null) {
      return null;
    }
    List<DestinyInventoryItemStatDefinition> stats = definition
        .stats.stats.values
        .where((stat) => DestinyData.statWhitelist.contains(stat.statHash))
        .toList();

    stats.sort((statA, statB) {
      int valA = _noBarStats.contains(statA.statHash)
          ? 2
          : _hiddenStats.contains(statA.statHash) ? 1 : 0;
      int valB = _noBarStats.contains(statB.statHash)
          ? 2
          : _hiddenStats.contains(statB.statHash) ? 1 : 0;
      return valA - valB;
    });
    return stats;
  }

  List<DestinyItemSocketState> get socketStates {
    if (item == null) return null;
    return profile.getItemSockets(item.itemInstanceId);
  }
}

class ItemStatWidget extends StatelessWidget {
  final int statHash;
  final int baseValue;
  final StatValues modValues;

  ItemStatWidget(this.statHash, this.baseValue, this.modValues);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          print(constraints.maxWidth);
      return Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
            SizedBox(
                width: constraints.maxWidth * .45,
                child: ManifestText<DestinyStatDefinition>(
                  statHash,
                  key: Key("item_stat_$statHash"),
                  textAlign: TextAlign.right,
                  uppercase: true,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.fade,
                )),
            SizedBox(
                width: constraints.maxWidth * .1,
                child: Text(
                  "$numberValue",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      color: modColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  overflow: TextOverflow.fade,
                )),
            buildBar(context, constraints.maxWidth * .45)
          ]));
    });
  }

  Widget buildBar(BuildContext context, barWidth) {
    if (noBar) {
      return Container();
    }
    return SizedBox(
        width: barWidth,
        child: Container(
            color: Colors.grey.shade600,
            height: 8,
            child: Row(
              mainAxisAlignment: numberValue < 0 ? MainAxisAlignment.end : MainAxisAlignment.start, 
            children: [
              Container(
                height: 8,
                width: max(baseBarSize / maxBarSize, 0) * barWidth,
                color: color,
              ),
              Container(
                height: 8,
                width: (modBarSize / maxBarSize).abs() * barWidth,
                color: modColor,
              ),
              Container(
                  height: 8,
                  width: (masterwork / maxBarSize).abs() * barWidth,
                  color: Colors.amberAccent.shade400),
            ])));
  }

  int get maxBarSize {
    return max(100, numberValue);
  }

  int get numberValue {
    return baseValue + selected + masterwork;
  }

  int get selected => modValues?.selected ?? 0;
  int get equipped => modValues?.equipped ?? 0;
  int get masterwork => modValues?.masterwork ?? 0;

  int get baseBarSize {
    if (selected != equipped && selected < equipped) {
      return baseValue + selected;
    }
    return baseValue + equipped;
  }

  Color get modColor {
    if (selected > equipped) {
      return DestinyData.positiveFeedback;
    }
    if (equipped > selected) {
      return DestinyData.negativeFeedback;
    }
    if (masterwork > 0) {
      return Colors.amberAccent.shade400;
    }
    return color;
  }

  int get modBarSize {
    return (selected - equipped).abs();
  }

  Color get color {
    return hiddenStat ? Colors.amber.shade200 : Colors.grey.shade300;
  }

  bool get hiddenStat {
    return _hiddenStats.contains(statHash);
  }

  bool get noBar {
    return _noBarStats.contains(statHash);
  }
}

class StatValues {
  int equipped = 0;
  int selected = 0;
  int masterwork = 0;
  StatValues();
}
