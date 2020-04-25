import 'package:flutter/material.dart';

import './_exporter.dart';
import '../models/_exporter.dart';
import '../tools/_exporter.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}
class _SearchState extends State<Search> {
  List<Subject> subjectList;
  List<String> searchKeys;
  List result = [];

  List search() {
    List _result = [];
    subjectList.forEach((subject) {
      searchKeys.forEach((key) {
        for(Fomula fomula in subject.fomulaList) {
          if(key==fomula.name) {
            _result.add(fomula);
            continue;
          }
          if(fomula.tagList.contains(key)) _result.add(fomula);
        }
      });
    });
    return _result;
  }

  Widget searchedResultListView() {
    if(result.length==0) {
      return Text("検索結果は一つもありませんでした");
    }else{
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Fomula fomula = result[index];
          Color color = fomula.liked ? Colors.yellow : Colors.grey;
          return ListTile(
            title: Text("${fomula.name}"),
            trailing: IconButton(
              color: color,
              onPressed: () {
                fomula.changeLike(!fomula.liked);
                setState(() {
                  color = fomula.liked ? Colors.yellow : Colors.grey;
                });
              },
              icon: Icon(Icons.star),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        title: Text("全体検索"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(4.0),
              child: Row(
                children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration.collapsed(hintText: "Search your fomula"),
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchKeys = controller.text.split(" ");
                      setState(() {
                        result = search();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: SubjectPrefarence.getSubjectList(),
            builder: (BuildContext context, AsyncSnapshot<List<Subject>> snapshot) {
              if(!snapshot.hasData) {
                return Text("データがありません");
              }else{
                subjectList = snapshot.data;
                return Expanded(child: searchedResultListView(),);
              }
            }
          ),
        ],
      ),
    );
  }
}