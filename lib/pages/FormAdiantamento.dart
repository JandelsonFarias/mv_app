import 'dart:convert';
import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;
import 'package:mvapp/validators/AdiantamentoValidator.dart';
import 'package:uuid/uuid.dart';

class FormAdiantamento extends StatefulWidget {
  final Adiantamento adiantamento;

  FormAdiantamento(this.adiantamento);

  @override
  _FormAdiantamentoState createState() => _FormAdiantamentoState();
}

class _FormAdiantamentoState extends State<FormAdiantamento> with AdiantamentoValidator {

  HelperDB helperDB = HelperDB();

  Usuario usuarioLogado = Usuario();

  List<Projeto> Projetos = [];
  List<DropdownMenuItem<String>> dowpDownMenuItems_projeto;
  Projeto ProjetoSelecionado = Projeto();

  bool validar = false;

  DateTime SelectedDataInicio;
  DateTime SelectedDataFim;

  final _formKey = GlobalKey<FormState>();

  MoneyMaskedTextController ValorApontadoController = new MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  TextEditingController JustificativaController = TextEditingController();

  bool carregando = true;

  @override
  void initState(){
    super.initState();

    if (widget.adiantamento.DataInicio != null)
      SelectedDataInicio = new DateTime(int.parse(widget.adiantamento.DataInicio.split("/")[2]), int.parse(widget.adiantamento.DataInicio.split("/")[1]), int.parse(widget.adiantamento.DataInicio.split("/")[0]));

    if (widget.adiantamento.DataFim != null)
      SelectedDataFim = new DateTime(int.parse(widget.adiantamento.DataFim.split("/")[2]), int.parse(widget.adiantamento.DataFim.split("/")[1]), int.parse(widget.adiantamento.DataFim.split("/")[0]));

    if (widget.adiantamento.ValorApontado != null)
      ValorApontadoController.updateValue(widget.adiantamento.ValorApontado);

    if (widget.adiantamento.Justificativa != null)
      JustificativaController.text = widget.adiantamento.Justificativa;

    helperDB.getUsuarioLogado().then((usuario){

      usuarioLogado = usuario;
      widget.adiantamento.UsuarioUID = usuario.UsuarioUID;

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

  LoadProjetos() async {
    http.Response response;
    response = await http.get(baseApiURL + "Projeto/GetProjetos/?UsuarioUID=" + usuarioLogado.UsuarioUID + "&ResourceUID=" + usuarioLogado.ResourceUID);

    if (response.statusCode == 200){
      var projetos = json.decode(response.body);

      Projetos = [];

      for (var item in projetos){
        Projeto p = Projeto();
        p.ProjectUID = item["ProjectUID"];
        p.NomeProjeto = item["NomeProjeto"];
        //Projetos.add(p);
      }

      setState(() {
        dowpDownMenuItems_projeto = _builddowpDownMenuItemsProjeto();

        if (widget.adiantamento.AdiantamentoUID != null){
          ProjetoSelecionado.ProjectUID = widget.adiantamento.ProjectUID;
          ProjetoSelecionado.NomeProjeto = widget.adiantamento.NomeProjeto;
        }

        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AD - " + widget.adiantamento.AdiantamentoCodigo),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1)
      ),
      body: carregando ?
      Center(
        child: CircularProgressIndicator(),
      )
          :
      Projetos.length == 0 ?
      Center(
        child: Text("Esse usuário não está alocado em nenhum projeto."),
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
                  absorbing: widget.adiantamento.ProjectUID != null ? true : false,
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
                  child: Text("De"),
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: validar && (SelectedDataInicio == null || (SelectedDataFim != null && SelectedDataInicio.isAfter(SelectedDataFim))) ? Colors.red : Colors.black12),
                      ),
                      alignment: Alignment.centerRight,
                      child:
                      Row(
                        children: <Widget>[
                          Text(
                            SelectedDataInicio != null ?  "${SelectedDataInicio.day}/${SelectedDataInicio.month}/${SelectedDataInicio.year}" : "-",
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
                      showDatePicker(
                          context: context,
                          initialDate: SelectedDataInicio?? DateTime.now(),
                          firstDate: DateTime.now().subtract(new Duration(days: 60)),
                          lastDate: DateTime(DateTime.now().year + 1),
                          locale: const Locale("pt","BR")
                      ).then((date) {
                        if (date != null){
                          setState(() {
                            SelectedDataInicio = new DateTime(date.year, date.month, date.day);
                          });
                        }
                      });
                      // var datePicked = await DatePicker.showSimpleDatePicker(
                      //   context,
                      //   initialDate: SelectedDataInicio?? DateTime.now(),
                      //   firstDate: DateTime.now().subtract(new Duration(days: 60)),
                      //   lastDate: DateTime(DateTime.now().year + 1),
                      //   dateFormat: "dd-MM-yyyy",
                      //   locale: DateTimePickerLocale.pt_br,
                      //   looping: true,
                      //   titleText: "Selecionar Data"
                      // );
                      //
                      // setState(() {
                      //   SelectedDataInicio = datePicked;
                      // });
                    }
                ),
                Visibility(
                  visible: (validar && SelectedDataInicio == null),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "Informe a Data",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.red
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: (validar && SelectedDataInicio != null && SelectedDataFim != null && SelectedDataInicio.isAfter(SelectedDataFim)),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "A data de início não pode ser maior que a data final",
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
                  child: Text("Até"),
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: validar && (SelectedDataInicio == null || (SelectedDataFim != null && SelectedDataInicio.isAfter(SelectedDataFim))) ? Colors.red : Colors.black12),
                      ),
                      alignment: Alignment.centerRight,
                      child:
                      Row(
                        children: <Widget>[
                          Text(
                            SelectedDataFim != null ?  "${SelectedDataFim.day}/${SelectedDataFim.month}/${SelectedDataFim.year}" : "-",
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
                      showDatePicker(
                          context: context,
                          initialDate: SelectedDataFim?? DateTime.now(),
                          firstDate: DateTime.now().subtract(new Duration(days: 60)),
                          lastDate: DateTime(DateTime.now().year + 1),
                          locale: const Locale("pt","BR")
                      ).then((date) {
                        if (date != null){
                          setState(() {
                            SelectedDataFim = new DateTime(date.year, date.month, date.day);
                          });
                        }
                      });
                      // var datePicked = await DatePicker.showSimpleDatePicker(
                      //     context,
                      //     initialDate: SelectedDataFim?? DateTime.now(),
                      //     firstDate: DateTime.now().subtract(new Duration(days: 60)),
                      //     lastDate: DateTime(DateTime.now().year + 1),
                      //     dateFormat: "dd-MM-yyyy",
                      //     locale: DateTimePickerLocale.pt_br,
                      //     looping: true,
                      //     titleText: "Selecionar Data"
                      // );
                      //
                      // setState(() {
                      //   SelectedDataFim = datePicked;
                      // });
                    }
                ),
                Visibility(
                  visible: (validar && SelectedDataFim == null),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "Informe a Data",
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.red
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: (validar && SelectedDataInicio != null && SelectedDataFim != null && SelectedDataInicio.isAfter(SelectedDataFim)),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      "A data de início não pode ser maior que a data final",
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
                  child: Text("Valor Solicitado"),
                ),
                TextFormField(
                  controller: ValorApontadoController,
                  keyboardType: TextInputType.number,
                  validator: validateValorApontado,
                ),
                SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Justificativa"),
                ),
                TextFormField(
                  controller: JustificativaController,
                  maxLines: 4,
                  validator: validateJustificativa,
                )
              ],
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        onPressed: !carregando && Projetos.length == 0 ? null : (){
          setState(() {
            validar = true;
          });

          if(_formKey.currentState.validate() && SelectedDataInicio != null && SelectedDataFim != null && SelectedDataFim.isAfter(SelectedDataInicio)){
            widget.adiantamento.ProjectUID = ProjetoSelecionado.ProjectUID;
            widget.adiantamento.NomeProjeto = ProjetoSelecionado.NomeProjeto;
            widget.adiantamento.DataInicio = "${SelectedDataInicio.day}/${SelectedDataInicio.month}/${SelectedDataInicio.year}";
            widget.adiantamento.DataFim = "${SelectedDataFim.day}/${SelectedDataFim.month}/${SelectedDataFim.year}";
            widget.adiantamento.ValorApontado = ValorApontadoController.numberValue;
            widget.adiantamento.Justificativa = JustificativaController.text;

            if (widget.adiantamento.AdiantamentoUID != null){
              helperDB.updateAdiantamento(widget.adiantamento).then((adiantamento){
                Alert(message: 'Adiantamento editado com sucesso!').show();
                Navigator.pop(context);
              });
            }
            else  {
              widget.adiantamento.AdiantamentoUID = Uuid().v1().toString();

              helperDB.saveAdiantamento(widget.adiantamento).then((adiantamento){
                Alert(message: 'Adiantamento salvo com sucesso!').show();
                Navigator.pop(context);
              });
            }
          }
        },
      ),
    );
  }
}
