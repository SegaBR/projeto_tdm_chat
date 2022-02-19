import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget{

  TextComposer(this.sendMessage);
  final Function({String text, XFile imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer>{
  final _textController = TextEditingController();
  bool _isComposing = false;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal:8.0),
            child: Row(
                children: <Widget>[
                  Container(
                    child: IconButton(icon: Icon(Icons.photo_camera),
                        onPressed: () async{
                          final img = await picker.pickImage(source: ImageSource.camera);
                          if(img == null)
                            return;
                          widget.sendMessage(imgFile: img);
                        }),
                  ),
                  Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration:
                        InputDecoration.collapsed(hintText: "Enviar uma mensagem..."),
                        onChanged: (text) {
                          setState(() {
                            _isComposing=text.length>0;
                          });
                        },
                        onSubmitted: (text) {
                          widget.sendMessage(text: _textController.text);
                          print(text);
                          _reset();
                        },
                      ),
                  ),
                  Container(
                    margin : const EdgeInsets.symmetric(horizontal:4.0),
                    child: IconButton(icon: Icon(Icons.send),
                      onPressed: _isComposing ? () {
                        widget.sendMessage(text: _textController.text);
                        print(_textController.text);
                        _reset();
                      } : null,
                    ),
                  ),
                ],
            ),
        ),
    );
  }

  void _reset(){
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

}