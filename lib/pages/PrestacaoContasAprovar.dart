import 'dart:convert';
import 'package:alert/alert.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mvapp/validators/PrestacaoContasValidator.dart';

class PrestacaoContasAprovar extends StatefulWidget {

  Map prestacaoContas;

  PrestacaoContasAprovar(this.prestacaoContas);

  @override
  _PrestacaoContasAprovarState createState() => _PrestacaoContasAprovarState();
}

class _PrestacaoContasAprovarState extends State<PrestacaoContasAprovar>  with PrestacaoContasValidator {

  ProgressDialog loading;

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  Map map_remove;

  AprovarReprovarGrupo(PrestacaoContasAprovacaoPOST prestacaoContasAprovacaoPOST) async {
    await loading.show();

    http.post(
        baseApiURL + "PrestacaoContas/AprovarReprovarPrestacaoContas",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(prestacaoContasAprovacaoPOST)
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
            content: Text("Uma ou mais PCs já foram aprovadas ou reprovadas anteriormente, portanto não tiveram alterações."),
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

  AprovarReprovarPC(PrestacaoContasAprovacaoPOST prestacaoContasAprovacaoPOST) async {
    await loading.show();

    http.post(
        baseApiURL + "PrestacaoContas/AprovarReprovarPrestacaoContas",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(prestacaoContasAprovacaoPOST)
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
            content: Text("Não é possível aprovar ou reprovar esta PC, pois essa operação já foi realizada."),
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

        if (widget.prestacaoContas["_PrestacaoContas"].length > 1) {
          setState(() {
            widget.prestacaoContas["_PrestacaoContas"].remove(map_remove);
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
              Text("Tem certeza que deseja Reprovar esta PC? É necessário informar uma justificativa."),
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

  List<PrestacaoContas> pcs_glosas = [];

  Future _createGlosaDialog(BuildContext context, String prestacaoContasUID){
    PrestacaoContas pc_glosa = pcs_glosas.length > 0 ? pcs_glosas.firstWhere((element) => element.PrestacaoContasUID == prestacaoContasUID, orElse: (){return null;}) : null;

    MoneyMaskedTextController ValorController = new MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', initialValue: pc_glosa != null ? pc_glosa.Valor : 0);
    TextEditingController ObservacoesController = TextEditingController(text: pc_glosa != null ? pc_glosa.JustificativaGP : "");
    final _formKey = GlobalKey<FormState>();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Deseja editar o valor da PC?"),
        content: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Valor"),
                  ),
                  TextFormField(
                    controller: ValorController,
                    keyboardType: TextInputType.number,
                    validator: validateValor,
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Justificativa"),
                  ),
                  TextFormField(
                    controller: ObservacoesController,
                    maxLines: 4,
                    validator: validateObservacoes,
                  )
                ],
              )
          )
        ),
        actions: <Widget> [
          MaterialButton(
            child: Text("Ok"),
            elevation: 5.0,
            onPressed: () async {
              if (_formKey.currentState.validate()){
                setState(() {
                  PrestacaoContas pc = pcs_glosas.length > 0 ? pcs_glosas.firstWhere((element) => element.PrestacaoContasUID == prestacaoContasUID, orElse: (){return null;}) : PrestacaoContas();
                  if (pc != null && pc.PrestacaoContasUID == prestacaoContasUID){
                    pc.Valor = ValorController.numberValue;
                    pc.JustificativaGP = ObservacoesController.text;
                  }
                  else {
                    pc = PrestacaoContas();
                    pc.PrestacaoContasUID = prestacaoContasUID;
                    pc.Valor = ValorController.numberValue;
                    pc.JustificativaGP = ObservacoesController.text;
                    pcs_glosas.add(pc);
                  }
                });

                Navigator.of(context).pop();
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

  Widget _builderListViewPrestacaoContas(){
    return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: widget.prestacaoContas["_PrestacaoContas"].length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index){

          DateTime data = DateTime.parse(widget.prestacaoContas["_PrestacaoContas"][index]["Data"]);

          PrestacaoContas pc_glosa = pcs_glosas.length > 0 ? pcs_glosas.firstWhere((element) => element.PrestacaoContasUID == widget.prestacaoContas["_PrestacaoContas"][index]["PrestacaoContasUID"], orElse: (){return null;}) : null;

          return Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 250.0,
                        child: Text("${widget.prestacaoContas["_PrestacaoContas"][index]["NomeDespesa"]}",
                          style: TextStyle(fontSize: 15.0)
                        )
                      ),
                      Spacer(),
                      Container(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                          child: GestureDetector(
                            child: Icon(Icons.mode_comment_outlined),
                            onTap: () {
                              AlertDialog alert = AlertDialog(
                                title: Text("Descrição"),
                                content: SingleChildScrollView(
                                  child: Text(widget.prestacaoContas["_PrestacaoContas"][index]["Descricao"]),
                                ),
                                actions: [
                                  FlatButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                    },
                                  )
                                ],
                              );

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            },
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Text("${data.day}/${data.month}/${data.year}",
                        style: TextStyle(fontSize: 15.0),
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Text(currency.format(widget.prestacaoContas["_PrestacaoContas"][index]["Valor"]),
                        style: TextStyle(fontSize: 14.0, decoration: pc_glosa != null ? TextDecoration.lineThrough : TextDecoration.none),
                      ),
                      SizedBox(width: 10),
                      pc_glosa != null ?
                        Text(currency.format(pc_glosa.Valor),
                          style: TextStyle(fontSize: 14.0),
                        )
                      :
                        Container()
                      ,
                      SizedBox(width: 10),
                      GestureDetector(
                        child: Icon(Icons.edit, size: 18),
                        onTap: (){
                          _createGlosaDialog(context, widget.prestacaoContas["_PrestacaoContas"][index]["PrestacaoContasUID"]);
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      InkWell(
                        child: Text(
                          "Anexo",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () async {
                          var url = "${widget.prestacaoContas["_PrestacaoContas"][index]["LinkAnexo"]}";

                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            Alert(message: 'Não será possível abrir o anexo').show();
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                              content: Text("Tem certeza que deseja Aprovar esta PC?"),
                              textOK: Text("Sim"),
                              textCancel: Text("Não")
                            )
                          ) {
                            PrestacaoContasAprovacaoPOST prestacaoContasAprovacaoPOST = PrestacaoContasAprovacaoPOST();
                            prestacaoContasAprovacaoPOST.PrestacaoConta_GrupoUID = widget.prestacaoContas["PrestacaoConta_GrupoUID"];
                            prestacaoContasAprovacaoPOST.StatusAprovacao = "Aprovado";
                            prestacaoContasAprovacaoPOST.Pcs = [];
                            prestacaoContasAprovacaoPOST.Pcs.add(pc_glosa?? widget.prestacaoContas["_PrestacaoContas"][index]);
                            map_remove = widget.prestacaoContas["_PrestacaoContas"][index];

                            await AprovarReprovarPC(prestacaoContasAprovacaoPOST);
                          }
                        },
                      ),
                      SizedBox(width: 20.0),
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
                              PrestacaoContasAprovacaoPOST prestacaoContasAprovacaoPOST = PrestacaoContasAprovacaoPOST();
                              prestacaoContasAprovacaoPOST.PrestacaoConta_GrupoUID = widget.prestacaoContas["PrestacaoConta_GrupoUID"];
                              prestacaoContasAprovacaoPOST.StatusAprovacao = "Reprovado";
                              prestacaoContasAprovacaoPOST.JustificativaAprovacao = value;
                              prestacaoContasAprovacaoPOST.Pcs = [];
                              prestacaoContasAprovacaoPOST.Pcs.add(widget.prestacaoContas["_PrestacaoContas"][index]);

                              map_remove = widget.prestacaoContas["_PrestacaoContas"][index];

                              await AprovarReprovarPC(prestacaoContasAprovacaoPOST);
                            }
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            )
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
        title: Text("PC - ${widget.prestacaoContas["GrupoCodigo"]}"),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10.0),
              alignment: Alignment.center,
              child: Text(
                "${widget.prestacaoContas["NomeProjeto"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(top: 10.0),
              alignment: Alignment.center,
              child: Text(
                  "${widget.prestacaoContas["NomeUsuario"]}",
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
                        PrestacaoContasAprovacaoPOST prestacaoContasAprovacaoPOST = PrestacaoContasAprovacaoPOST();
                        prestacaoContasAprovacaoPOST.PrestacaoConta_GrupoUID = widget.prestacaoContas["PrestacaoConta_GrupoUID"];
                        prestacaoContasAprovacaoPOST.StatusAprovacao = "Reprovado";
                        prestacaoContasAprovacaoPOST.JustificativaAprovacao = value;
                        prestacaoContasAprovacaoPOST.Pcs = [];

                        for (Map map in widget.prestacaoContas["_PrestacaoContas"]){
                          prestacaoContasAprovacaoPOST.Pcs.add(PrestacaoContas.fromMap(map));
                        }

                        await AprovarReprovarPC(prestacaoContasAprovacaoPOST);
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
                        content: Text("Tem certeza que deseja Aprovar esta PC?"),
                        textOK: Text("Sim"),
                        textCancel: Text("Não")
                      )
                    ) {
                      PrestacaoContasAprovacaoPOST prestacaoContasAprovacaoPOST = PrestacaoContasAprovacaoPOST();
                      prestacaoContasAprovacaoPOST.PrestacaoConta_GrupoUID = widget.prestacaoContas["PrestacaoConta_GrupoUID"];
                      prestacaoContasAprovacaoPOST.StatusAprovacao = "Aprovado";
                      prestacaoContasAprovacaoPOST.Pcs = [];

                      for (Map map in widget.prestacaoContas["_PrestacaoContas"]){
                        PrestacaoContas pc_glosa = pcs_glosas.length > 0 ? pcs_glosas.firstWhere((element) => element.PrestacaoContasUID == map["PrestacaoContasUID"], orElse: (){return null;}) : null;
                        prestacaoContasAprovacaoPOST.Pcs.add(pc_glosa?? PrestacaoContas.fromMap(map));
                      }

                      await AprovarReprovarGrupo(prestacaoContasAprovacaoPOST);
                    }
                  },
                )
              ],
            ),
            _builderListViewPrestacaoContas()
          ],
        ),
      ),
    );
  }
}
