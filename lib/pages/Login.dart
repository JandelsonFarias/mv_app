import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:alert/alert.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/Home.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'SelecionarProjetoWorkOffline.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool verificandoUsuarioLogado = true;

  HelperDB helperDB = HelperDB();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController usuarioController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  ProgressDialog loading;

  bool workOffline = false;

  bool usuarioEmpty = true;
  bool senhaEmpty = true;

  @override
  void initState(){
    super.initState();
    helperDB.getUsuarioLogado().then((usuarioLogado){
      if (usuarioLogado == null){
        Future.delayed(
          new Duration(seconds: 2), () => {
            setState(() {
            verificandoUsuarioLogado = false;
            })
          }
        );
      }
      else if (usuarioLogado.WorkOffline == "0") {
        Future.delayed(
          new Duration(seconds: 2), () => {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,
            )
          }
        );
      }
      else {
        helperDB.getProjetoSelecionado().then((projetoSelecionado){
          if (projetoSelecionado == null){
            helperDB.deleteUsuarioLogado().then((deleted){
              Future.delayed(
                new Duration(seconds: 2), () => {
                  setState(() {
                    verificandoUsuarioLogado = false;
                  })
                }
              );
            });
          }
        });
      }
    });
  }

  Widget _buildUsuarioField() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Usuário',
            style: kLabelStyle,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              style: TextStyle(color: Colors.black, fontFamily: 'OpenSans'),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(Icons.account_circle, color: Colors.black),
                  hintText: 'Digite seu Usuário',
                  hintStyle: kHintTextStyle
              ),
              controller: usuarioController,
              onChanged: (text) {
                setState(() {
                  text.isEmpty ? usuarioEmpty = true : usuarioEmpty = false;
                });
              }
            ),
          )
        ]);
  }

  Widget _buildPasswordField() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Senha',
            style: kLabelStyle,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              obscureText: true,
              style: TextStyle(color: Colors.black, fontFamily: 'OpenSans'),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                  hintText: 'Digite sua Senha',
                  hintStyle: kHintTextStyle
              ),
              controller: senhaController,
              onChanged: (text) {
                setState(() {
                  text.isEmpty ? senhaEmpty = true : senhaEmpty = false;
                });
              }
            ),
          )
        ]);
  }

  Widget _buildButtonSignIn() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        disabledColor: Colors.black12,
        disabledTextColor: Colors.white70,
        elevation: 5.0,
        onPressed: (usuarioEmpty || senhaEmpty) ? null : _btnEntrarClick,
        padding: EdgeInsets.all(15.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        color: Colors.white,
        child: Text(
          'ENTRAR',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontFamily: 'OpenSans'),
        ),
      ),
    );
  }

  Future<void> _btnEntrarClick() async {
    await loading.show();
    _efetuarLogin(usuarioController.text, senhaController.text).then((map) async {
      if (map != null){

        if (map["UsuarioUID"] != null){
          Usuario usuario = Usuario();
          usuario.UsuarioUID = map["UsuarioUID"];
          usuario.ResourceUID = map["ResourceUID"];
          usuario.Nome = map["Nome"];
          usuario.WorkOffline = workOffline ? "1" : "0";

          helperDB.saveUsuario(usuario).then((usuario){

            if (workOffline)
            {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SelecionarProjetoWorkOffline()),
                    (Route<dynamic> route) => false,
              );
            }
            else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false,
              );
            }
          });
        }
        else {
          await loading.hide().then((e){
            var a = map["Erro"];

            Alert(message: map["Erro"]).show();
          });
        }
      }
      else {
        await loading.hide().then((e){
          Alert(message: 'Usuário e/ou Senha inválidos').show();
        });
      }
    });
  }

  Widget _buidSwitchWorkOffline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
         'Trabalhar Offline?',
         style: kLabelStyle,
        ),
       SizedBox(height: 10.0),
       Container(
         alignment: Alignment.centerLeft,
         child: FlutterSwitch(
           width: 100.0,
           height: 50.0,
           valueFontSize: 15.0,
           toggleSize: 30.0,
           value: workOffline,
           borderRadius: 15.0,
           padding: 8.0,
           showOnOff: true,
           activeText: 'Sim',
           inactiveText: 'Não',
           toggleColor: workOffline ? Colors.black : Colors.white,
           activeColor: Colors.white,
           activeTextColor: Colors.black,
           inactiveColor: Colors.black,
           inactiveTextColor: Colors.white,
           onToggle: (val) {
             setState(() {
               workOffline = val;
             });
           },
         ),
       )
     ],
    );
  }

  Future<Map> _efetuarLogin(usuario, senha) async {
    try {
      http.Response response;
      response = await http.get(baseApiURL + "Usuario/EfetuarLogin/?Login=$usuario&Senha=$senha");

      if (response.statusCode == 200)
        return json.decode(response.body);
      else if (response.statusCode == 401)
        return null;
      else {
        Map map = Map();
        map["Erro"] = "Ocorreu um erro inesperado.";
        return map;
      }
    }
    catch (ex) {
      Map map = Map();
      map["Erro"] = "Ocorreu um erro inesperado.";
      print(ex);
      return map;
    }
  }

  @override
  Widget build(BuildContext context) {

    loading = ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false);

    loading.style(
        message: 'Carregando...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut
    );

    if  (verificandoUsuarioLogado) {
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/MV.png")
                  )
                ),
              ),
              CircularProgressIndicator()
            ],
          )
        ),
      );
    }
    else {
      return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(36, 177, 139, 1),
                            Color.fromRGBO(43, 196, 155, 1),
                            Color.fromRGBO(58, 214, 172, 1),
                            Color.fromRGBO(62, 214, 173, 1),
                          ],
                          stops: [
                            0.1,
                            0.4,
                            0.7,
                            0.9
                          ]
                      )
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 120.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'MV Sistemas',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'OpenSans',
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30.0),
                              _buildUsuarioField(),
                              SizedBox(height: 15.0),
                              _buildPasswordField(),
                              SizedBox(height: 15.0),
                              _buidSwitchWorkOffline(),
                              SizedBox(height: 40.0),
                              _buildButtonSignIn()
                            ],
                          ),
                        )
                    ),
                  )
                ],
              ),
            ),
          )
      );
    }
  }
}
