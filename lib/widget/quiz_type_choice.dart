import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../const.dart';

class QuizTypeChoice extends StatefulWidget {
  final List choiceList;
  final Function checkAnswer;

  const QuizTypeChoice({
    Key? key,
    required this.choiceList,
    required this.checkAnswer,
  }) : super(key: key);

  @override
  State<QuizTypeChoice> createState() => _QuizTypeChoiceState();
}

class _QuizTypeChoiceState extends State<QuizTypeChoice> {
  List choiceList = [];
  List selectList = [];
  List answerList = [];
  int selectNum = 0;
  int answerNum = 0;

  @override
  void initState() {
    choiceList = widget.choiceList;
    if (kIsChoiceRandom) choiceList.shuffle();
    for (var choice in choiceList) {
      answerList.add(choice[1]);
      selectList.add(false);
      if (choice[1]) answerNum++;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: choiceList.length,
      itemBuilder: (context, index) {
        return Card(
          color: selectList[index] ? kPrimaryColor : Colors.white,
          child: MaterialButton(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              constraints: const BoxConstraints(
                minHeight: 56,
              ),
              child: Center(
                child: Text(
                  choiceList[index][0],
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            onPressed: () {
              selectList[index] = !selectList[index];
              selectList[index] ? selectNum++ : selectNum--;
              if (selectNum >= answerNum) {
                widget.checkAnswer(listEquals(answerList, selectList));
              }
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
