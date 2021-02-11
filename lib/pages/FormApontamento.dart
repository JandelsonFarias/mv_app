import 'dart:convert';

import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;
import 'package:mvapp/pages/SelecionarAtividade.dart';
import 'package:mvapp/validators/ApontamentoValidator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:uuid/uuid.dart';

class FormApontamento extends StatefulWidget {
  final Apontamento apontamento;

  FormApontamento(this.apontamento);

  @override
  _FormApontamentoState createState() => _FormApontamentoState();
}

class _FormApontamentoState extends State<FormApontamento> with ApontamentoValidator {

  HelperDB helperDB = HelperDB();

  Usuario usuarioLogado = Usuario();

  List<Projeto> Projetos = [];
  List<DropdownMenuItem<String>> dowpDownMenuItems_projeto;
  Projeto ProjetoSelecionado = Projeto();

  bool validar = false;

  DateTime SelectedData;

  var maskFormatter = new MaskTextInputFormatter(mask: '##:##', filter: { "#": RegExp(r'[0-9]') });

  final _formKey = GlobalKey<FormState>();

  TextEditingController ObservacoesController = TextEditingController();
  TextEditingController HorasApontadasController = TextEditingController();
  TextEditingController HorasRestantesController = TextEditingController();

  LoadProjetos() async {
    http.Response response;
    response = await http.get(baseApiURL + "Projeto/GetProjetosApontamento/?ResourceUID=" + usuarioLogado.ResourceUID);

    if (response.statusCode == 200){
      var projetos = json.decode(response.body);

      Projetos = [];

      for (var item in projetos){
        Projeto p = Projeto();
        p.ProjectUID = item["ProjectUID"];
        p.NomeProjeto = item["NomeProjeto"];
        Projetos.add(p);
      }

      setState(() {
        dowpDownMenuItems_projeto = _builddowpDownMenuItemsProjeto();

        if (widget.apontamento.ApontamentoUID != null){
          ProjetoSelecionado.ProjectUID = widget.apontamento.ProjectUID;
          ProjetoSelecionado.NomeProjeto = widget.apontamento.NomeProjeto;
        }
      });
    }
  }

  List<DropdownMenuItem<String>> _builddowpDownMenuItemsProjeto(){
    List<DropdownMenuItem<String>> items = List();

    if (ProjetoSelecionado != null && ProjetoSelecionado.ProjectUID != null && ProjetoSelecionado.ProjectUID != ""){
      Projetos.add(ProjetoSelecionado);
    }

    if (Projetos.length > 0){
      for (Projeto p in Projetos){
        items.add(
            DropdownMenuItem(
                value: p.ProjectUID,
                child: Text(p.NomeProjeto)
            )
        );
      }
    }

    return items;
  }

  @override
  void initState(){
    super.initState();

    if (widget.apontamento.NewTimeByDay != null)
      SelectedData = new DateTime(int.parse(widget.apontamento.NewTimeByDay.split("/")[2]), int.parse(widget.apontamento.NewTimeByDay.split("/")[1]), int.parse(widget.apontamento.NewTimeByDay.split("/")[0]));

    if (widget.apontamento.HorasApontadas != null)
      HorasApontadasController.text = widget.apontamento.HorasApontadas;

    if (widget.apontamento.HorasRestantes != null)
      HorasRestantesController.text = widget.apontamento.HorasRestantes;

    if (widget.apontamento.Observacoes != null)
      ObservacoesController.text = widget.apontamento.Observacoes;

    helperDB.getUsuarioLogado().then((usuario){

      usuarioLogado = usuario;
      widget.apontamento.ResourceUID = usuario.ResourceUID;

      helperDB.getProjetoSelecionado().then((projeto){
        if (projeto != null){
          setState(() {
            ProjetoSelecionado = projeto;
            dowpDownMenuItems_projeto = _builddowpDownMenuItemsProjeto();
          });
        }
        else
        {
          LoadProjetos();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Apontamento"),
          backgroundColor: Color.fromRGBO(36, 177, 139, 1)
      ),
      body: Projetos.length == 0 ?
      Center(
        child: CircularProgressIndicator(),
      )
          :
      SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Projeto"),
                ),
                AbsorbPointer(
                  absorbing: widget.apontamento.ProjectUID != null ? true : false,
                  child: DropdownButtonFormField<String>(
                    value: ProjetoSelecionado.ProjectUID,
                    icon: Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
                    iconSize: 24.0,
                    elevation: 16,
                    /*style: TextStyle(
                      color: Color.fromRGBO(36, 177, 139, 1)
                  ),*/
                    onChanged: (projeto){
                      setState(() {
                        ProjetoSelecionado = Projetos.firstWhere((x) => x.ProjectUID == projeto, orElse: () => Projeto());
                      });
                    },
                    items: dowpDownMenuItems_projeto,
                    validator: validatorProjeto,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Atividade"),
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: validar && widget.apontamento.TaskUID == null ? Colors.red : Colors.black12),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(widget.apontamento.TaskName?? "Selecionar"),
                        ),
                        Visibility(
                          child: Text(widget.apontamento.TaskUID != null ? "${DateTime.parse(widget.apontamento.TimeByDay).day}/${DateTime.parse(widget.apontamento.TimeByDay).month}/${DateTime.parse(widget.apontamento.TimeByDay).year}" : "-"),
                          visible: widget.apontamento.TaskUID != null ? true : false
                        )
                      ],
                    ),
                  ),
                  onTap: (){
                    if (ProjetoSelecionado != null && ProjetoSelecionado.ProjectUID != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SelecionarAtividade(ProjetoSelecionado, usuarioLogado))
                      ).then((e){
                        if (e != null){
                          setState(() {
                            widget.apontamento.TaskUID = e.TaskUID;
                            widget.apontamento.TaskName = e.TaskName;
                            widget.apontamento.AssignmentUID = e.AssignmentUID;
                            widget.apontamento.TimeByDay = e.TimeByDay;
                          });
                        }
                      });
                    }
                    else{
                      Alert(message: 'Selecione o Projeto').show();
                    }
                  },
                ),
                Visibility(
                  visible: (validar && widget.apontamento.TaskUID == null),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "Informe a Atividade",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.red
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Horas Trabalhadas"),
                ),
                TextFormField(
                  controller: HorasApontadasController,
                  inputFormatters: [maskFormatter],
                  validator: validateHorasApontadas,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Horas Restantes"),
                ),
                TextFormField(
                  controller: HorasRestantesController,
                  inputFormatters: [maskFormatter],
                  keyboardType: TextInputType.number,
                  validator: validateHorasRestantes,
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Data do Apontamento"),
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: validar && SelectedData == null ? Colors.red : Colors.black12),
                      ),
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: <Widget>[
                          Text(
                            SelectedData != null ?  "${SelectedData.day}/${SelectedData.month}/${SelectedData.year}" : "-",
                            style: TextStyle(
                                fontSize: 16.0
                            ),
                          ),
                          Spacer(),
                          Icon(
                              Icons.calendar_today
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      var datePicked = await DatePicker.showSimpleDatePicker(
                          context,
                          initialDate: SelectedData?? DateTime.now(),
                          firstDate: DateTime.now().subtract(new Duration(days: 60)),
                          lastDate: DateTime(DateTime.now().year + 1),
                          dateFormat: "dd-MM-yyyy",
                          locale: DateTimePickerLocale.pt_br,
                          looping: true,
                          titleText: "Selecionar Data"
                      );

                      setState(() {
                        SelectedData = datePicked;
                      });
                    }
                ),
                Visibility(
                  visible: (validar && SelectedData == null),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "Informe a Data do Apontamento",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.red
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Observações"),
                ),
                TextFormField(
                  controller: ObservacoesController,
                  maxLines: 4,
                  validator: validateObservacoes,
                )
              ],
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        onPressed: (){
          setState(() {
            validar = true;
          });

          if(_formKey.currentState.validate() && SelectedData != null && widget.apontamento.TaskUID != null){
            widget.apontamento.ProjectUID = ProjetoSelecionado.ProjectUID;
            widget.apontamento.NomeProjeto = ProjetoSelecionado.NomeProjeto;
            widget.apontamento.NewTimeByDay = "${SelectedData.day}/${SelectedData.month}/${SelectedData.year}";
            widget.apontamento.HorasApontadas = HorasApontadasController.text;
            widget.apontamento.HorasRestantes = HorasRestantesController.text;
            widget.apontamento.Observacoes = ObservacoesController.text;

            if (widget.apontamento.ApontamentoUID != null){
              helperDB.updateApontamento(widget.apontamento).then((apotamento){
                Alert(message: 'Apontamento editado com sucesso!').show();
                Navigator.pop(context);
              });
            }
            else  {
              widget.apontamento.ApontamentoUID = Uuid().v1().toString();

              helperDB.saveApontamento(widget.apontamento).then((apotamento){
                Alert(message: 'Apontamento salvo com sucesso!').show();
                Navigator.pop(context);
              });
            }
          }
        },
      ),
    );
  }
}
