import 'package:flutter/material.dart';

import '../input_fomula_data/input_fomula_data.dart';
import '../datail/detail.dart';
import '../widgets/dialogs.dart';
import '../widgets/drawer.dart';

import '../../data_manager_class/subject.dart';
import '../../data_manager_class/fomula.dart';

class Preview extends StatefulWidget {
  final Subject subject;
  final int parentIndex;
  late final List fomulaList;

  Preview({required this.subject, required this.parentIndex}) {
    this.fomulaList = subject.fomulaList;
  }

  @override
  _PreviewState createState() => _PreviewState(subject, fomulaList, parentIndex);
}
class _PreviewState extends State<Preview> {
  Subject subject;
  List fomulaList;
  int parentIndex;

  _PreviewState(this.subject, this.fomulaList, this.parentIndex);

  Widget fomulaListView() {
    if(fomulaList.length==0) {
      return Center(child: Text("公式が一つもありません"));
    }else{
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Fomula fomula = fomulaList[index];
          Color color = fomula.liked ? Colors.yellow : Colors.grey;
          bool isDelete;
          return Container(
            child: ListTile(
              title: Text("${fomula.name}"),
              subtitle: Text("${fomula.expression}\ntag: ${fomula.tagList}", style: TextStyle(fontSize: 12),),
              trailing: IconButton(
                color: color,
                onPressed: () {
                  fomula.changeLike(fomula.liked);
                  setState(() {
                    color = fomula.liked ? Colors.yellow : Colors.grey;
                  });
                },
                icon: Icon(Icons.star),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<Widget>(builder: (BuildContext context) => Datail(
                    childIndex: index,
                    parentIndex: parentIndex,
                    parentSubject: subject,
                    fomula: fomula,
                  ))
                );
              },
              onLongPress: () async{
                isDelete = await confirmDeleteFomulaDialog(context);
                if(isDelete && !fomula.liked) {
                  List<Subject> subjectList = await SubjectPrefarence.getSubjectList();
                  setState(() {
                    subject.fomulaList.removeAt(index);
                  });
                  subjectList[parentIndex] = subject;
                  await SubjectPrefarence.saveSubjectList(subjectList);
                }
              },
            ),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
          );
        },
        itemCount: fomulaList.length,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GeneralDrawer(),
      appBar: AppBar(
        title: Text("Preview Fomulas in ${subject.name}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async{
              Fomula newFomula = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => AddFomulaPage(subjectIndex: parentIndex)
                ),
              );
              if(newFomula!=null) {
                setState(() {
                  subject.fomulaList.add(newFomula);
                });
                List<Subject> subjectList = await SubjectPrefarence.getSubjectList();
                subjectList[parentIndex] = subject;
                SubjectPrefarence.saveSubjectList(subjectList);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: fomulaListView(),
          ),
        ],
      ),
    );
  }
}