import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;

class SelecionarAtividade extends StatefulWidget {

  Projeto projeto;
  Usuario usuarioLogado;

  SelecionarAtividade(this.projeto, this.usuarioLogado);

  @override
  _SelecionarAtividadeState createState() => _SelecionarAtividadeState();
}

class _SelecionarAtividadeState extends State<SelecionarAtividade> {

  HelperDB helperDB = HelperDB();

  List<ApontamentoTask> apontamentoTasks = [];

  bool carregando = true;

  void initState(){
    super.initState();
    LoadAtividades();
  }

  LoadAtividades() async {
    if (widget.usuarioLogado.WorkOffline == "1"){
      helperDB.getAllApontamentoTask().then((_apotamentoTasks) async {

        List<ApontamentoTask> temp = [];

        List<Apontamento> apontamentos = await helperDB.getApontamentosByProjectUID(widget.projeto.ProjectUID);

        for (var apontamentoTask in _apotamentoTasks){

          List<ApontamentoAssignment> list = [];

          for (var apontamentoAssignment in apontamentoTask.Assignments){
            Apontamento ap = apontamentos.firstWhere((x) => x.TaskUID == apontamentoTask.TaskUID && x.TimeByDay == apontamentoAssignment.TimeByDay, orElse: () => null);

            if (ap == null)
              list.add(apontamentoAssignment);
          }

          if (list.length > 0){
            apontamentoTask.Assignments = list;
            temp.add(apontamentoTask);
          }
        }

        setState(() {
          apontamentoTasks = temp;
          carregando = false;
        });
      });
    }
    else  {
      http.Response response;
      response = await http.get(baseApiURL + "Apontamento/GetTasks/?ProjectUID=" + widget.projeto.ProjectUID + "&ResourceUID=" + widget.usuarioLogado.ResourceUID);

      if (response.statusCode == 200){
        var apotamentoTasks = json.decode(response.body);

        List<ApontamentoTask> temp = [];

        List<Apontamento> apontamentos = await helperDB.getApontamentosByProjectUID(widget.projeto.ProjectUID);

        for (var item in apotamentoTasks){
          ApontamentoTask apontamentoTask = ApontamentoTask();
          apontamentoTask.ProjectUID = widget.projeto.ProjectUID;
          apontamentoTask.TaskUID = item["TaskUID"];
          apontamentoTask.TaskName = item["TaskName"];
          apontamentoTask.Assignments = [];

          for (var item_assignment in item["Assignments"]){
            ApontamentoAssignment apontamentoAssignment = ApontamentoAssignment();
            apontamentoAssignment.TaskUID = apontamentoTask.TaskUID;
            apontamentoAssignment.AssignmentUID = item_assignment["AssignmentUID"];
            apontamentoAssignment.TrabalhoPrevisto = item_assignment["TrabalhoPrevisto"];
            apontamentoAssignment.strTrabalhoPrevisto = item_assignment["strTrabalhoPrevisto"];
            apontamentoAssignment.TimeByDay = item_assignment["TimeByDay"];

            Apontamento ap = apontamentos.firstWhere((x) => x.TaskUID == apontamentoTask.TaskUID && x.TimeByDay == apontamentoAssignment.TimeByDay, orElse: () => null);

            if (ap == null)
              apontamentoTask.Assignments.add(apontamentoAssignment);
          }

          if (apontamentoTask.Assignments.length > 0)
            temp.add(apontamentoTask);
        }

        setState(() {
          apontamentoTasks = temp;
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecione a Atividade"),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1)
      ),
      body: carregando && apontamentoTasks.length == 0 ?
      Center(
        child: CircularProgressIndicator(),
      )
      :
      !carregando && apontamentoTasks.length == 0 ?
      Center(
        child: Text("Nenhuma Atividade para Apontar"),
      )
      :
      ListView.builder(
          itemCount: apontamentoTasks.length,
          itemBuilder: (context, index){

            List<ApontamentoAssignment> assignments = apontamentoTasks[index].Assignments;

            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: Text(
                      apontamentoTasks[index].TaskName,
                      style: TextStyle(
                          fontSize: 16.0
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.all(5.0),
                    itemCount: assignments.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index){

                      DateTime timeByDay = DateTime.parse(assignments[index].TimeByDay);

                      return
                        GestureDetector(
                            onTap: (){
                              Apontamento apotamento = Apontamento();
                              apotamento.TaskUID = assignments[index].TaskUID;
                              apotamento.TaskName = apontamentoTasks.firstWhere((x) => x.TaskUID == assignments[index].TaskUID).TaskName;
                              apotamento.AssignmentUID = assignments[index].AssignmentUID;
                              apotamento.TimeByDay = assignments[index].TimeByDay;

                              Navigator.pop(context, apotamento);
                            },
                            child: Card(
                              child: ListTile(
                                title: Text("${timeByDay.day}/${timeByDay.month}/${timeByDay.year}"),
                                subtitle: Text("${assignments[index].strTrabalhoPrevisto}"),
                              )
                            )
                        );
                    },
                  )
                ],
              ),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.black12)
                  )
              ),
            );
          }
      )
    );
  }
}
