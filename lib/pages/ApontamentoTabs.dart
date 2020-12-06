import 'package:flutter/material.dart';
import 'package:tabbar/tabbar.dart';

import 'ApontamentoAprovacao.dart';
import 'ApontamentoPage.dart';

class ApontamentoTabs extends StatefulWidget {
  @override
  _ApontamentoTabsState createState() => _ApontamentoTabsState();
}

class _ApontamentoTabsState extends State<ApontamentoTabs> {
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
          ApontamentoPage(),
          ApontamentoAprovacao()
        ],
      ),
    );
  }
}
