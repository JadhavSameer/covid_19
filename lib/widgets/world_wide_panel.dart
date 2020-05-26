import 'package:covid_19/constant.dart';
import 'package:covid_19/widgets/counter.dart';
import 'package:flutter/material.dart';

class WorldWidePanel extends StatelessWidget {
  final Map selectedData;
  const WorldWidePanel({
    Key key,
    this.selectedData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 30,
            color: kShadowColor,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Counter(color: kInfectedColor, number: selectedData['cases'], title: "Infected", logo: true),
          Counter(color: kDeathColor, number: selectedData['deaths'], title: "Deaths", logo: true),
          Counter(color: kRecovercolor, number: selectedData['recovered'], title: "Recovered", logo: true),
        ],
      ),
    );
  }
}
