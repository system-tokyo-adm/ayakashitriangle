import 'package:flutter/material.dart';
import 'package:quiz_spreadsheet/const.dart';

class QuizTypeTextSelect extends StatefulWidget {
  final String textSelect;
  final String textChoice;
  final Function checkAnswer;

  const QuizTypeTextSelect({
    Key? key,
    required this.textSelect,
    required this.textChoice,
    required this.checkAnswer,
  }) : super(key: key);

  @override
  State<QuizTypeTextSelect> createState() => _QuizTypeTextSelectState();
}

class _QuizTypeTextSelectState extends State<QuizTypeTextSelect> {
  String answer = "";
  List choiceList = [];
  List selectList = [];
  int selectNum = 0;

  @override
  void initState() {
    answer = widget.textSelect;
    String choice = answer;
    if(widget.textChoice != ""){
      choice = widget.textChoice;
    }
    choiceList = choice.split("");
    choiceList.shuffle();
    selectList = List.generate(answer.length, (i) => "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GridView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: answer.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Center(
                  child: Text(
                    selectList[index],
                    style: const TextStyle(
                      fontSize: 22,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            color: kPrimaryColor,
            icon: const Icon(Icons.backspace),
            iconSize: 60,
            onPressed: () {
              if (selectNum > 0) selectList[--selectNum] = "";
              setState(() {});
            },
          ),
        ),
        GridView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: choiceList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: MaterialButton(
                  child: Text(
                    choiceList[index],
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (selectNum < selectList.length) {
                      selectList[selectNum++] = choiceList[index];
                      setState(() {});
                      if (selectNum == selectList.length) {
                        widget.checkAnswer(answer == selectList.join());
                      }
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
