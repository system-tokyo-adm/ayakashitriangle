import 'package:flutter/cupertino.dart';

List setQuizData(quizList, resultList) {
  // 結果データの設定
  Map resultAllMap = {};
  List resultTitleList = [];
  String resultTitle = "";
  for (int i = 1; i < resultList.length; i++) {
    List item = resultList[i];
    if (item.isEmpty) {
      resultAllMap[resultTitle] = resultTitleList;
      break;
    }
    if (item[0] != "") {
      if (resultTitleList.isNotEmpty) {
        resultAllMap[resultTitle] = resultTitleList;
      }
      resultTitle = item[0];
      resultTitleList = [];
    }
    Map resultMap = {};
    resultMap["percent"] = item.length <= 1 ? 0 : int.parse(item[1]);
    resultMap["result"] = item.length <= 2 ? "" : item[2];
    resultMap["comment"] = item.length <= 3 ? "" : item[3];
    resultTitleList.add(resultMap);
    if (i == resultList.length - 1) {
      resultAllMap[resultTitle] = resultTitleList;
    }
  }
  // クイズデータの設定
  List allList = [];
  Map titleMap = {};
  for (int i = 1; i < quizList.length; i++) {
    List item = quizList[i];
    if (item.isEmpty) {
      allList.add(titleMap);
      break;
    }
    if (item[0] != "") {
      if (titleMap.isNotEmpty) {
        allList.add(titleMap);
      }
      titleMap = {};
      titleMap["title"] = item[0];
      if (resultAllMap.containsKey(item[0])) {
        titleMap["results"] = resultAllMap[item[0]];
      } else if (resultAllMap.containsKey("全体")) {
        titleMap["results"] = resultAllMap["全体"];
      } else {
        titleMap["results"] = [];
      }
      titleMap["quizzes"] = [];
    }
    Map quizMap = {};
    quizMap["quiz"] = item.length <= 1 ? "" : item[1];
    quizMap["comment"] = item.length <= 2 ? "" : item[2];
    quizMap["text_select"] = item.length <= 3 ? "" : item[3];
    quizMap["text_choice"] = item.length <= 4 ? "" : item[4];
    quizMap["marubatu"] = item.length <= 5 ? "" : item[5];
    List choiceList = [];
    for (int j = 6; j < item.length; j = j + 2) {
      if (item[j] == "") break;
      var choice = [item[j], item[j + 1] == "TRUE"];
      choiceList.add(choice);
    }
    quizMap["choice"] = choiceList;
    titleMap["quizzes"].add(quizMap);
    if (i == quizList.length - 1) {
      allList.add(titleMap);
    }
  }
  return allList;
}

List setShindanData(shindanList) {
  List shindanAllList = [];
  Map shindanMap = {};
  int subNum = 0;
  Map quizMap = {};
  for (int i = 1; i < shindanList.length; i++) {
    List item = shindanList[i];
    if (item.isEmpty) {
      if (quizMap.isNotEmpty) {
        shindanMap["quizzes"].add(quizMap);
      }
      shindanAllList.add(shindanMap);
      break;
    }
    if (item[0] != "") {
      if (shindanMap.isNotEmpty) {
        if (quizMap.isNotEmpty) {
          shindanMap["quizzes"].add(quizMap);
        }
        shindanAllList.add(shindanMap);
      }
      subNum = 0;
      shindanMap = {};
      shindanMap["title"] = item[0];
      shindanMap["results"] = [];
      shindanMap["quizzes"] = [];
    }
    if (subNum == 0) {
      for (int j = 3; j < item.length; j++) {
        shindanMap["results"].add({
          "result": item[j],
          "comment": shindanList[i + 1][j],
        });
      }
    } else if (subNum >= 2) {
      if (item[1] != "") {
        if (quizMap.isNotEmpty) {
          shindanMap["quizzes"].add(quizMap);
        }
        quizMap = {};
        quizMap["quiz"] = item[1];
        quizMap["choice"] = [];
      }
      List point = [];
      for (int j = 3; j < item.length; j++) {
        point.add(int.parse(item[j]));
      }
      quizMap["choice"].add([item[2], point]);
      if (i == shindanList.length - 1) {
        shindanMap["quizzes"].add(quizMap);
      }
    }
    subNum++;
    if (i == shindanList.length - 1) {
      shindanAllList.add(shindanMap);
    }
  }
  // debugPrint("asdfasdfsdf:" + shindanAllList.toString());
  return shindanAllList;
}
