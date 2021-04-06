import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/AdiantamentoAprovacao.dart';
import 'AdiantamentoPage.dart';

class AdiantamentoTabs extends StatefulWidget {
  @override
  _AdiantamentoTabsState createState() => _AdiantamentoTabsState();
}

class _AdiantamentoTabsState extends State<AdiantamentoTabs> {
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
    AdiantamentoPage(),
    AdiantamentoAprovacao()
  ];

  List<BottomNavigationBarItem> getItems(){
    List<BottomNavigationBarItem> retorno = [];

    retorno.add(BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: "Cadastro",
        backgroundColor: Color.fromRGBO(36, 177, 139, 1)
    ));

    retorno.add(BottomNavigationBarItem(
      icon: Icon(Icons.check),
      label: "Aprovação",
      backgroundColor: Color.fromRGBO(36, 177, 139, 1),
    ));

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
