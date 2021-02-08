import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
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
                Icons.logout,
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
                  helperDB.logOut().then((deleted){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                          (Route<dynamic> route) => false,
                    );
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