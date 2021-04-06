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
  HelperDB helperDB = HelperDB();
  Usuario usuarioLogado = Usuario();

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      setState(() {
        usuarioLogado = usuario;
      });
    });
  }

  int _currentTab = 0;

  List<Widget> tabs = [
    ApontamentoPage(),
    ApontamentoAcompanhamento(),
    ApontamentoAprovacao()
  ];

  List<BottomNavigationBarItem> getItems(){
    List<BottomNavigationBarItem> retorno = [];

    retorno.add(BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: "Cadastro",
        backgroundColor: Color.fromRGBO(36, 177, 139, 1)
    ));

    retorno.add(BottomNavigationBarItem(
        icon: Icon(Icons.article),
        label: "Acompanhamento",
        backgroundColor: Color.fromRGBO(36, 177, 139, 1)
    ));

    if (usuarioLogado.IsGerente != null && usuarioLogado.IsGerente){
      retorno.add(BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: "Aprovação",
          backgroundColor: Color.fromRGBO(36, 177, 139, 1)
      ));
    }

    return retorno;
  }

  @override
  void initState(){
    super.initState();
    loadUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        items: getItems(),
        onTap: (index){
          setState(() {
            _currentTab = index;
          });
        },
      )
    );
  }
}
