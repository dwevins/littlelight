import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

typedef void FreeSlotsChanged(int freeSlots);

class FreeSlotsSliderWidget extends StatefulWidget {
  final FreeSlotsChanged onChanged;
  final int initialValue;
  final bool suppressLabel;

  const FreeSlotsSliderWidget(
      {Key key,
      this.onChanged,
      this.initialValue = 0,
      this.suppressLabel = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FreeSlotsSliderWidgetState();
  }
}

class FreeSlotsSliderWidgetState extends State<FreeSlotsSliderWidget> {
  int freeSlots = 0;

  @override
  void initState() {
    freeSlots = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: <Widget>[
            widget.suppressLabel
                ? Container()
                : TranslatedTextWidget("Free Slots"),
            Expanded(
                child: Slider(
              min: 0,
              max: 9,
              value: freeSlots.toDouble(),
              onChanged: (double value) {
                freeSlots = value.round();
                setState(() {});
                if (widget.onChanged != null) {
                  widget.onChanged(freeSlots);
                }
              },
            )),
            Text(
              "$freeSlots",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
  }
}
