import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:covid_19/constant.dart';
import 'package:covid_19/widgets/my_header.dart';
import 'package:sortedmap/sortedmap.dart';

class CountryDetails extends StatefulWidget {
  final String countryName;
  final Map selectedData;
  const CountryDetails({
    Key key,
    this.selectedData,
    this.countryName,
  }) : super(key: key);

  @override
  _CountryDetailsState createState() => _CountryDetailsState();
}

class _CountryDetailsState extends State<CountryDetails> {
  final controller = ScrollController();
  double offset = 0;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyHeader(
              image: "assets/icons/coronadr.svg",
              textTop: "Country Details",
              textBottom: "About Covid-19.",
              offset: offset,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.countryName + " Details", style: kTitleTextstyle),
                  SizedBox(height: 20),
                  DetailsTable(selectedData: widget.selectedData),
                  SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DetailsTable extends StatefulWidget {
  Map selectedData;

  DetailsTable({
    Key key,
    this.selectedData,
  }) : super(key: key);

  @override
  _DetailsTableState createState() => _DetailsTableState();
}

class _DetailsTableState extends State<DetailsTable> {
  bool sort;
  int sortColumnIndex;

  @override
  void initState() {
    sort = false;
    super.initState();
  }

  void onSortColumn(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      var entries = widget.selectedData.entries.toList();
      if (ascending) {
        entries.sort((a, b) => a.key.compareTo(b.key));
      } else {
        entries.sort((a, b) => b.key.compareTo(a.key));
      }
      widget.selectedData = Map.fromEntries(entries);
    }
    if (columnIndex == 1) {
      var entries = widget.selectedData.entries.toList();
      if (ascending) {
        entries.sort((a, b) => a.value.compareTo(b.value));
      } else {
        entries.sort((a, b) => b.value.compareTo(a.value));
      }
      widget.selectedData = Map.fromEntries(entries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
            sortAscending: sort,
            sortColumnIndex: sortColumnIndex,
            columns: <DataColumn>[
              DataColumn(
                  label: Text('Field', style: kTableHeaderTextStyle),
                  onSort: ((columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                      sortColumnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending);
                  })),
              DataColumn(
                  label: Text('Data', style: kTableHeaderTextStyle),
                  numeric: true,
                  onSort: ((columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                      sortColumnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending);
                  })),
            ],
            rows: widget.selectedData.entries
                .map((e) => DataRow(cells: [
                      DataCell(Text(e.key.toString(), style: kTableTextStyle)),
                      DataCell(Text(e.value.toString(), style: kTableTextStyle)),
                    ]))
                .toList()),
      ),
    );
  }
}
