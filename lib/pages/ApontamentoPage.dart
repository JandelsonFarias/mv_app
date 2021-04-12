import 'dart:convert';

import 'package:alert/alert.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';

import 'FormApontamento.dart';

class ApontamentoPage extends StatefulWidget {
  @override
  _ApontamentoPageState createState() => _ApontamentoPageState();
}

class _ApontamentoPageState extends State<ApontamentoPage> {

  bool hasConnection = false;

  ProgressDialog loading;

  HelperDB helperDB = HelperDB();

  Usuario usuarioLogado = Usuario();

  List<Apontamento> apontamentos = [];
  List<Projeto> AP_projetos = [];

  Apontamento apontamento_removido;
  int apontamento_removido_posicao;

  void loadApontamentos(){
    helperDB.getAllApontamentos().then((_apontamentos){

      List<Projeto> _temp_projetos = [];

      for (Apontamento ap in _apontamentos){

        Projeto p = _temp_projetos.firstWhere((x) => x.ProjectUID == ap.ProjectUID, orElse: () => null);

        if (p == null) {
          Projeto projeto = Projeto();
          projeto.ProjectUID = ap.ProjectUID;
          projeto.NomeProjeto = ap.NomeProjeto;
          _temp_projetos.add(projeto);
        }
      }

      setState(() {
        apontamentos = _apontamentos;
        AP_projetos = _temp_projetos;
      });
    });
  }

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
    });
  }

  void verifyConnection() async {
    bool con = await DataConnectionChecker().hasConnection;
    setState(()  {
      hasConnection = con;
    });
  }

  Widget _buildContainerNoData(){
    return Container(
      alignment: Alignment.center,
      child: Text(
          "Nenhum Apontamento Cadastrado",
          style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.black26
          )
      ),
    );
  }

  Widget _builderListViewApontamentos(){
    return ListView.builder(
        itemBuilder: (context, index){
          List<Apontamento> grouped = apontamentos.where((x) => x.ProjectUID == AP_projetos[index].ProjectUID).toList();
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "${AP_projetos[index].NomeProjeto}",
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10.0),
                ListView.builder(
                  itemBuilder: (context, index){
                    return Dismissible(
                      key: Key(apontamentos[index].ApontamentoUID),
                      background: Container(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment(-0.9, 0.0),
                          child: Icon(
                              Icons.delete,
                              color: Colors.white
                          ),
                        ),
                      ),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction){
                        setState(() {
                          apontamento_removido = grouped[index];
                          apontamento_removido_posicao = apontamentos.indexWhere((x) => x.ApontamentoUID == apontamento_removido.ApontamentoUID);
                          apontamentos.removeAt(apontamento_removido_posicao);

                          helperDB.deleteApontamentoByUID(apontamento_removido.ApontamentoUID).then((e){
                            loadApontamentos();
                          });

                          final snack = SnackBar(
                              content: Text("Apontamento removido!"),
                              action: SnackBarAction(
                                label: "Desfazer",
                                onPressed: (){
                                  setState(() {
                                    apontamentos.insert(apontamento_removido_posicao, apontamento_removido);
                                    helperDB.saveApontamento(apontamento_removido).then((e){
                                      loadApontamentos();
                                    });
                                  });
                                },
                              ),
                              duration: Duration(
                                  seconds: 3
                              )
                          );

                          Scaffold.of(context).showSnackBar(snack);
                        });
                      },
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => FormApontamento(grouped[index]))
                          ).then((e){
                            loadApontamentos();
                          });
                        },
                        child: Card(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("${grouped[index].TaskName}",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text("${grouped[index].NewTimeByDay}",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text("${grouped[index].HorasApontadas}",
                                      style: TextStyle(fontSize: 14.0),
                                    )
                                  ],
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: !hasConnection ? null : () async {
                                  await verifyConnection();

                                  if (hasConnection && await confirm(
                                      context,
                                      title: Text("Atenção"),
                                      content: Text("Tem certeza que deseja enviar este apontamento de horas? Após enviado, será removida do seu dispositivo e não poderá mais ser editado."),
                                      textOK: Text("Sim"),
                                      textCancel: Text("Não")
                                  )) {

                                    await loading.show();

                                    http.post(
                                        baseApiURL + "Apontamento/SaveApontamento",
                                        headers: <String, String>{
                                          'Content-Type': 'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(grouped[index])
                                    ).then((response) async {

                                      await loading.hide();

                                      if (response.statusCode == 200){
                                        if (response.body.isNotEmpty) {
                                          var map = json.decode(response.body);

                                          String erros = map.toString().replaceAll(";", "\n");
                                          
                                          if (map.toString().contains("Apontamento já realizado")) erros = "Já existe um apontamento para esta atividade nesta data. Selecione outro dia.";

                                          AlertDialog alert = AlertDialog(
                                            title: Text("Apontamento não enviado."),
                                            content: Text(erros),
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
                                        }
                                        else  {
                                          Alert(message: 'Apontamento enviado com sucesso!').show();

                                          helperDB.deleteApontamentoByUID(grouped[index].ApontamentoUID).then((e){
                                            loadApontamentos();
                                          });
                                        }
                                      }
                                      else  {
                                        Alert(message: 'Erro ao enviar. ${response.body}').show();
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: 80.0,
                                  height: 80.0,
                                  child: Icon(
                                    Icons.send,
                                    size: 30.0,
                                    color: !hasConnection ? Colors.black12 : Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: grouped.length,
                  shrinkWrap: true,
                )
              ],
            ),
          );
        },
        itemCount: AP_projetos.length);
  }

  @override
  void initState(){
    super.initState();
    verifyConnection();
    loadUsuarioLogado();
    loadApontamentos();
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
      body: apontamentos.length > 0 ? _builderListViewApontamentos() : _buildContainerNoData(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
            Icons.add
        ),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        onPressed: (){
          Apontamento ap = Apontamento();

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FormApontamento(ap))
          ).then((e){
            loadApontamentos();
          });
        },
      ),
    );
  }
}

























