// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom; // Contains DOM related classes for extracting data from elements
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:http/http.dart' as http;

import 'package:covid_19/constant.dart';
import 'package:covid_19/widgets/my_header.dart';
// import 'package:covid_19/country_details.dart';
// import 'package:covid_19/widgets/counter.dart';
// import 'package:web_scraper/web_scraper.dart';

class IndianStates extends StatefulWidget {
  const IndianStates({Key key}) : super(key: key);

  @override
  _IndianStatesState createState() => _IndianStatesState();
}

class _IndianStatesState extends State<IndianStates> {
  List statesDataList;
  final controller = ScrollController();
  double offset = 0;

  @override
  void initState() {
    fetchIndianStatesData();
    super.initState();
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  fetchIndianStatesData() async {
    String apiUrl = "https://www.mohfw.gov.in/";
    statesDataList = [];
    var client = http.Client();
    http.Response response = await client.get(apiUrl);
    var document = parse(response.body);
    List<dom.Element> links = document.querySelectorAll('tbody > tr '); //('th > strong')
    for (var link in links) {
      List<dom.Element> res = link.querySelectorAll('td');
      if (res.length == 5 && !["", null, false, 0].contains(res[0].text)) {
        // res[0].text?.isNotEmpty ?? true
        statesDataList.add({'srno': res[0].text, 'state': res[1].text, 'cases': res[2].text, 'recovered': res[3].text, 'deaths': res[4].text});
      }
    }
    print("Data fetched from : " + apiUrl + " size : " + statesDataList.length.toString());

    setState(() {
      statesDataList = statesDataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MyHeader(image: "assets/icons/coronadr.svg", textTop: "Indian States", textBottom: "About Covid-19.", offset: offset),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("INDIA State / UT", style: kTitleTextstyle),
            ),
            // statesDataList.isEmpty
            //     ? Center(child: CircularProgressIndicator())
            //     : ListView.builder(
            //         physics: NeverScrollableScrollPhysics(),
            //         shrinkWrap: true,
            //         itemBuilder: (context, index) {
            //           return IndianStatesCard(title: statesDataList[index]['state'], stateData: statesDataList[index]);
            //           // return DetailsTable(selectedData: statesDataList[index]);
            //         },
            //         itemCount: statesDataList == null ? 0 : statesDataList.length,
            //       ),
            StatesTable(statesDataList: statesDataList),
          ],
        ),
      ),
    );
  }
}

class StatesTable extends StatefulWidget {
  final List statesDataList;

  const StatesTable({
    Key key,
    this.statesDataList,
  }) : super(key: key);

  @override
  _StateTableState createState() => _StateTableState();
}

class _StateTableState extends State<StatesTable> {
  bool sort;
  int sortColumnIndex;

  @override
  void initState() {
    sort = false;
    super.initState();
  }

  void onSortColumn(int columnIndex, bool ascending, String field) {
    if (columnIndex == 0) {
      if (ascending) {
        widget.statesDataList.sort((a, b) => a['state'].compareTo(b['state']));
      } else {
        widget.statesDataList.sort((a, b) => b['state'].compareTo(a['state']));
      }
    }
    if (columnIndex == 1 || columnIndex == 2 || columnIndex == 3) {
      if (ascending) {
        widget.statesDataList.sort((a, b) => int.parse(a[field]).compareTo(int.parse(b[field])));
      } else {
        widget.statesDataList.sort((a, b) => int.parse(b[field]).compareTo(int.parse(a[field])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      // padding: EdgeInsets.all(10),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
              // dataRowHeight: 60,
              columnSpacing: 0,
              sortAscending: sort,
              sortColumnIndex: sortColumnIndex,
              columns: <DataColumn>[
                DataColumn(
                  label: Text('State', style: kTableHeaderTextStyle),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                      sortColumnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending, 'states');
                  },
                ),
                DataColumn(
                  label: Text('Cases', style: kTableHeaderTextStyle),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                      sortColumnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending, 'cases');
                  },
                ),
                DataColumn(
                  label: Text('Deaths', style: kTableHeaderTextStyle),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                      sortColumnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending, 'deaths');
                  },
                ),
                DataColumn(
                  label: Text('Recovered', style: kTableHeaderTextStyle),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                      sortColumnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending, 'recovered');
                  },
                ),
              ],
              rows: widget.statesDataList
                  .map((e) => DataRow(cells: [
                        DataCell(Container(width: 120, child: Text(e['state'].toString(), style: kTableTextStyle))),
                        DataCell(Text(e['cases'].toString(), style: TextStyle(fontSize: 16, color: kInfectedColor))),
                        DataCell(Text(e['deaths'].toString(), style: TextStyle(fontSize: 16, color: kDeathColor))),
                        DataCell(Text(e['recovered'].toString(), style: TextStyle(fontSize: 16, color: kRecovercolor))),
                      ]))
                  .toList()),
        ),
      ),
    );
  }
}

// class IndianStatesCard extends StatelessWidget {
//   final String title;
//   final bool isActive;
//   final Map stateData;
//   const IndianStatesCard({
//     Key key,
//     this.title,
//     this.isActive = false,
//     this.stateData,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white, boxShadow: [
//         isActive
//             ? BoxShadow(
//                 offset: Offset(0, 10),
//                 blurRadius: 20,
//                 color: kActiveShadowColor,
//               )
//             : BoxShadow(
//                 offset: Offset(0, 3),
//                 blurRadius: 6,
//                 color: kShadowColor,
//               ),
//       ]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Counter(color: kInfectedColor, number: int.parse(stateData['cases']), title: "Infected", logo: false),
//               Counter(color: kDeathColor, number: int.parse(stateData['deaths']), title: "Deaths", logo: false),
//               Counter(color: kRecovercolor, number: int.parse(stateData['recovered']), title: "Recovered", logo: false),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
