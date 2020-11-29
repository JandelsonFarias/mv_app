import 'package:flutter/material.dart';
import 'package:mvapp/pages/AdiantamentoAprovacao.dart';
import 'package:tabbar/tabbar.dart';
import 'AdiantamentoPage.dart';

class AdiantamentoTabs extends StatefulWidget {
  @override
  _AdiantamentoTabsState createState() => _AdiantamentoTabsState();
}

class _AdiantamentoTabsState extends State<AdiantamentoTabs> {
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
          AdiantamentoPage(),
          AdiantamentoAprovacao()
        ],
      ),
    );
  }
}
