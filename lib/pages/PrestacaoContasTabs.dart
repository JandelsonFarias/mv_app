import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/PrestacaoContasAcompanhamento.dart';
import 'PrestacaoContasAprovacao.dart';
import 'PrestacaoContasPage.dart';

class PrestacaoContasTabs extends StatefulWidget {
  @override
  _PrestacaoContasTabsState createState() => _PrestacaoContasTabsState();
}

class _PrestacaoContasTabsState extends State<PrestacaoContasTabs> {

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
    PrestacaoContasPage(),
    PrestacaoContasAcompanhamento(),
    PrestacaoContasAprovacao()
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
