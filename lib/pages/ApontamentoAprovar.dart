import 'dart:convert';

import 'package:alert/alert.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

class ApontamentoAprovar extends StatefulWidget {

  Map apontamento;

  ApontamentoAprovar(this.apontamento);

  @override
  _ApontamentoAprovarState createState() => _ApontamentoAprovarState();
}

class _ApontamentoAprovarState extends State<ApontamentoAprovar> {

  ProgressDialog loading;

  Map map_remove;

  AprovarReprovarTask(ApontamentoAprovacaoPOST apontamentoAprovacaoPOST) async {
    await loading.show();

    http.post(
        baseApiURL + "Apontamento/SalvarAprovacao",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(apontamentoAprovacaoPOST)
    ).then((response) async {

      await loading.hide();

      if (response.statusCode == 200){
        String qtd = response.body;

        if (qtd == "0"){
          Alert(message: "Operação relizada com sucesso!").show();
        }
        else {
          AlertDialog alert = AlertDialog(
            title: Text("Atenção"),
            content: Text("Um ou mais Apontamentos já foram aprovados ou reprovados anteriormente, portanto não tiveram alterações."),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          );

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }

        Navigator.pop(context);
      }
      else  {
        Alert(message: 'Erro ao enviar. ${response.body}').show();
      }
    });
  }

  AprovarReprovarApontamento(ApontamentoAprovacaoPOST apontamentoAprovacaoPOST) async {
    await loading.show();

    http.post(
        baseApiURL + "Apontamento/SalvarAprovacao",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(apontamentoAprovacaoPOST)
    ).then((response) async {

      await loading.hide();

      if (response.statusCode == 200){
        String qtd = response.body;

        if (qtd == "0"){
          Alert(message: "Operação relizada com sucesso!").show();
        }
        else {
          AlertDialog alert = AlertDialog(
            title: Text("Operação não realizada"),
            content: Text("Não é possível aprovar ou reprovar este Apontamento, pois essa operação já foi realizada."),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          );

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }

        if (widget.apontamento["Apontamentos"].length > 1) {
          setState(() {
            widget.apontamento["Apontamentos"].remove(map_remove);
          });
        }
        else {
          Navigator.pop(context);
        }
      }
      else  {
        Alert(message: 'Erro ao enviar. ${response.body}').show();
      }
    });
  }

  Future<String> _createConfirmDialog(BuildContext context){
    TextEditingController controller = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Atenção"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text("Tem certeza que deseja Reprovar este Apontamento? É necessário informar uma justificativa."),
              SizedBox(height: 10.0),
              TextField(
                controller: controller,
                maxLines: 4,
              )
            ],
          ),
        ),
        actions: <Widget> [
          MaterialButton(
              child: Text("Reprovar"),
              elevation: 5.0,
              onPressed: () async {
                if (controller.text.toString().isEmpty){
                  await Alert(message: "Informe a Justificativa").show();
                }
                else {
                  Navigator.of(context).pop(controller.text.toString());
                }
              }
          ),
          MaterialButton(
              child: Text("Cancelar"),
              elevation: 5.0,
              onPressed: (){
                Navigator.of(context).pop("");
              }
          )
        ],
      );
    });
  }

  Widget _builderListViewApontamentos(){
    return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: widget.apontamento["Apontamentos"].length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index){

          DateTime NewTimeByDay = DateTime.parse(widget.apontamento["Apontamentos"][index]["NewTimeByDay"]);

          return Card(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(widget.apontamento["Apontamentos"][index]["ResourceName"],
                          style: TextStyle(fontSize: 15.0),
                        ),
                        alignment: Alignment.centerLeft,
                        width: 200.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("${NewTimeByDay.day}/${NewTimeByDay.month}/${NewTimeByDay.year}",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      SizedBox(height: 10.0),
                      Text(widget.apontamento["Apontamentos"][index]["HoraMinuto"],
                        style: TextStyle(fontSize: 14.0),
                      )
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Column(
                    children: [
                      RaisedButton(
                        child: Row(
                          children: [
                            Text("Aprovar"),
                            Icon(Icons.check)
                          ],
                        ),
                        onPressed: () async{
                          if (await confirm(
                              context,
                              title: Text("Atenção"),
                              content: Text("Tem certeza que deseja Aprovar este Apontamento?"),
                              textOK: Text("Sim"),
                              textCancel: Text("Não")
                          )
                          ) {
                            ApontamentoAprovacaoPOST apontamentoAprovacaoPOST = ApontamentoAprovacaoPOST();
                            apontamentoAprovacaoPOST.ProjectUID = widget.apontamento["ProjectUID"];
                            apontamentoAprovacaoPOST.ProjectName = widget.apontamento["ProjectName"];
                            apontamentoAprovacaoPOST.TaskUID = widget.apontamento["TaskUID"];
                            apontamentoAprovacaoPOST.TaskName = widget.apontamento["TaskName"];
                            apontamentoAprovacaoPOST.Assignments = [];

                            ApontamentoAssignmentAprovacaoPOST apontamentoAssignmentAprovacaoPOST = ApontamentoAssignmentAprovacaoPOST();
                            apontamentoAssignmentAprovacaoPOST.AssignmentUID = widget.apontamento["Apontamentos"][index]["AssignmentUID"];
                            apontamentoAssignmentAprovacaoPOST.ResourceUID = widget.apontamento["Apontamentos"][index]["ResourceUID"];
                            apontamentoAssignmentAprovacaoPOST.ResourceName = widget.apontamento["Apontamentos"][index]["ResourceName"];
                            apontamentoAssignmentAprovacaoPOST.TimeByDay = widget.apontamento["Apontamentos"][index]["TimeByDay"];
                            apontamentoAssignmentAprovacaoPOST.NewTimeByDay = widget.apontamento["Apontamentos"][index]["NewTimeByDay"];
                            apontamentoAssignmentAprovacaoPOST.StatusAprovacao = "Aprovado";
                            apontamentoAssignmentAprovacaoPOST.ObservacoesAprovacao = null;

                            apontamentoAprovacaoPOST.Assignments.add(apontamentoAssignmentAprovacaoPOST);

                            map_remove = widget.apontamento["Apontamentos"][index];

                            await AprovarReprovarApontamento(apontamentoAprovacaoPOST);
                          }
                        },
                      ),
                      RaisedButton(
                        child: Row(
                          children: [
                            Text("Reprovar"),
                            Icon(Icons.close)
                          ],
                        ),
                        onPressed: () async {
                          _createConfirmDialog(context).then((value) async {
                            if (value.isNotEmpty){
                              ApontamentoAprovacaoPOST apontamentoAprovacaoPOST = ApontamentoAprovacaoPOST();
                              apontamentoAprovacaoPOST.ProjectUID = widget.apontamento["ProjectUID"];
                              apontamentoAprovacaoPOST.ProjectName = widget.apontamento["ProjectName"];
                              apontamentoAprovacaoPOST.TaskUID = widget.apontamento["TaskUID"];
                              apontamentoAprovacaoPOST.TaskName = widget.apontamento["TaskName"];
                              apontamentoAprovacaoPOST.Assignments = [];

                              ApontamentoAssignmentAprovacaoPOST apontamentoAssignmentAprovacaoPOST = ApontamentoAssignmentAprovacaoPOST();
                              apontamentoAssignmentAprovacaoPOST.AssignmentUID = widget.apontamento["Apontamentos"][index]["AssignmentUID"];
                              apontamentoAssignmentAprovacaoPOST.ResourceUID = widget.apontamento["Apontamentos"][index]["ResourceUID"];
                              apontamentoAssignmentAprovacaoPOST.ResourceName = widget.apontamento["Apontamentos"][index]["ResourceName"];
                              apontamentoAssignmentAprovacaoPOST.TimeByDay = widget.apontamento["Apontamentos"][index]["TimeByDay"];
                              apontamentoAssignmentAprovacaoPOST.NewTimeByDay = widget.apontamento["Apontamentos"][index]["NewTimeByDay"];
                              apontamentoAssignmentAprovacaoPOST.StatusAprovacao = "Reprovado";
                              apontamentoAssignmentAprovacaoPOST.ObservacoesAprovacao = value;

                              apontamentoAprovacaoPOST.Assignments.add(apontamentoAssignmentAprovacaoPOST);

                              map_remove = widget.apontamento["Apontamentos"][index];

                              await AprovarReprovarApontamento(apontamentoAprovacaoPOST);
                            }
                          });
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    loading = ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false);

    loading.style(
        message: 'Enviando...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut
    );

    return Scaffold(
      appBar: AppBar(
          title: Text("Aprovação de Apontamentos"),
          backgroundColor: Color.fromRGBO(36, 177, 139, 1)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10.0),
              alignment: Alignment.center,
              child: Text(
                  "${widget.apontamento["ProjectName"]}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  )
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Row(
                    children: [
                      Text("Reprovar Todos"),
                      Icon(Icons.close)
                    ],
                  ),
                  onPressed: (){
                    _createConfirmDialog(context).then((value) async {
                      if (value.isNotEmpty){
                        ApontamentoAprovacaoPOST apontamentoAprovacaoPOST = ApontamentoAprovacaoPOST();
                        apontamentoAprovacaoPOST.ProjectUID = widget.apontamento["ProjectUID"];
                        apontamentoAprovacaoPOST.ProjectName = widget.apontamento["ProjectName"];
                        apontamentoAprovacaoPOST.TaskUID = widget.apontamento["TaskUID"];
                        apontamentoAprovacaoPOST.TaskName = widget.apontamento["TaskName"];
                        apontamentoAprovacaoPOST.Assignments = [];

                        for (Map map in widget.apontamento["Apontamentos"]){
                          ApontamentoAssignmentAprovacaoPOST apontamentoAssignmentAprovacaoPOST = ApontamentoAssignmentAprovacaoPOST();
                          apontamentoAssignmentAprovacaoPOST.AssignmentUID = map["AssignmentUID"];
                          apontamentoAssignmentAprovacaoPOST.ResourceUID = map["ResourceUID"];
                          apontamentoAssignmentAprovacaoPOST.ResourceName = map["ResourceName"];
                          apontamentoAssignmentAprovacaoPOST.TimeByDay = map["TimeByDay"];
                          apontamentoAssignmentAprovacaoPOST.NewTimeByDay = map["NewTimeByDay"];
                          apontamentoAssignmentAprovacaoPOST.StatusAprovacao = "Reprovado";
                          apontamentoAssignmentAprovacaoPOST.ObservacoesAprovacao = value;

                          apontamentoAprovacaoPOST.Assignments.add(apontamentoAssignmentAprovacaoPOST);
                        }

                        await AprovarReprovarTask(apontamentoAprovacaoPOST);
                      }
                    });
                  },
                ),
                SizedBox(width: 20.0),
                RaisedButton(
                  child: Row(
                    children: [
                      Text("Aprovar Todos"),
                      Icon(Icons.check)
                    ],
                  ),
                  onPressed: () async {
                    if (await confirm(
                        context,
                        title: Text("Atenção"),
                        content: Text("Tem certeza que deseja Aprovar este Apontamento?"),
                        textOK: Text("Sim"),
                        textCancel: Text("Não")
                    )
                    ) {
                      ApontamentoAprovacaoPOST apontamentoAprovacaoPOST = ApontamentoAprovacaoPOST();
                      apontamentoAprovacaoPOST.ProjectUID = widget.apontamento["ProjectUID"];
                      apontamentoAprovacaoPOST.ProjectName = widget.apontamento["ProjectName"];
                      apontamentoAprovacaoPOST.TaskUID = widget.apontamento["TaskUID"];
                      apontamentoAprovacaoPOST.TaskName = widget.apontamento["TaskName"];
                      apontamentoAprovacaoPOST.Assignments = [];

                      for (Map map in widget.apontamento["Apontamentos"]){
                        ApontamentoAssignmentAprovacaoPOST apontamentoAssignmentAprovacaoPOST = ApontamentoAssignmentAprovacaoPOST();
                        apontamentoAssignmentAprovacaoPOST.AssignmentUID = map["AssignmentUID"];
                        apontamentoAssignmentAprovacaoPOST.ResourceUID = map["ResourceUID"];
                        apontamentoAssignmentAprovacaoPOST.ResourceName = map["ResourceName"];
                        apontamentoAssignmentAprovacaoPOST.TimeByDay = map["TimeByDay"];
                        apontamentoAssignmentAprovacaoPOST.NewTimeByDay = map["NewTimeByDay"];
                        apontamentoAssignmentAprovacaoPOST.StatusAprovacao = "Aprovado";
                        apontamentoAssignmentAprovacaoPOST.ObservacoesAprovacao = null;

                        apontamentoAprovacaoPOST.Assignments.add(apontamentoAssignmentAprovacaoPOST);
                      }

                      await AprovarReprovarTask(apontamentoAprovacaoPOST);
                    }
                  },
                )
              ],
            ),
            _builderListViewApontamentos()
          ],
        ),
      ),
    );
  }
}
