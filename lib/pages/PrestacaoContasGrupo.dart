import 'dart:convert';

import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/FormPrestacaoContas.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:mvapp/helpers/constants.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class PrestacaoContasGrupo extends StatefulWidget {

  final PrestacaoContas prestacaoContas;

  PrestacaoContasGrupo(this.prestacaoContas);

  @override
  _PrestacaoContasGrupoState createState() => _PrestacaoContasGrupoState();
}

class _PrestacaoContasGrupoState extends State<PrestacaoContasGrupo> {

  bool hasConnection = false;

  Usuario usuarioLogado = Usuario();

  ProgressDialog loading;

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  HelperDB helperDB = HelperDB();

  List<PrestacaoContas> prestacaoContas = [];

  PrestacaoContas prestacaoContas_removida;
  int prestacaoContas_removida_posicao;

  void loadPrescataoContas() {
    helperDB.getPrestacaoContasByCodigoGrupo(widget.prestacaoContas.CodigoGrupo).then((_prestacaoContas){
      setState(() {
        prestacaoContas = _prestacaoContas;
      });
    });
  }

  void loadUsuarioLogado(){
    helperDB.getUsuarioLogado().then((usuario){
      usuarioLogado = usuario;
    });
  }

  void verifyConnection() async {
    bool con = await DataConnectionChecker().hasConnection;
    setState(()  {
      hasConnection = con;
    });
  }

  @override
  void initState(){
    super.initState();
    verifyConnection();
    loadPrescataoContas();
    loadUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {

    loading = ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: false);

    loading.style(
        message: 'Enviando...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("PC - " + widget.prestacaoContas.CodigoGrupo),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () async {
              if (await confirm(
                  context,
                  title: Text("Atenção"),
                  content: Text("Tem certeza que deseja deletar a PC ${widget.prestacaoContas.CodigoGrupo}?"),
                  textOK: Text("Sim"),
                  textCancel: Text("Não")
              )) {
                helperDB.deletePrestacaoContasByCodigoGrupo(widget.prestacaoContas.CodigoGrupo).then((deleted){
                  Alert(message: 'Prestação de Contas deletada com sucesso!').show();
                  Navigator.pop(context);
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: !hasConnection ? Colors.black12 : Colors.white,
            ),
            onPressed: !hasConnection ? null : () async {
              if (await confirm(
                  context,
                  title: Text("Atenção"),
                  content: Text("Tem certeza que deseja enviar a PC ${widget.prestacaoContas.CodigoGrupo}? Após enviada, será removida do seu dispositivo e não poderá mais ser editada."),
                  textOK: Text("Sim"),
                  textCancel: Text("Não")
              )) {

                await loading.show();

                helperDB.getPrestacaoContasByCodigoGrupo(widget.prestacaoContas.CodigoGrupo).then((pcs) async {
                  var request = http.MultipartRequest('POST', Uri.parse(baseApiURL + "PrestacaoContas/UploadToS3"));

                  try {
                    for (PrestacaoContas pc in pcs.where((x) => x.LinkAnexo == null)){
                      request.files.add(
                          await http.MultipartFile.fromPath(pc.PrestacaoContasUID, pc.AttachmentPath));
                    }
                  }
                  catch (ex) {
                    await loading.hide().then((e){
                      Alert(message: 'Erro ao buscar anexos no dispositivo. ${ex.toString()}').show();
                    });
                  }

                  request.send().then((result) async {
                    if (result.statusCode == 200){
                      result.stream.transform(utf8.decoder).listen((value) {
                        var maps = json.decode(value);

                        for (Map map in maps) {
                          PrestacaoContas pc = pcs.firstWhere((x) => x.PrestacaoContasUID == map["PrestacaoContasUID"]);
                          pc.UsuarioUID = usuarioLogado.UsuarioUID;
                          pc.LinkAnexo = map["LinkAnexo"];
                        }

                        PrestacaoContasGrupoPost pcs_post = PrestacaoContasGrupoPost(pcs);

                        http.post(
                            baseApiURL + "PrestacaoContas/SalvarPrestacaoContas",
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(pcs_post)
                        ).then((response) async {

                          await loading.hide();

                          if (response.statusCode == 200){
                            if (response.body.isNotEmpty) {
                              var map = json.decode(response.body);

                              var pcs_retornadas = map["_PrestacaoContas"];

                              for (Map pc_retornada_map in pcs_retornadas){
                                PrestacaoContas _pc_retornada = pcs.firstWhere((x) => x.PrestacaoContasUID == pc_retornada_map["PrestacaoContasUID"]);
                                _pc_retornada.Erros = pc_retornada_map["Erros"].toString().isEmpty ? null : pc_retornada_map["Erros"];
                                helperDB.updatePrestacaoContas(_pc_retornada);
                              }

                              Alert(message: 'PC não enviada.').show();
                              loadPrescataoContas();
                            }
                            else  {
                              Alert(message: 'PC enviada com sucesso!').show();

                              helperDB.deletePrestacaoContasByCodigoGrupo(pcs.first.CodigoGrupo).then((e){
                                Navigator.of(context).pop();
                              });
                            }
                          }
                          else  {
                            Alert(message: 'Erro ao enviar. ${response.body}').show();
                          }
                        });
                      });
                    }
                    else {
                      await loading.hide().then((e){
                        result.stream.transform(utf8.decoder).listen((value) {
                          Alert(message: 'Erro ao enviar. $value').show();
                        });
                      });
                    }
                  });
                });
              }
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15.0),
            alignment: Alignment.center,
            child: Text(
              "${widget.prestacaoContas.NomeProjeto}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0
              ),
            )
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(prestacaoContas[index].PrestacaoContasUID),
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment(-0.9, 0.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white
                    ),
                  ),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction){
                  setState(() {
                    prestacaoContas_removida = prestacaoContas[index];
                    prestacaoContas_removida_posicao = index;
                    prestacaoContas.removeAt(index);

                    helperDB.deletePrestacaoContasByUID(prestacaoContas_removida.PrestacaoContasUID);

                    final snack = SnackBar(
                      content: Text("Prestação de Contas removida!"),
                      action: SnackBarAction(
                        label: "Desfazer",
                        onPressed: (){
                          setState(() {
                            prestacaoContas.insert(prestacaoContas_removida_posicao, prestacaoContas_removida);
                            helperDB.savePrestacaoContas(prestacaoContas_removida);
                          });
                        },
                      ),
                      duration: Duration(
                        seconds: 3
                      )
                    );

                    Scaffold.of(context).showSnackBar(snack);
                  });
                },
                child: GestureDetector(
                  child: Card(
                    shape: prestacaoContas[index].Erros != null ?
                      RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.red,
                          width: 1.0
                        ),
                        borderRadius: BorderRadius.circular(4.0)
                      )
                        :
                      RoundedRectangleBorder(
                        side: new BorderSide(color: Colors.transparent, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0)
                      ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(prestacaoContas[index].NomeDespesa.length > 25 ? "${prestacaoContas[index].NomeDespesa.substring(0, 25)}..." : prestacaoContas[index].NomeDespesa,
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(height: 5.0),
                              Text(prestacaoContas[index].Data,
                                style: TextStyle(fontSize: 14.0),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(currency.format(prestacaoContas[index].Valor),
                            style: TextStyle(fontSize: 20.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FormPrestacaoContas(prestacaoContas[index]))
                    ).then((e){
                      loadPrescataoContas();
                    });
                  },
                ),
              );
            },
            itemCount: prestacaoContas.length,
            shrinkWrap: true
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
            Icons.add
        ),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        onPressed: (){
          PrestacaoContas pc = PrestacaoContas();
          pc.CodigoGrupo = widget.prestacaoContas.CodigoGrupo;
          pc.ProjectUID = widget.prestacaoContas.ProjectUID;
          pc.NomeProjeto = widget.prestacaoContas.NomeProjeto;

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FormPrestacaoContas(pc))
          ).then((e){
            loadPrescataoContas();
          });
        },
      ),
    );
  }
}
