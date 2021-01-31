import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/PrestacaoContasAcompanhamento.dart';
import 'package:tabbar/tabbar.dart';
import 'PrestacaoContasAprovacao.dart';
import 'PrestacaoContasPage.dart';

class PrestacaoContasTabs extends StatefulWidget {
  @override
  _PrestacaoContasTabsState createState() => _PrestacaoContasTabsState();
}

class _PrestacaoContasTabsState extends State<PrestacaoContasTabs> {

  final controller = PageController(initialPage: 0);

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
          preferredSize: Size.fromHeight(20.0),
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
          PrestacaoContasPage(),
          PrestacaoContasAprovacao(),
          PrestacaoContasAcompanhamento()
        ] : <Widget>[
          PrestacaoContasPage(),
          PrestacaoContasAcompanhamento()
        ],
      ),
    );
  }
}
