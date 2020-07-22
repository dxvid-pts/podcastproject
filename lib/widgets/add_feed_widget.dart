import 'package:flutter/material.dart';

class AddFeedWidget extends StatefulWidget {
  final Function onSubmit;

  const AddFeedWidget({Key key, this.onSubmit}) : super(key: key);

  @override
  _AddFeedWidgetState createState() => _AddFeedWidgetState();
}

class _AddFeedWidgetState extends State<AddFeedWidget> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: myController,
        ),
        RaisedButton(
          onPressed: (){
            widget.onSubmit(myController.text);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
