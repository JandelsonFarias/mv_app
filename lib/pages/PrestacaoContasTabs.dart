import 'package:flutter/material.dart';
import 'package:tabbar/tabbar.dart';
import 'PrestacaoContasAprovacao.dart';
import 'PrestacaoContasPage.dart';

class PrestacaoContasTabs extends StatefulWidget {
  @override
  _PrestacaoContasTabsState createState() => _PrestacaoContasTabsState();
}

class _PrestacaoContasTabsState extends State<PrestacaoContasTabs> {

  final controller = PageController();

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
            tabs: [
              Tab(text: "Cadastro"),
              Tab(text: "Aprovação")
            ],
          ),
        ),
      ),
      body: TabbarContent(
        controller: controller,
        children: <Widget>[
          PrestacaoContasPage(),
          PrestacaoContasAprovacao()
        ],
      ),
    );
  }
}
