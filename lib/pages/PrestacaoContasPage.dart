import 'dart:convert';
import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:mvapp/pages/FormPrestacaoContas.dart';
import 'package:intl/intl.dart';
import 'package:mvapp/pages/PrestacaoContasGrupo.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:mvapp/helpers/constants.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class PrestacaoContasPage extends StatefulWidget {
  @override
  _PrestacaoContasPageState createState() => _PrestacaoContasPageState();
}

class _PrestacaoContasPageState extends State<PrestacaoContasPage> {

  bool hasConnection = false;

  ProgressDialog loading;

  Usuario usuarioLogado = Usuario();

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  HelperDB helperDB = HelperDB();

  List<PrestacaoContas> prestacaoContas = [];
  List<Projeto> PC_projetos = [];

  void loadPrescataoContas(){
    helperDB.getAllPrestacaoContas().then((_prestacaoContas){

      _prestacaoContas.sort((a, b) => a.CodigoGrupo.compareTo(b.CodigoGrupo));

      List<PrestacaoContas> _temp = [];
      List<Projeto> _temp_projetos = [];

      for (PrestacaoContas pc in _prestacaoContas){
        PrestacaoContas _pc = _temp.firstWhere((x) => x.CodigoGrupo == pc.CodigoGrupo, orElse: () => null);

        if (_pc == null){
          _temp.add(pc);
        }
        else {
          _pc.Valor += pc.Valor;
        }

        Projeto p = _temp_projetos.firstWhere((x) => x.ProjectUID == pc.ProjectUID, orElse: () => null);

        if (p == null) {
          Projeto projeto = Projeto();
          projeto.ProjectUID = pc.ProjectUID;
          projeto.NomeProjeto = pc.NomeProjeto;
          _temp_projetos.add(projeto);
        }
      }
      
      setState(() {
        prestacaoContas = _temp;
        PC_projetos = _temp_projetos;
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
    loadUsuarioLogado();
    loadPrescataoContas();
  }

  Widget _builderListViewPrestacaoContas(){
    return ListView.builder(
      itemBuilder: (context, index){
        List<PrestacaoContas> grouped = prestacaoContas.where((x) => x.ProjectUID == PC_projetos[index].ProjectUID).toList();
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                "${PC_projetos[index].NomeProjeto}",
                style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return GestureDetector(
                    child: Card(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("PC - ${grouped[index].CodigoGrupo}",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                SizedBox(height: 5.0),
                                Text(currency.format(grouped[index].Valor),
                                  style: TextStyle(fontSize: 14.0),
                                )
                              ],
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: !hasConnection ? null : () async {
                              if (await confirm(
                              context,
                              title: Text("Atenção"),
                              content: Text("Tem certeza que deseja enviar a PC ${grouped[index].CodigoGrupo}? Após enviada, será removida do seu dispositivo e não poderá mais ser editada."),
                              textOK: Text("Sim"),
                              textCancel: Text("Não")
                              )) {

                                await loading.show();

                                helperDB.getPrestacaoContasByCodigoGrupo(grouped[index].CodigoGrupo).then((pcs) async {
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

                                              Alert(message: 'PC não enviada. Verifique os lançamentos para mais informações.').show();
                                            }
                                            else  {
                                              Alert(message: 'PC enviada com sucesso!').show();

                                              helperDB.deletePrestacaoContasByCodigoGrupo(pcs.first.CodigoGrupo).then((e){
                                                loadPrescataoContas();
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
                            child: Container(
                              width: 80.0,
                              height: 80.0,
                              child: Icon(
                                Icons.send,
                                size: 30.0,
                                color: !hasConnection ? Colors.black12 : Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PrestacaoContasGrupo(grouped[index]))
                      ).then((e){
                        loadPrescataoContas();
                      });
                    },
                  );
                },
                itemCount: grouped.length,
                shrinkWrap: true,
              )
            ],
          ),
        );
      },
      itemCount: PC_projetos.length);
  }

  Widget _buildContainerNoData(){
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Nenhuma Prestação de Contas Cadastrada",
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
          color: Colors.black26
        )
      ),
    );
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
      body: prestacaoContas.length > 0 ? _builderListViewPrestacaoContas() : _buildContainerNoData(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add
        ),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        onPressed: (){
          PrestacaoContas pc = PrestacaoContas();

          if (prestacaoContas.length > 0){
            prestacaoContas.sort((a, b) => a.CodigoGrupo.compareTo(b.CodigoGrupo));
            pc.CodigoGrupo = (int.parse(prestacaoContas.last.CodigoGrupo) + 1).toString().padLeft(4, "0");
          }
          else
            pc.CodigoGrupo = (1).toString().padLeft(4, "0");

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
