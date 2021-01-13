import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;

class ApontamentoAcompanhamento extends StatefulWidget {
  @override
  _ApontamentoAcompanhamentoState createState() => _ApontamentoAcompanhamentoState();
}

class _ApontamentoAcompanhamentoState extends State<ApontamentoAcompanhamento> {
  bool carregando = true;

  List<Map> apontamentos = [];

  Usuario usuarioLogado = Usuario();

  HelperDB helperDB = HelperDB();

  List<Map> Projetos = [];
  List<DropdownMenuItem<String>> dowpDownMenuItems_projeto;
  Map ProjetoSelecionado = Map();

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
      LoadProjetos();
    });
  }

  LoadProjetos() async {
    http.Response response;
    response = await http.get(baseApiURL + "Apontamento/GetProjetosAcompanhamento/?ResourceUID=" + usuarioLogado.ResourceUID);

    if (response.statusCode == 200){
      var projetos = json.decode(response.body);

      setState(() {
        for (var item in projetos){
          Projetos.add(item);
        }
        dowpDownMenuItems_projeto = _builddowpDownMenuItemsProjeto();
        carregando = false;
      });
    }
  }

  List<DropdownMenuItem<String>> _builddowpDownMenuItemsProjeto(){
    List<DropdownMenuItem<String>> items = List();

    if (ProjetoSelecionado != null && ProjetoSelecionado["ProjectUID"] != null && ProjetoSelecionado["ProjectUID"] != ""){
      Projetos.add(ProjetoSelecionado);
    }

    if (Projetos.length > 0){
      for (Map p in Projetos){
        items.add(
            DropdownMenuItem(
                value: p["ProjectUID"],
                child: Text(p["Nome"])
            )
        );
      }
    }

    return items;
  }

  loadApontamentos() async {
    setState(() {
      carregando = true;
    });

    http.Response response;

    response = await http.get(baseApiURL + "Apontamento/GetApontamentosAcompanhamento/?ProjectUID=${ProjetoSelecionado["ProjectUID"]}&ResourceUID=${usuarioLogado.ResourceUID}");

    if (response.statusCode == 200){
      var responsemap = json.decode(response.body);

      setState(() {
        for (Map map in responsemap){
          apontamentos.add(map);
        }

        carregando = false;
      });
    }
    else
      carregando = false;
  }

  Widget _builderListViewApontamentos(){
    return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: apontamentos.length,
        shrinkWrap: true,
        itemBuilder: (context, index){

          DateTime NewTimeByDay = DateTime.parse(apontamentos[index]["DataInicio"]);

          return Container();
        }
    );
  }

  Widget _buildContainerNoData(){
    return Center(
      heightFactor: 15.0,
      child: Text(
          "Nenhum Apontamento encontrado",
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

    if (apontamentos.length == 0)
      loadUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.0),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(border: InputBorder.none),
                hint: Text("Selecione o Projeto"),
                value: ProjetoSelecionado["ProjectUID"],
                icon: Icon(Icons.keyboard_arrow_down),
                isExpanded: true,
                iconSize: 24.0,
                elevation: 16,
                onChanged: (projeto){
                  setState(() {
                    ProjetoSelecionado = Projetos.firstWhere((x) => x["ProjectUID"] == projeto, orElse: () => Map());
                  });

                  loadApontamentos();
                },
                items: dowpDownMenuItems_projeto,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: carregando ? Center(heightFactor: 8,
                child: CircularProgressIndicator()
            ) : apontamentos.length == 0 ? _buildContainerNoData() : _builderListViewApontamentos()
        ),
      );
  }
}