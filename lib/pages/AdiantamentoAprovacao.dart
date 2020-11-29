import 'dart:convert';

import 'package:alert/alert.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

class AdiantamentoAprovacao extends StatefulWidget {
  @override
  _AdiantamentoAprovacaoState createState() => _AdiantamentoAprovacaoState();
}

class _AdiantamentoAprovacaoState extends State<AdiantamentoAprovacao> {

  HelperDB helperDB = HelperDB();

  ProgressDialog loading;

  Usuario usuarioLogado = Usuario();

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  List<Map> adiantamentos = [];

  bool carregando = true;

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
      loadAdiantamentos();
    });
  }

  loadAdiantamentos() async {

    setState(() {
      carregando = true;
    });

    http.Response response;

    response = await http.get(baseApiURL + "Adiantamento/GetAdiantamentosPendentes/?UsuarioUID=" + usuarioLogado.UsuarioUID + "&ResourceUID=" + usuarioLogado.ResourceUID);

    if (response.statusCode == 200){
      var responsemap = json.decode(response.body);

      List<Map> temp = [];

      for (Map map in responsemap){
        temp.add(map);
      }

      setState(() {
        adiantamentos = temp;
        carregando = false;
      });
    }
    else
      carregando = false;
  }

  AprovarReprovarAD(AdiantamentoAprovacaoPOST adiantamentoAprovacaoPOST) async {
    await loading.show();

    http.post(
        baseApiURL + "Adiantamento/AprovarReprovarAdiantamento",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(adiantamentoAprovacaoPOST)
    ).then((response) async {

      await loading.hide();

      if (response.statusCode == 200){
        String retorno = response.body;

        if (retorno == ""){
          Alert(message: "Operação relizada com sucesso!").show();
        }
        else {
          AlertDialog alert = AlertDialog(
            title: Text("Atenção"),
            content: Text(retorno),
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
      }
      else  {
        Alert(message: 'Erro ao enviar. ${response.body}').show();
      }

      loadAdiantamentos();
    });
  }

  Widget _buildContainerNoData(){
    return Container(
      alignment: Alignment.center,
      child: Text(
          "Não há aprovações pendentes",
          style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.black26
          )
      ),
    );
  }

  Widget _builderListViewAdiantamentos(){
    return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: adiantamentos.length,
        shrinkWrap: true,
        itemBuilder: (context, index){

          DateTime DataInicio = DateTime.parse(adiantamentos[index]["DataInicio"]);
          DateTime DataFim = DateTime.parse(adiantamentos[index]["DataFim"]);

          return Card(
            child: Row(
              children: <Widget>[
                Container(
                  width: 200.0,
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("AD - ${adiantamentos[index]["Codigo"]}",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      SizedBox(height: 5.0),
                      Text("${adiantamentos[index]["Solicitante"]}",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      SizedBox(height: 5.0),
                      Text("De: ${DataInicio.day}/${DataInicio.month}/${DataInicio.year}",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      SizedBox(height: 5.0),
                      Text("Até: ${DataFim.day}/${DataFim.month}/${DataFim.year}",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      SizedBox(height: 5.0),
                      Text(currency.format(adiantamentos[index]["ValorApontado"]),
                        style: TextStyle(fontSize: 14.0),
                      )
                    ],
                  ),
                ),
                Spacer(),
                Container(
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
                              content: Text("Tem certeza que deseja Aprovar este AD?"),
                              textOK: Text("Sim"),
                              textCancel: Text("Não")
                          )
                          ) {
                            AdiantamentoAprovacaoPOST adiantamentoAprovacaoPOST = AdiantamentoAprovacaoPOST();
                            adiantamentoAprovacaoPOST.AdiantamentoUID = adiantamentos[index]["AdiantamentoUID"];
                            adiantamentoAprovacaoPOST.StatusAprovacao = "Aprovado";

                            await AprovarReprovarAD(adiantamentoAprovacaoPOST);
                          }
                        },
                      ),
                      SizedBox(height: 10.0),
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
                              AdiantamentoAprovacaoPOST adiantamentoAprovacaoPOST = AdiantamentoAprovacaoPOST();
                              adiantamentoAprovacaoPOST.AdiantamentoUID = adiantamentos[index]["AdiantamentoUID"];
                              adiantamentoAprovacaoPOST.StatusAprovacao = "Reprovado";
                              adiantamentoAprovacaoPOST.Justificativa = value;

                              await AprovarReprovarAD(adiantamentoAprovacaoPOST);
                            }
                          });
                        },
                      )
                    ],
                  )
                )
              ],
            ),
          );
        }
    );
  }

  Future<String> _createConfirmDialog(BuildContext context){
    TextEditingController controller = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Atenção"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text("Tem certeza que deseja Reprovar esta AD? É necessário informar uma justificativa."),
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

  @override
  void initState(){
    super.initState();
    loadUsuarioLogado();
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

    if (carregando){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else if (adiantamentos.length == 0){
      return _buildContainerNoData();
    }
    else {
      return _builderListViewAdiantamentos();
    }
  }
}
