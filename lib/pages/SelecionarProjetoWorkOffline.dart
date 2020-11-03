import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

import 'Home.dart';

class SelecionarProjetoWorkOffline extends StatefulWidget {
  @override
  _SelecionarProjetoWorkOfflineState createState() => _SelecionarProjetoWorkOfflineState();
}

class _SelecionarProjetoWorkOfflineState extends State<SelecionarProjetoWorkOffline> {

  HelperDB helperDB = HelperDB();
  Usuario usuarioLogado = Usuario();

  List<Projeto> projetos = [];
  List<Projeto> projetos_filtrados = [];

  ProgressDialog loading;

  @override
  void initState(){
    super.initState();

    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
      LoadProjetos();
    });
  }

  LoadProjetos() async {
    String UsuarioUID = usuarioLogado.UsuarioUID;
    String ResourceUID = usuarioLogado.ResourceUID;

    http.Response response;
    response = await http.get(baseApiURL + "Projeto/GetProjetos/?UsuarioUID=$UsuarioUID&ResourceUID=$ResourceUID");

    if (response.statusCode == 200){
      List maps = json.decode(response.body);

      List<Projeto> temp = [];

      for (Map map in maps){
        Projeto projeto = Projeto();
        projeto.ProjectUID = map["ProjectUID"];
        projeto.NomeProjeto = map["NomeProjeto"];

        temp.add(projeto);
      }

      if (temp.length > 0) {
        setState(() {
          projetos = temp;
          loading.hide();
        });
      }
    }
  }

  SaveProjetoSelecionado(Projeto projetoSelecionado) async {
    helperDB.saveProjetoSelecionado(projetoSelecionado).then((projeto) async {
      http.Response response;
      String ProjectUID = projeto.ProjectUID;

      response = await http.get(baseApiURL + "Projeto/GetProjetoInformacoes/?ProjectUID=$ProjectUID");

      if (response.statusCode == 200){
        Map map = json.decode(response.body);

        for (var item in map["Despesas"]){
          Despesa despesa = Despesa();
          despesa.DespesaUID = item["DespesaUID"];
          despesa.ProjectUID = item["ProjectUID"];
          despesa.NomeDespesa = item["NomeDespesa"];

          await helperDB.saveDespesa(despesa);
        }

        await loading.hide();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    loading = ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false);

    loading.style(
        message: 'Carregando informações do projeto...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Projetos"),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(7.0, 1.0, 7.0, 1.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquisar",
                labelStyle: TextStyle(
                  color: Color.fromRGBO(36, 177, 139, 1)
                )
              ),
              onChanged: (text){
                setState(() {
                  if(text.isNotEmpty){
                    projetos_filtrados = projetos.where((f) => f.NomeProjeto.contains(text)).toList();

                    if (projetos_filtrados.length == 0){
                      Projeto p = Projeto();
                      p.ProjectUID = "";
                      p.NomeProjeto = "Nenhum projeto encontrado";
                      projetos_filtrados.add(p);
                    }
                  }
                  else
                    projetos_filtrados = [];
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: projetos_filtrados.length == 0 && projetos.length == 0 ? 1 : projetos_filtrados.length > 0 ? projetos_filtrados.length : projetos.length,
                itemBuilder: (context, index){
                  if (projetos_filtrados.length == 0 && projetos.length == 0)  {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else {
                    return Container(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        title: Text(
                          projetos_filtrados.length > 0 ? projetos_filtrados[index].NomeProjeto : projetos[index].NomeProjeto,
                          textAlign:  projetos_filtrados.length > 0 && projetos_filtrados[0].ProjectUID.isEmpty ? TextAlign.center : TextAlign.left,
                        ),
                        onTap: () async {
                          Projeto projetoSelecionado = projetos_filtrados.length > 0 ? projetos_filtrados[index] : projetos[index];

                          if (projetoSelecionado.ProjectUID.isNotEmpty){

                            if (await confirm(
                                context,
                                title: Text("Confirmar"),
                                content: Text("Tem certeza que deseja selecionar este projeto para trabalhar offline?"),
                                textOK: Text("Sim"),
                                textCancel: Text("Não")
                            )) {
                              await loading.show();
                              //print(projetoSelecionado.ProjectUID);
                              SaveProjetoSelecionado(projetoSelecionado);
                            }
                          }
                        },
                      ),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.black12)
                          )
                      ),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}
