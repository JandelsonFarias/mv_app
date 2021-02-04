import 'dart:convert';

import 'package:alert/alert.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'FormAdiantamento.dart';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';

class AdiantamentoPage extends StatefulWidget {
  @override
  _AdiantamentoPageState createState() => _AdiantamentoPageState();
}

class _AdiantamentoPageState extends State<AdiantamentoPage> {

  bool hasConnection = false;

  ProgressDialog loading;

  Usuario usuarioLogado = Usuario();

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  HelperDB helperDB = HelperDB();

  List<Adiantamento> adiantamentos = [];
  List<Projeto> AD_projetos = [];

  Adiantamento adiantamento_removido;
  int adiantamento_removido_posicao;

  void loadAdiantamentos(){
    helperDB.getAllAdiantamentos().then((_adiantamentos){

      _adiantamentos.sort((a, b) => a.AdiantamentoCodigo.compareTo(b.AdiantamentoCodigo));

      List<Projeto> _temp_projetos = [];

      for (Adiantamento ad in _adiantamentos){

        Projeto p = _temp_projetos.firstWhere((x) => x.ProjectUID == ad.ProjectUID, orElse: () => null);

        if (p == null) {
          Projeto projeto = Projeto();
          projeto.ProjectUID = ad.ProjectUID;
          projeto.NomeProjeto = ad.NomeProjeto;
          _temp_projetos.add(projeto);
        }
      }

      setState(() {
        adiantamentos = _adiantamentos;
        AD_projetos = _temp_projetos;
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

  Widget _builderListViewAdiantamentos(){
    return ListView.builder(
        itemBuilder: (context, index){
          List<Adiantamento> grouped = adiantamentos.where((x) => x.ProjectUID == AD_projetos[index].ProjectUID).toList();
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "${AD_projetos[index].NomeProjeto}",
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10.0),
                ListView.builder(
                  itemBuilder: (context, index){
                    return Dismissible(
                      key: Key(adiantamentos[index].AdiantamentoUID),
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
                          adiantamento_removido = grouped[index];
                          adiantamento_removido_posicao = adiantamentos.indexWhere((x) => x.AdiantamentoUID == adiantamento_removido.AdiantamentoUID);
                          adiantamentos.removeAt(adiantamento_removido_posicao);

                          helperDB.deleteAdiantamentoByUID(adiantamento_removido.AdiantamentoUID).then((e){
                            loadAdiantamentos();
                          });

                          final snack = SnackBar(
                              content: Text("Adiantamento removido!"),
                              action: SnackBarAction(
                                label: "Desfazer",
                                onPressed: (){
                                  setState(() {
                                    adiantamentos.insert(adiantamento_removido_posicao, adiantamento_removido);
                                    helperDB.saveAdiantamento(adiantamento_removido).then((e){
                                      loadAdiantamentos();
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
                              MaterialPageRoute(builder: (context) => FormAdiantamento(grouped[index]))
                          ).then((e){
                            loadAdiantamentos();
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
                                    Text("AD - ${grouped[index].AdiantamentoCodigo}",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text("De ${grouped[index].DataInicio} até ${grouped[index].DataFim}",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(currency.format(grouped[index].ValorApontado),
                                      style: TextStyle(fontSize: 14.0),
                                    )
                                  ],
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: !hasConnection ? null : () async {
                                  await verifyConnection();

                                  int day = int.parse(grouped[index].DataFim.split("/")[0]);
                                  int month = int.parse(grouped[index].DataFim.split("/")[1]);
                                  int year = int.parse(grouped[index].DataFim.split("/")[2]);

                                  DateTime dataFim = new DateTime(year, month, day);
                                  dataFim = dataFim.add(new Duration(days: 3));
                                  
                                  if (hasConnection && await confirm(
                                      context,
                                      title: Text("Atenção"),
                                      content: SingleChildScrollView(
                                        child: Text("Tem certeza que deseja enviar a AD ${grouped[index].AdiantamentoCodigo}? Após enviada, será removida do seu dispositivo e não poderá mais ser editada.\nComo colaborador desta empresa comprometo-me a prestar contas dos valores recebidos para despesas de viagens a trabalho, com as respectivas notas fiscais até ${dataFim.day}/${dataFim.month}/${dataFim.year}, após o retorno ao meu local de trabalho. Autorizo ainda em caso de não prestação de contas dentro do prazo previsto, o desconto de valores totais ou parciais correspondentes ao adiantamento recebido, em meu salário do mês, respeitados os devidos limites legais."),
                                      ),
                                      textOK: Text("Sim"),
                                      textCancel: Text("Não")
                                  )) {

                                    await loading.show();

                                    http.post(
                                        baseApiURL + "Adiantamento/SalvarAdiantamento",
                                        headers: <String, String>{
                                          'Content-Type': 'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(grouped[index])
                                    ).then((response) async {

                                      await loading.hide();

                                      if (response.statusCode == 200){
                                        if (response.body.isNotEmpty) {
                                          var map = json.decode(response.body);

                                          String erros = map["erros"].toString().replaceAll(";", "\n");

                                          AlertDialog alert = AlertDialog(
                                            title: Text("AD não enviada."),
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
                                          Alert(message: 'AD enviado com sucesso!').show();

                                          helperDB.deleteAdiantamentoByUID(grouped[index].AdiantamentoUID).then((e){
                                            loadAdiantamentos();
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
        itemCount: AD_projetos.length);
  }

  Widget _buildContainerNoData(){
    return Container(
      alignment: Alignment.center,
      child: Text(
          "Nenhum Adiantamento Cadastrado",
          style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.black26
          )
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    verifyConnection();
    loadUsuarioLogado();
    loadAdiantamentos();
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
      body: adiantamentos.length > 0 ? _builderListViewAdiantamentos() : _buildContainerNoData(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
            Icons.add
        ),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        onPressed: (){
          Adiantamento ad = Adiantamento();

          if (adiantamentos.length > 0){
            adiantamentos.sort((a, b) => a.AdiantamentoCodigo.compareTo(b.AdiantamentoCodigo));
            ad.AdiantamentoCodigo = (int.parse(adiantamentos.last.AdiantamentoCodigo) + 1).toString().padLeft(4, "0");
          }
          else
            ad.AdiantamentoCodigo = (1).toString().padLeft(4, "0");

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FormAdiantamento(ad))
          ).then((e){
            loadAdiantamentos();
          });
        },
      ),
    );
  }
}
