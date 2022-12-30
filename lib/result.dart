import 'package:flutter/material.dart';
import 'package:quiz_spreadsheet/const.dart';
import 'package:quiz_spreadsheet/widget/my_banner.dart';
import 'package:quiz_spreadsheet/widget/my_banner_rectangle.dart';
import 'package:quiz_spreadsheet/widget/my_interstitial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_share/flutter_share.dart';

class Result extends StatefulWidget {
  final int titleNum;
  final String title;
  final int quizNum;
  final int correctNum;
  final List results;
  final List shindanAnswers;
  final bool isShindan;

  const Result({
    Key? key,
    required this.titleNum,
    required this.title,
    required this.quizNum,
    required this.correctNum,
    required this.results,
    required this.shindanAnswers,
    required this.isShindan,
  }) : super(key: key);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  String title = "";
  List results = [];
  int quizNum = 0;
  int correctNum = 0;
  int percent = 0;
  String result = "";
  String comment = "";
  bool isShindan = false;
  List shindanAnswers = [];

  void setClearUnlock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lockNum = prefs.getInt("lock_num") ?? 0;
    if (widget.titleNum >= lockNum) {
      prefs.setInt("lock_num", ++lockNum);
    }
    List<String> clearList = prefs.getStringList("clear_list") ?? [];
    if (!clearList.contains(title)) {
      clearList.add(title);
      prefs.setStringList("clear_list", clearList);
    }
    List<String> perfectList = prefs.getStringList("perfect_list") ?? [];
    if (percent == 100 && !perfectList.contains(title)) {
      perfectList.add(title);
      prefs.setStringList("perfect_list", perfectList);
    }
  }

  final MyInterstitialPlay _myInterstitialPlay =
      MyInterstitialPlay(kAdmobIdInterstitialResult);

  @override
  void dispose() {
    _myInterstitialPlay.interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _myInterstitialPlay.createInterstitialAd();
    title = widget.title;
    results = widget.results;
    quizNum = widget.quizNum;
    correctNum = widget.correctNum;
    shindanAnswers = widget.shindanAnswers;
    isShindan = widget.isShindan;
    if (isShindan) {
      int pointMax = -100;
      for (int i = 0; i < results.length; i++) {
        int point = shindanAnswers[i];
        if (point > pointMax) {
          result = results[i]["result"];
          comment = results[i]["comment"];
          pointMax = point;
        }
      }
    } else {
      percent = (correctNum / quizNum * 100).toInt();
      for (var item in results) {
        if (percent >= item["percent"]) {
          result = item["result"];
          comment = item["comment"];
          break;
        }
      }
      if (percent >= kClearPercent) setClearUnlock();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _myInterstitialPlay.showInterstitialAd();
        return true;
      },
      child: Scaffold(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 6),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Card(
                              elevation: 0,
                              color: Colors.white.withOpacity(0.7),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "$title 結果",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height / 3,
                            ),
                            child: Card(
                              color: Colors.black.withOpacity(0.7),
                              child: Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const SizedBox(height: 10),
                                    Text(
                                      result,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      comment,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (!isShindan)
                                      Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "$quizNum",
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                "問中",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "$correctNum",
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                "問正解",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              const Text(
                                                "正解率",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "$percent",
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                "％",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const MyBannerRectangle(),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Card(
                                    color: kPrimaryColor,
                                    margin: EdgeInsets.zero,
                                    child: MaterialButton(
                                      textColor: Colors.white,
                                      child: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "トップへ",
                                          style: TextStyle(
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _myInterstitialPlay
                                            .showInterstitialAd();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Card(
                                  color: Colors.blue,
                                  margin: EdgeInsets.zero,
                                  child: MaterialButton(
                                    textColor: Colors.white,
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        "シェア",
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      String share = "";
                                      if (isShindan) {
                                        FlutterShare.share(
                                          title: kAppName,
                                          text: "$title\n$result\n$comment",
                                          linkUrl: kAppUrl,
                                        );
                                      } else {
                                        FlutterShare.share(
                                          title: kAppName,
                                          text: "$title\n$result\n$comment"
                                              "\n$percent点$quizNum問中$correctNum問正解です。",
                                          linkUrl: kAppUrl,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
      ),
    );
  }
}
