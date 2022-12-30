import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_spreadsheet/const.dart';
import 'package:quiz_spreadsheet/play.dart';
import 'package:quiz_spreadsheet/data/set_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quiz_spreadsheet/widget/my_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPrimaryColor,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kAppName,
      theme: ThemeData(
        primarySwatch: kPrimaryColorSwatch,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      home: const MyHomePage(title: kAppName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future future;

  Future<List> httpsGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map sheetNameMap = {
      "quiz": kSheetQuiz,
      "result": kSheetResult,
      "shindan": kSheetShindan,
    };
    Map dataMap = {"quiz": [], "result": [], "shindan": []};
    String baseUrl = "https://sheets.googleapis.com/v4/spreadsheets";
    Map<String, String> headers = {
      'content-type': 'application/json',
    };
    for (String key in sheetNameMap.keys) {
      if (sheetNameMap[key] == "") continue;
      try {
        var url = Uri.parse(
            "$baseUrl/$kSheetId/values/${sheetNameMap[key]}?key=$kApiKey");
        final response = await http.get(url, headers: headers);
        Map data = json.decode(utf8.decode(response.bodyBytes));
        dataMap[key] = data["values"] ?? [];
        // 保存
        if (dataMap[key].length > 0) {
          prefs.setString("data_$key", jsonEncode(dataMap[key]));
        }
      } catch (e) {}
    }
    // httpsで取得できなかった場合、保存したデータから取得
    for (String key in dataMap.keys) {
      if (dataMap[key].length == 0) {
        var saveData = prefs.getString("data_$key") ?? "";
        if (saveData != "") dataMap[key] = jsonDecode(saveData);
      }
    }
    List quizDataList = setQuizData(dataMap["quiz"], dataMap["result"]);
    List shindanDataList = setShindanData(dataMap["shindan"]);
    return [quizDataList, shindanDataList];
  }

  int lockNum = 0;
  List<String> clearList = [];
  List<String> perfectList = [];
  bool isAudio = true;

  void getSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    /// リセット用
    // prefs.setInt("lock_num", 0);
    // prefs.setStringList("clear_list", []);
    // prefs.setStringList("perfect_list", []);
    ///
    clearList = prefs.getStringList("clear_list") ?? [];
    perfectList = prefs.getStringList("perfect_list") ?? [];
    lockNum = prefs.getInt("lock_num") ?? 0;
    isAudio = prefs.getBool("audio") ?? isAudio;
    setState(() {});
  }

  void setSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("audio", isAudio);
  }

  @override
  void initState() {
    getSetting();
    future = httpsGet();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getSetting();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              "assets/image/background.png",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              color: kBackgroundColor,
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          child: Image.asset(
                            "assets/image/title.png",
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              MaterialButton(
                                elevation: 0,
                                focusElevation: 0,
                                highlightElevation: 0,
                                hoverElevation: 0,
                                disabledElevation: 0,
                                color: Colors.orange,
                                shape: const StadiumBorder(),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(kAppUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "レビュー",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              MaterialButton(
                                elevation: 0,
                                focusElevation: 0,
                                highlightElevation: 0,
                                hoverElevation: 0,
                                disabledElevation: 0,
                                color: Colors.blue,
                                shape: const StadiumBorder(),
                                onPressed: () {
                                  FlutterShare.share(
                                    title: kAppName,
                                    linkUrl: kAppUrl,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "シェア",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              MaterialButton(
                                elevation: 0,
                                focusElevation: 0,
                                highlightElevation: 0,
                                hoverElevation: 0,
                                disabledElevation: 0,
                                color: Colors.green,
                                shape: const StadiumBorder(),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          title: const Text("設定"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              CheckboxListTile(
                                                value: isAudio,
                                                title: const Text("効果音"),
                                                onChanged: (flg) {
                                                  isAudio = flg ?? true;
                                                  setSetting();
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("閉じる"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                    },
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "設定",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          color: Colors.white,
                          child: const Text(
                            "$kClearPercent%正解で次のクイズのロックが解除されるよ。",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: future,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List data = snapshot.data;
                              List quizDataList = data[0];
                              List shindanDataList = data[1];
                              return Column(
                                children: [
                                  for (int i = 0; i < quizDataList.length; i++)
                                    Card(
                                      color: kPrimaryColor,
                                      margin: const EdgeInsets.only(
                                          left: 14, right: 14, top: 24),
                                      child: MaterialButton(
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 64,
                                          ),
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional.center,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 44,
                                                        vertical: 8),
                                                child: Text(
                                                  quizDataList[i]["title"],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (i <= lockNum &&
                                                  clearList.contains(
                                                      quizDataList[i]["title"]))
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  margin: const EdgeInsets.only(
                                                      right: 5),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: 38,
                                                    height: 38,
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 6),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Text(
                                                      perfectList.contains(
                                                              quizDataList[i]
                                                                  ["title"])
                                                          ? "満点"
                                                          : "クリア",
                                                      style: const TextStyle(
                                                        color: kPrimaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (i > lockNum)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 11),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: const Icon(
                                                    Icons.lock,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        onPressed: () {
                                          if (i > lockNum) {
                                            Fluttertoast.cancel();
                                            Fluttertoast.showToast(
                                              msg: "ロックされています",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Play(
                                                titleNum: i,
                                                quizData: quizDataList[i],
                                                isShindan: false,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  for (var shindanData in shindanDataList)
                                    Card(
                                      color: kPrimaryColor,
                                      margin: const EdgeInsets.only(
                                          left: 14, right: 14, top: 24),
                                      child: MaterialButton(
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 64,
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 44, vertical: 8),
                                            child: Text(
                                              shindanData["title"],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Play(
                                                titleNum: 0,
                                                quizData: shindanData,
                                                isShindan: true,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                for (int i = 0; i < 4; i++)
                                  Card(
                                    color: kPrimaryColor,
                                    margin: const EdgeInsets.only(
                                        left: 14, right: 14, top: 24),
                                    child: MaterialButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: null,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 64,
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 44, vertical: 8),
                                          child: const Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const MyBanner(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
