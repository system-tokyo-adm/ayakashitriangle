import 'package:flutter/material.dart';
import 'package:quiz_spreadsheet/const.dart';

class QuizTypeMarubatu extends StatefulWidget {
  final String marubatu;
  final Function checkAnswer;

  const QuizTypeMarubatu({
    Key? key,
    required this.marubatu,
    required this.checkAnswer,
  }) : super(key: key);

  @override
  State<QuizTypeMarubatu> createState() => _QuizTypeMarubatuState();
}

class _QuizTypeMarubatuState extends State<QuizTypeMarubatu> {
  bool answer = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          for (var item in ["○", "×"])
            Expanded(
              child: Card(
                color: Colors.white,
                child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Icon(
                      item == "○" ? Icons.circle_outlined : Icons.close,
                      color: kPrimaryColor,
                      size: 100,
                    ),
                  ),
                  onTap: () {
                    widget.checkAnswer(widget.marubatu == item);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
