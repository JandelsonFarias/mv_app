import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'AdiantamentoTabs.dart';
import 'ApontamentoTabs.dart';
import 'Login.dart';
import 'PrestacaoContasTabs.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  HelperDB helperDB = HelperDB();
  Usuario usuarioLogado = Usuario();

  @override
  void initState(){
    super.initState();

    helperDB.getUsuarioLogado().then((usuario){
      setState(() {
        usuarioLogado = usuario;
      });
    });
  }

  int _currentTab = 0;

  final tabs = [
    PrestacaoContasTabs(),
    AdiantamentoTabs(),
    ApontamentoTabs()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(usuarioLogado != null && usuarioLogado.Nome != null ? usuarioLogado.Nome : "",
              style: TextStyle(color: Colors.white)
          ),
          backgroundColor: Color.fromRGBO(36, 177, 139, 1),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.reply,
                color: Colors.white,
              ),
              onPressed: () async {
                if (await confirm(
                  context,
                  title: Text("Sair"),
                  content: Text("Tem certeza que sair? Todas as informações não enviadas serão perdidas."),
                  textOK: Text("Sim"),
                  textCancel: Text("Não")
                  )) {
                  helperDB.deleteUsuarioLogado().then((deleted){
                    helperDB.deleteProjetoSelecionado().then((projetodeleted){
                      helperDB.deleteDespesas().then((despesadeleted){
                        helperDB.deletePrestacaoContas().then((pcdeleted){
                          helperDB.deleteAdiantamentos().then((addeleted){
                            helperDB.deleteApontamentoAssignment().then((assdeleted){
                              helperDB.deleteApontamentoTask().then((taskdeleted){
                                helperDB.deleteApontamentos().then((apotdeleted){
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => Login()),
                                        (Route<dynamic> route) => false,
                                  );
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                }
              },
            )
          ],
        ),
      body: tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Prest. Contas",
            backgroundColor: Color.fromRGBO(36, 177, 139, 1)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Adiantamento",
            backgroundColor: Color.fromRGBO(36, 177, 139, 1)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Apontamentos",
            backgroundColor: Color.fromRGBO(36, 177, 139, 1)
          )
        ],
        onTap: (index){
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }
}