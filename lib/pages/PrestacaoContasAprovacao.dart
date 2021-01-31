import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

import 'PrestacaoContasAprovar.dart';

class PrestacaoContasAprovacao extends StatefulWidget {
  @override
  _PrestacaoContasAprovacaoState createState() => _PrestacaoContasAprovacaoState();
}

class _PrestacaoContasAprovacaoState extends State<PrestacaoContasAprovacao> {

  HelperDB helperDB = HelperDB();

  ProgressDialog loading;

  Usuario usuarioLogado = Usuario();

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  List<Map> prestacaoContas = [];

  bool carregando = true;

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
      loadPrestacaoContas();
    });
  }

  loadPrestacaoContas() async {

    if (this.mounted){
      setState(() {
        carregando = true;
      });
    }

    http.Response response;

    response = await http.get(baseApiURL + "PrestacaoContas/GetPrestacaoContasPendentes/?UsuarioUID=" + usuarioLogado.UsuarioUID + "&ResourceUID=" + usuarioLogado.ResourceUID);

    if (response.statusCode == 200){
      var responsemap = json.decode(response.body);

      List<Map> temp = [];

      for (Map map in responsemap){
        temp.add(map);
      }

      if (this.mounted){
        setState(() {
          prestacaoContas = temp;
          carregando = false;
        });
      }
    }
    else{
      if (this.mounted){
        setState(() {
          carregando = false;
        });
      }
    }
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

  Widget _builderListViewPrestacaoContas(){
    return ListView.builder(
      padding: EdgeInsets.all(5.0),
      itemCount: prestacaoContas.length,
      shrinkWrap: true,
      itemBuilder: (context, index){
        return GestureDetector(
          child: Card(
            child: Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("PC - ${prestacaoContas[index]["GrupoCodigo"]}",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          width: 250.0,
                          child: Text("${prestacaoContas[index]["NomeUsuario"]}",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(currency.format(prestacaoContas[index]["Valor"]),
                          style: TextStyle(fontSize: 14.0),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 80.0,
                    height: 80.0,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30.0,
                    ),
                  )
                ],
              ),
            ),
          ),
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PrestacaoContasAprovar(prestacaoContas[index]))
            ).then((e){
              loadPrestacaoContas();
            });
          },
        );
      }
    );
  }

  @override
  void initState(){
    super.initState();
    loadUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else if (prestacaoContas.length == 0){
      return _buildContainerNoData();
    }
    else {
      return _builderListViewPrestacaoContas();
    }
  }
}
