import 'dart:convert';

import 'package:covid_19/indian_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart' as dom; // Contains DOM related classes for extracting data from elements

import 'package:covid_19/constant.dart';
import 'package:covid_19/widgets/my_header.dart';
import 'package:covid_19/widgets/world_wide_panel.dart';
import 'package:covid_19/country_details.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid 19',
      theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          fontFamily: "Poppins",
          textTheme: TextTheme(
            bodyText1: TextStyle(color: kBodyTextColor),
          )),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List countryData;
  String dropdownValue = 'World';
  Map selectedData;
  // String apiUrl = "https://corona.lmao.ninja/v2/countries/";
  String apiUrl = "https://coronavirus-19-api.herokuapp.com/countries";

  List statesDataList;

  fetchCountryData() async {
    http.Response response = await http.get(apiUrl);
    setState(() {
      countryData = json.decode(response.body);
      Iterator it = countryData.iterator;
      while (it.moveNext()) {
        if (it.current['country'] == dropdownValue) {
          selectedData = it.current;
          print("Data fetched from : " + apiUrl + " size : " + countryData.length.toString());
          break;
        }
      }
    });
  }

  final controller = ScrollController();
  double offset = 0;

  @override
  void initState() {
    fetchCountryData();
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd').format(now);

    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: <Widget>[
            MyHeader(
              image: "assets/icons/Drcorona.svg",
              textTop: "All you need",
              textBottom: "is stay at home.",
              offset: offset,
            ),
            countryData == null
                ? CircularProgressIndicator()
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Color(0xFFE5E5E5),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset("assets/icons/maps-and-flags.svg"),
                        SizedBox(width: 20),
                        Expanded(
                          child: DropdownButton(
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                            value: dropdownValue,
                            items: countryData.map((item) {
                              return DropdownMenuItem(
                                child: Text(item['country']),
                                value: item['country'].toString(),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                Iterator it = countryData.iterator;
                                while (it.moveNext()) {
                                  if (it.current['country'] == newValue) {
                                    selectedData = it.current;
                                    break;
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Case Update\n",
                              style: kTitleTextstyle,
                            ),
                            TextSpan(
                              text: "Newest update " + formattedDate,
                              style: TextStyle(
                                color: kTextLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          print("onTap() Country Details : " + ModalRoute.of(context).settings.name);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: 'CountryDetails'),
                              builder: (context) {
                                var country = selectedData["country"];
                                Map tempSelectedData = new Map.from(selectedData);
                                tempSelectedData.remove("country");
                                return CountryDetails(countryName: country, selectedData: tempSelectedData);
                              },
                            ),
                          );
                        },
                        child: Text(
                          "See details",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // WorldWidePanel(),
                  selectedData == null ? CircularProgressIndicator() : WorldWidePanel(selectedData: selectedData),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Indian States", style: kTitleTextstyle),
                      GestureDetector(
                        onTap: () {
                          print("onTap() Indian States : " + ModalRoute.of(context).settings.name);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: 'IndianStates'),
                              builder: (context) {
                                return IndianStates();
                              },
                            ),
                          );
                        },
                        child: Text("See details", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(10),
                    height: 165,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 30, color: kShadowColor)],
                    ),
                    child: Image.asset("assets/images/map.png", fit: BoxFit.fill),
                  ),

                  Container(
                    alignment: Alignment.center,
                    child: Text("Copyright © 2020 sameer.jadhav01@gmail.com", style: kCopyrightTextStyle),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
