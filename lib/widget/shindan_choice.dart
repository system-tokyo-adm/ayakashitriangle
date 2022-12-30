import 'package:flutter/material.dart';

class ShindanChoice extends StatefulWidget {
  final List choiceList;
  final Function checkShindan;

  const ShindanChoice({
    Key? key,
    required this.choiceList,
    required this.checkShindan,
  }) : super(key: key);

  @override
  State<ShindanChoice> createState() => _ShindanChoiceState();
}

class _ShindanChoiceState extends State<ShindanChoice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: widget.choiceList.length,
      itemBuilder: (context, index) {
        return Card(
          child: MaterialButton(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              constraints: const BoxConstraints(
                minHeight: 56,
              ),
              child: Center(
                child: Text(
                  widget.choiceList[index][0],
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            onPressed: () {
              widget.checkShindan(widget.choiceList[index][1]);
            },
          ),
        );
      },
    );
  }
}
