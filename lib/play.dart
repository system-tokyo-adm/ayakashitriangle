import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiz_spreadsheet/const.dart';
import 'package:quiz_spreadsheet/result.dart';
import 'package:quiz_spreadsheet/widget/my_banner.dart';
import 'package:quiz_spreadsheet/widget/my_interstitial.dart';
import 'package:quiz_spreadsheet/widget/quiz_type_choice.dart';
import 'package:quiz_spreadsheet/widget/quiz_type_marubatu.dart';
import 'package:quiz_spreadsheet/widget/quiz_type_text_select.dart';
import 'package:quiz_spreadsheet/widget/shindan_choice.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Play extends StatefulWidget {
  final int titleNum;
  final Map quizData;
  final bool isShindan;

  const Play({
    Key? key,
    required this.titleNum,
    required this.quizData,
    required this.isShindan,
  }) : super(key: key);

  @override
  State<Play> createState() => _PlayState();
}

class _PlayState extends State<Play> {
  int num = 0;
  String title = "";
  List quizzes = [];
  List results = [];
  List shindanAnswers = [];
  bool isShindan = false;
  String answer = "";
  int correctNum = 0;
  bool shindanDisplay = false;

  late Timer _timer;
  var _timeValue = 1.0;
  var _timeValueView = 1.0;
  var _timeValueFlg = true;
  var timeout = const Duration(milliseconds: 1000);
  bool isTime = kIsTime;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  bool readyReward = false;
  int maxFailedLoadAttempts = 3;

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? kIsRelease
                ? kAdmobIdReward
                : 'ca-app-pub-3940256099942544/5224354917'
            : 'ca-app-pub-3940256099942544/1712485313',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            readyReward = true;
            setState(() {});
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );
    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Result(
            titleNum: widget.titleNum,
            title: title,
            quizNum: quizzes.length,
            correctNum: correctNum,
            results: results,
            shindanAnswers: shindanAnswers,
            isShindan: isShindan,
          ),
        ),
      );
    });
    _rewardedAd = null;
  }

  final player = AudioPlayer();

  bool isAudio = true;

  void getSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isAudio = prefs.getBool("audio") ?? isAudio;
  }

  void setSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("audio", isAudio);
  }

  final MyInterstitialPlay _myInterstitialPlay =
      MyInterstitialPlay(kAdmobIdInterstitialPlay);

  @override
  void initState() {
    getSetting();
    _myInterstitialPlay.createInterstitialAd();
    title = widget.quizData["title"];
    quizzes = widget.quizData["quizzes"];
    results = widget.quizData["results"];
    isShindan = widget.isShindan;
    if (isShindan) _createRewardedAd();
    if (isShindan) {
      isTime = false;
      shindanAnswers = List.generate(results.length, (i) => 0);
    } else {
      if (isTime) startTimer();
      if (kIsQuizRandom) quizzes.shuffle();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (isTime) _timer.cancel();
    if (isAudio) player.dispose();
    _myInterstitialPlay.interstitialAd?.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(timeout, (Timer timer) {
      if (_timeValue <= 0 || !_timeValueFlg) return;
      setState(() {
        _timeValue = _timeValue - (1 / kLimitTime);
        if (_timeValueFlg) _timeValueView = _timeValue;
        if (_timeValue <= 0) {
          checkAnswer(false);
        }
      });
    });
  }

  void next() {
    answer = "";
    num++;
    if (isTime) {
      _timeValue = 1.0;
      _timeValueFlg = true;
      _timeValueView = 1.0;
      _timer.cancel();
      startTimer();
    }
    setState(() {});
  }

  void checkAnswer(bool correct) {
    if (isTime) {
      _timeValueFlg = false;
      _timeValueView = _timeValue;
    }
    if (correct) {
      answer = "正解！";
      if (isAudio) player.setAsset("assets/sound/correct.mp3");
    } else {
      answer = "残念！";
      if (isAudio) player.setAsset("assets/sound/wrong.mp3");
    }
    if (isAudio) player.play();
    if (correct) correctNum++;
    setState(() {});
  }

  void checkShindan(List answerList) {
    if (isAudio) {
      player.setAsset("assets/sound/select.mp3");
      player.play();
    }
    for (int i = 0; i < answerList.length; i++) {
      shindanAnswers[i] += answerList[i];
    }
    if (num + 1 > quizzes.length - 1) {
      shindanDisplay = true;
    } else {
      num++;
    }
    setState(() {});
  }

  Widget quizType() {
    if (isShindan) {
      return ShindanChoice(
        choiceList: quizzes[num]["choice"],
        checkShindan: checkShindan,
      );
    }
    if (quizzes[num].containsKey("text_select") &&
        quizzes[num]["text_select"] != "") {
      return QuizTypeTextSelect(
        textSelect: quizzes[num]["text_select"],
        textChoice: quizzes[num]["text_choice"],
        checkAnswer: checkAnswer,
      );
    } else if (quizzes[num].containsKey("marubatu") &&
        quizzes[num]["marubatu"] != "") {
      return QuizTypeMarubatu(
        marubatu: quizzes[num]["marubatu"],
        checkAnswer: checkAnswer,
      );
    } else if (quizzes[num].containsKey("choice") &&
        quizzes[num]["choice"] != "") {
      return QuizTypeChoice(
        choiceList: quizzes[num]["choice"],
        checkAnswer: checkAnswer,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isTime) _timer.cancel();
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
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Card(
                                      elevation: 0,
                                      color: Colors.white.withOpacity(0.7),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          "$title 第${num + 1}問",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    color: Colors.black54,
                                    icon: const Icon(Icons.settings),
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
                                  ),
                                ],
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height / 3,
                                ),
                                child: Card(
                                  color: Colors.black.withOpacity(0.7),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(22),
                                    child: Text(
                                      quizzes[num]["quiz"],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (isTime)
                                Container(
                                  height: 12,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: LinearProgressIndicator(
                                    value: _timeValueView,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      kPrimaryColor,
                                    ),
                                    backgroundColor: kPrimaryColorSwatch[50],
                                  ),
                                ),
                              const SizedBox(height: 6),
                              answer == ""
                                  ? quizType()
                                  : Card(
                                      color: Colors.black.withOpacity(0.7),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              answer,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              quizzes[num]["comment"],
                                              style: const TextStyle(
                                                fontSize: 22,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              // margin: const EdgeInsets.all(10),
                                              width: double.infinity,
                                              height: 50,
                                              child: MaterialButton(
                                                color: kPrimaryColor,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  "Next",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (num <
                                                      quizzes.length - 1) {
                                                    next();
                                                  } else {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Result(
                                                          titleNum:
                                                              widget.titleNum,
                                                          title: title,
                                                          quizNum:
                                                              quizzes.length,
                                                          correctNum:
                                                              correctNum,
                                                          results: results,
                                                          shindanAnswers: const [],
                                                          isShindan: false,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        if (shindanDisplay)
                          Container(
                            color: Colors.black.withOpacity(0.9),
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                const Text(
                                  "集計を行います。集計中は動画が流れます。"
                                  "※中断すると集計がキャンセルされます。",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Card(
                                    color: readyReward
                                        ? kPrimaryColor
                                        : Colors.grey,
                                    margin: EdgeInsets.zero,
                                    child: MaterialButton(
                                      height: 60,
                                      padding: EdgeInsets.zero,
                                      child: const Text(
                                        "集計する",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      onPressed: () {
                                        _showRewardedAd();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
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
