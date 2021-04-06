import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:mvapp/pages/AdiantamentoPage.dart';
import 'AdiantamentoTabs.dart';
import 'ApontamentoTabs.dart';
import 'Login.dart';
import 'PrestacaoContasTabs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _message = '';

  _registerOnFirebase() {
    _firebaseMessaging.subscribeToTopic(usuarioLogado.UsuarioUID);
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  HelperDB helperDB = HelperDB();
  Usuario usuarioLogado = Usuario();

  @override
  void initState(){
    super.initState();
    helperDB.getUsuarioLogado().then((usuario){
      setState(() {
        usuarioLogado = usuario;
        _registerOnFirebase();
        getMessage();
      });
    });
  }

  void getMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('received message ${message["notification"]["body"]}');
      }, onResume: (Map<String, dynamic> message) async {
        print('on resume ${message["notification"]["body"]}');
      }, onLaunch: (Map<String, dynamic> message) async {
        print('on launch ${message["notification"]["body"]}');
    });
  }

  int _currentPage = 0;

  Widget getPage(){
    if (_currentPage == 0)
      return PrestacaoContasTabs();
    else if (_currentPage == 1){
      if (usuarioLogado.IsGerente != null && usuarioLogado.IsGerente)
        return AdiantamentoTabs();
      else
        return AdiantamentoPage();
    }
    else if (_currentPage == 2)
      return ApontamentoTabs();
    else
      return Container();
  }

  void SelectPage(index){
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(_currentPage == 0 ? "Prestação de Contas" : _currentPage == 1 ? "Adiantamentos" : "Apontamento",
              style: TextStyle(color: Colors.white)
          ),
          backgroundColor: Color.fromRGBO(36, 177, 139, 1),
          centerTitle: true,
        ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bem vindo!", style: TextStyle(color: Colors.white)),
                  Text(usuarioLogado.Nome?? "Olá",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0
                    ),
                  ),
                  Text("Atualizado em: ${ DateFormat('dd/MM/yyyy').format(usuarioLogado.WorkOffline == "1" ? DateTime.parse(usuarioLogado.AtualizadoEm) : DateTime.now())}", style: TextStyle(color: Colors.white))
                ],
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 3.0
                      )
                  )
              ),
            ),
            ListTile(
              title: Text('Prestação de Contas'),
              leading: Icon(Icons.credit_card),
              selected: _currentPage == 0,
              onTap: () {
                SelectPage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Adiantamento'),
              leading: Icon(Icons.attach_money),
              selected: _currentPage == 1,
              onTap: () {
                SelectPage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Apontamentos'),
              leading: Icon(Icons.calendar_today),
              selected: _currentPage == 2,
              onTap: () {
                SelectPage(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sair'),
              leading: Icon(Icons.logout),
              onTap: () async {
                if (await confirm(
                    context,
                    title: Text("Sair"),
                    content: Text("Tem certeza que sair? Todas as informações não enviadas serão perdidas."),
                    textOK: Text("Sim"),
                    textCancel: Text("Não")
                )) {
                  helperDB.logOut().then((deleted){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                          (Route<dynamic> route) => false,
                    );
                  });
                }
              },
            ),
          ],
        )
      ),
      body: getPage()
    );
  }
}