import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/AdiantamentoAprovacao.dart';
import 'package:tabbar/tabbar.dart';
import 'AdiantamentoPage.dart';

class AdiantamentoTabs extends StatefulWidget {
  @override
  _AdiantamentoTabsState createState() => _AdiantamentoTabsState();
}

class _AdiantamentoTabsState extends State<AdiantamentoTabs> {
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
              Tab(text: "Aprovação")
            ] : [
              Tab(text: "Cadastro")
            ],
          ),
        ),
      ),
      body: TabbarContent(
        controller: controller,
        children: usuarioLogado.IsGerente != null && usuarioLogado.IsGerente ? <Widget>[
          AdiantamentoPage(),
          AdiantamentoAprovacao()
        ] : <Widget>[
          AdiantamentoPage()
        ],
      ),
    );
  }
}
