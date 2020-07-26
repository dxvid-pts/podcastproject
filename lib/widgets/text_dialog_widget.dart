import 'package:flutter/material.dart';

typedef OnSubmit(String text);

class TextDialogWidget extends StatefulWidget {
  final String title, hint, cancelButtonText, okButtonText;
  final OnSubmit onSubmit;

  const TextDialogWidget(
      {Key key,
      @required this.title,
      @required this.hint,
      this.cancelButtonText = 'Cancel',
      @required this.okButtonText,
      @required this.onSubmit})
      : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  final TextEditingController _textFieldController = TextEditingController();
  bool _validate = false;

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(
          hintText: widget.hint,
          labelText: 'Enter the Value',
          errorText: _validate ? 'Value Can\'t Be Empty' : null,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(widget.cancelButtonText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(widget.okButtonText),
          onPressed: () {
            var text = _textFieldController.text;

            if (text.isEmpty)
              setState(() {
                _validate = true;
              });
            else
              widget.onSubmit(text);
          },
        ),
      ],
    );
  }
}
