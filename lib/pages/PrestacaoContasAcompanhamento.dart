import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;
import 'package:mvapp/pages/PrestacaoContasAcompanhamentoDetalhes.dart';
import 'package:group_button/group_button.dart';

class PrestacaoContasAcompanhamento extends StatefulWidget {
  @override
  _PrestacaoContasAcompanhamentoState createState() => _PrestacaoContasAcompanhamentoState();
}

class _PrestacaoContasAcompanhamentoState extends State<PrestacaoContasAcompanhamento> {

  bool carregando = true;

  List<Map> prestacaoContas = [];
  List<Map> prestacaoContas_filtered = [];
  List<Projeto> PC_projetos = [];

  Usuario usuarioLogado = Usuario();

  HelperDB helperDB = HelperDB();

  bool filtro_pendente = false;
  bool filtro_aprovado = false;
  bool filtro_reprovado = false;

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
      loadPrestacaoContas();
    });
  }

  loadPrestacaoContas() async {

    setState(() {
      carregando = true;
    });

    http.Response response;

    response = await http.get(baseApiURL + "PrestacaoContas/GetPrestacaoContasAcompanhamento/?UsuarioUID=${usuarioLogado.UsuarioUID}");

    if (response.statusCode == 200){
      var responsemap = json.decode(response.body);

      List<Map> temp = [];
      List<Projeto> _temp_projetos = [];

      for (Map map in responsemap){
        Projeto p = _temp_projetos.firstWhere((x) => x.NomeProjeto == map["NomeProjeto"], orElse: () => null);

        if (p == null) {
          Projeto projeto = Projeto();
          projeto.NomeProjeto = map["NomeProjeto"];
          _temp_projetos.add(projeto);
        }

        temp.add(map);
      }

      setState(() {
        prestacaoContas = temp;
        PC_projetos = _temp_projetos;
        carregando = false;
      });
    }
    else
      carregando = false;
  }

  filterLists() {

    List<Map> temp = [];
    List<Projeto> _temp_projetos = [];

    if (filtro_pendente || filtro_aprovado || filtro_reprovado){
      for (Map map in prestacaoContas){

        if (filtro_pendente && map["StatusPC"].toString() == "Pendente"){
          Projeto p = _temp_projetos.firstWhere((x) => x.NomeProjeto == map["NomeProjeto"], orElse: () => null);

          if (p == null) {
            Projeto projeto = Projeto();
            projeto.NomeProjeto = map["NomeProjeto"];
            _temp_projetos.add(projeto);
          }

          temp.add(map);
        }

        if (filtro_aprovado && map["StatusPC"].toString() == "Aprovado"){
          Projeto p = _temp_projetos.firstWhere((x) => x.NomeProjeto == map["NomeProjeto"], orElse: () => null);

          if (p == null) {
            Projeto projeto = Projeto();
            projeto.NomeProjeto = map["NomeProjeto"];
            _temp_projetos.add(projeto);
          }

          temp.add(map);
        }

        if (filtro_reprovado && map["StatusPC"].toString() == "Reprovado"){
          Projeto p = _temp_projetos.firstWhere((x) => x.NomeProjeto == map["NomeProjeto"], orElse: () => null);

          if (p == null) {
            Projeto projeto = Projeto();
            projeto.NomeProjeto = map["NomeProjeto"];
            _temp_projetos.add(projeto);
          }

          temp.add(map);
        }
      }

      setState(() {
        prestacaoContas_filtered = temp;
        PC_projetos = _temp_projetos;
      });
    }
    else {
      for (Map map in prestacaoContas){
        Projeto p = _temp_projetos.firstWhere((x) => x.NomeProjeto == map["NomeProjeto"], orElse: () => null);

        if (p == null) {
          Projeto projeto = Projeto();
          projeto.NomeProjeto = map["NomeProjeto"];
          _temp_projetos.add(projeto);
        }

        temp.add(map);
      }

      setState(() {
        prestacaoContas_filtered = temp;
        PC_projetos = _temp_projetos;
      });
    }
  }

  Widget _builderListViewPrestacaoContas(){
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index){
        List<Map> grouped = filtro_pendente || filtro_aprovado || filtro_reprovado ? prestacaoContas_filtered.where((x) => x["NomeProjeto"] == PC_projetos[index].NomeProjeto).toList() : prestacaoContas.where((x) => x["NomeProjeto"] == PC_projetos[index].NomeProjeto).toList();
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                "${PC_projetos[index].NomeProjeto}",
                style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return GestureDetector(
                    child: Card(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                        color: grouped[index]["StatusPC"] == "Aprovado" ? Colors.green : grouped[index]["StatusPC"] == "Reprovado" ? Colors.red : Colors.black12
                                      ),
                                        padding: EdgeInsets.all(7.0),
                                        child: Container()
                                    ),
                                    SizedBox(width: 10.0),
                                    Text("PC - ${grouped[index]["GrupoCodigo"]}",
                                      style: TextStyle(fontSize: 15.0),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => PrestacaoContasAcompanhamentoDetalhes(grouped[index]))
                              );
                            },
                            child: Container(
                              width: 80.0,
                              height: 80.0,
                              child: Icon(
                                Icons.info_outline,
                                size: 30.0,
                                color: Colors.black
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PrestacaoContasAcompanhamentoDetalhes(grouped[index]))
                      );
                    },
                  );
                },
                itemCount: grouped.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical
              )
            ],
          ),
        );
      },
      itemCount: PC_projetos.length);
  }

  Widget _buildContainerNoData(){
    return Center(
      heightFactor: 15.0,
      child: Text(
          "Nenhuma Prestação de Contas Cadastrada",
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

    if (prestacaoContas.length == 0)
      loadUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando){
      return Center(
          child: CircularProgressIndicator()
      );
    }
    else {
      return
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.0),
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: GroupButton(
                  isRadio: false,
                  spacing: 10,
                  selectedColor: Color.fromRGBO(36, 177, 139, 1),
                  onSelected: (index, isSelected) {
                    if (index == 0)
                      filtro_pendente = isSelected;
                    else if (index == 1)
                      filtro_aprovado = isSelected;
                    else
                      filtro_reprovado = isSelected;

                    filterLists();
                  },
                  buttons: ["Pendente", "Aprovado", "Reprovado"],
                )
              ),
            ),
          ),
          // bottomNavigationBar: Container(
          //   padding: EdgeInsets.all(5.0),
          //   child: TextField(
          //     keyboardType: TextInputType.number,
          //     controller: pesquisaController,
          //     decoration: InputDecoration(
          //         border: InputBorder.none,
          //         contentPadding: EdgeInsets.only(top: 14.0),
          //         prefixIcon: Icon(Icons.search, color: Colors.black),
          //         hintText: 'Pesquisar'
          //     ),
          //     onChanged: (text){
          //       filterLists();
          //     },
          //   ),
          // ),
          body: SingleChildScrollView(
            child: (((filtro_pendente || filtro_aprovado || filtro_reprovado) && prestacaoContas_filtered.length == 0) || prestacaoContas.length == 0) ? _buildContainerNoData() : _builderListViewPrestacaoContas()
        ),
      );
    }
  }
}
