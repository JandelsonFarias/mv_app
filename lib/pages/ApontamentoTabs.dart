import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/ApontamentoAcompanhamento.dart';
import 'package:tabbar/tabbar.dart';

import 'ApontamentoAprovacao.dart';
import 'ApontamentoPage.dart';

class ApontamentoTabs extends StatefulWidget {
  @override
  _ApontamentoTabsState createState() => _ApontamentoTabsState();
}

class _ApontamentoTabsState extends State<ApontamentoTabs> {
  final controller = PageController();
  HelperDB helperDB = HelperDB();
  Usuario usuarioLogado = Usuario();

  List<Tab> tabs = [];
  var pages = <Widget>[];

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      setState(() {
        usuarioLogado = usuario;
      });
    });
  }

  @override
  void initState(){
    super.initState();
    loadUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48.0,
        bottom: PreferredSize(
          child: TabbarHeader(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            indicatorColor: Color.fromRGBO(36, 177, 139, 1),
            controller: controller,
            tabs: usuarioLogado.IsGerente != null && usuarioLogado.IsGerente ? [
              Tab(text: "Cadastro"),
              Tab(text: "Aprovação"),
              Tab(text: "Acompanhamento")
            ] : [
              Tab(text: "Cadastro"),
              Tab(text: "Acompanhamento")
            ],
          ),
        ),
      ),
      body: TabbarContent(
        controller: controller,
        children: usuarioLogado.IsGerente != null && usuarioLogado.IsGerente ? <Widget>[
          ApontamentoPage(),
          ApontamentoAprovacao(),
          ApontamentoAcompanhamento()
        ] : <Widget>[
          ApontamentoPage(),
          ApontamentoAcompanhamento()
        ],
      ),
    );
  }
}
