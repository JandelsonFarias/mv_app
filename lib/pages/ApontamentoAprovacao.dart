import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

import 'ApontamentoAprovar.dart';

class ApontamentoAprovacao extends StatefulWidget {
  @override
  _ApontamentoAprovacaoState createState() => _ApontamentoAprovacaoState();
}

class _ApontamentoAprovacaoState extends State<ApontamentoAprovacao> {

  HelperDB helperDB = HelperDB();

  ProgressDialog loading;

  Usuario usuarioLogado = Usuario();

  List<Map> apontamentos = [];

  bool carregando = true;

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
      loadApontamentos();
    });
  }

  loadApontamentos() async {

    if (this.mounted){
      setState(() {
        carregando = true;
      });
    }

    http.Response response;

    response = await http.get(baseApiURL + "Apontamento/GetApontamentosPendentes/?ResourceUID=" + usuarioLogado.ResourceUID);

    if (response.statusCode == 200){
      var responsemap = json.decode(response.body);

      List<Map> temp = [];

      for (Map map in responsemap){
        temp.add(map);
      }

      if (this.mounted){
        setState(() {
          apontamentos = temp;
          carregando = false;
        });
      }
    }
    else
      carregando = false;
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

  Widget _builderListViewApontamentos(){
    return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: apontamentos.length,
        shrinkWrap: true,
        itemBuilder: (context, index){

          DateTime DataInicio = DateTime.parse(apontamentos[index]["DataInicio"]);
          DateTime DataTermino = DateTime.parse(apontamentos[index]["DataTermino"]);

          return GestureDetector(
            child: Card(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${apontamentos[index]["TaskName"]}",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        SizedBox(height: 5.0),
                        Text("${DataInicio.day}/${DataInicio.month}/${DataInicio.year} - ${DataTermino.day}/${DataTermino.month}/${DataTermino.year}",
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
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ApontamentoAprovar(apontamentos[index]))
              ).then((e){
                loadApontamentos();
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
    else if (apontamentos.length == 0){
      return _buildContainerNoData();
    }
    else {
      return _builderListViewApontamentos();
    }
  }
}
