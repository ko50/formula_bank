import 'package:flutter/material.dart';
import '../home/home.dart';
import '../preview/preview.dart';

Map fomulaListMap = {"Math": [], "Physics": [], "Chemistory": []};
String fomulaName;
Map tagMap = {};
List tags = [];
Map componentsMap = {};
Map components = {};
String body;
String propety;
bool paint;

class Datail extends StatefulWidget {
  @override
  _DatailState createState() => _DatailState();
}
class _DatailState extends State<Datail> {
  var _addingfomulacontroller = TextEditingController();
  var _editingTagcontroller= TextEditingController();

  // ListViewを構築する要素
  int _currentIndex = 0;
  String _labelText;
  List _labelTags;
  String _labelTag;
  String _textFieldState = "add";
  List _fomulaList = fomulaListMap[subject];

  // 式名とタグを編集するときに値を避難させる
  String _originalBody;
  String _originalPropety;
  bool _originalPaint;

  // 243行目と264行目の処理をまとめた
  void _addComponents(String text) => componentsMap.addAll({text: {"body": body, "propety": propety, "paint": paint}});

  // お気に入りボタン   色がついている状態だと式を削除できない
  Widget starIcon(int index, String name) {
    paint = componentsMap[name]["paint"];
    if(paint==false){
      return IconButton(
        icon: Icon(Icons.star),
        color: Colors.grey,
        onPressed: () {
          setState(() {
            paint = true;
            componentsMap[name]["paint"] = paint;
          });
        },
      );
    }
    else{
      return IconButton(
        icon: Icon(Icons.star),
        color: Colors.yellow,
        onPressed: () {
          setState(() {
            paint = false;
            componentsMap[name]["paint"] = paint;
          });
        },
      );
    }
  }

  // ListView
  Widget _buildListView() {
    // 式が一つもなかったら式を追加するようメッセージを表示
    if(_fomulaList.length==0){
      return Expanded(
        child: Container(
          child: Center(
            child: Text(
              "Please Add Some fomula",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    // 式名とタグ、ボタン二つのRowのリスト
    else{
      return Expanded(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            _labelText = _fomulaList[index];
            _labelTags = tagMap[_labelText] ??= ["null"];
            _labelTag = _labelTags.join("/");
            return GestureDetector(
              onTap: () {
                fomulaName = _fomulaList[index];
                tags = tagMap[fomulaName] ??= ["null"]; // ここはいらないかも
                components = componentsMap[fomulaName];
                body = components["body"] ??= "null";
                propety = components["propety"] ??= "null";
                paint = components["paint"];
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Preview())
                );
              },
              child: Container(
                height: 70,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                _labelText,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 35,
                                  child: Text(
                                    "Tag:",
                                    style: TextStyle(fontSize: 12,color: Colors.grey),
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  child: Text(
                                    _labelTag,
                                    style: TextStyle(fontSize: 15,color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    starIcon(index, _fomulaList[index]),
                    MaterialButton(
                      child: Icon(Icons.settings),
                      onPressed: () {
                        setState(() {
                          fomulaName = _fomulaList[index];
                          _addingfomulacontroller = TextEditingController(text: fomulaName);
                          _editingTagcontroller = TextEditingController(text: _labelTag ??= "null");
                          components = componentsMap[fomulaName];
                          _originalBody = components["body"];
                          _originalPropety = components["propety"];
                          _originalPaint = components["paint"];
                          _currentIndex = index;
                          _textFieldState = "edit";
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: _fomulaList.length,
        ),
      );
    }
  }

  // テキストフィールドを管理
  Widget _textFields() {
    // 新しく式を追加する
    if(_textFieldState=="add"){
      return Expanded(
        child: TextField(
          enabled: true,
          decoration: InputDecoration(
            labelText: "add a fomula",
            hintText: "(only space, remove)"
          ),
          controller: _addingfomulacontroller,
        ),
      );
    }
    // 式名、タグを編集
    else{
      return Expanded(
        child: Row(
          children: <Widget>[
            // 式名編集
            Expanded(
              flex: 1,
              child: TextField(
                enabled: true,
                decoration: InputDecoration(
                  labelText: "add a fomula",
                  hintText: "(only space, remove)",
                ),
                controller: _addingfomulacontroller,
              ),
            ),
            // タグ編集
            Expanded(
              flex: 1,
              child: TextField(
                enabled: true,
                decoration: InputDecoration(
                  labelText: "edit tag",
                  hintText: "(separate with '/')"
                ),
                controller: _editingTagcontroller,
              ),
            ),
          ],
        ),
      );
    }
  }
  // テキストフィールド横のボタンを管理
  MaterialButton _difineSaveOrChange(int index) {
    // 新しく式を追加する
    if(_textFieldState=="add"){
      return MaterialButton(
        height: 20,
        minWidth: 20,
        child: Icon(Icons.add),
        onPressed: () {
          // 式の追加
          setState(() {
            if(_addingfomulacontroller.text.trim()!=""){
              _fomulaList.add(_addingfomulacontroller.text);
              tagMap.addAll({_addingfomulacontroller.text: []});
              body = "";
              propety = "";
              paint = false;
              _addComponents(_addingfomulacontroller.text);
              _addingfomulacontroller.text = "";
            }
          });
        },
      );
    }
    // 変更後の式名、タグを保存
    else{
      return MaterialButton(
        height: 20,
        minWidth: 20,
        child: Icon(Icons.save),
        onPressed: () {
          setState(() {
            tagMap.remove(fomulaName);
            componentsMap.remove(fomulaName);
            fomulaName = _addingfomulacontroller.text;
            if(fomulaName.trim()!=""){
              body = _originalBody;
              propety = _originalPropety;
              paint = _originalPaint;
              _addComponents(fomulaName);
              tagMap.addAll({fomulaName: _editingTagcontroller.text.split("/")});
              tags = tagMap[fomulaName] ??= ["null"];
              _fomulaList[index] = fomulaName;
            }
            else{
              if(paint==true){
                _fomulaList[index] = _originalBody ??= "null";
                tagMap.addAll({fomulaName: _editingTagcontroller.text.split("/")});
                tags = tagMap[fomulaName] ??= ["null"];
              }
              else{_fomulaList.remove(fomulaName);}
            }
            _addingfomulacontroller.text = "";
            _editingTagcontroller.text = "";
            _textFieldState = "add";
          });
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(datailtitle),
      ),
      body: Column(
        children: <Widget>[
          _buildListView(), // リスト
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1.0,color: Colors.grey)),
            ),
            child: Row(
              children: <Widget>[
                _textFields(),
                _difineSaveOrChange(_currentIndex), // ボタン
              ],
            ),
          ),
        ],
      ),
    );
  }
}