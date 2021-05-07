import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mvapp/helpers/constants.dart';
import 'package:mvapp/helpers/db.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mvapp/helpers/image_source_sheet.dart';
import 'package:mvapp/validators/PrestacaoContasValidator.dart';
import 'package:uuid/uuid.dart';
import 'package:alert/alert.dart';

class FormPrestacaoContas extends StatefulWidget {

  final PrestacaoContas prestacaoContas;

  FormPrestacaoContas(this.prestacaoContas);

  @override
  _FormPrestacaoContasState createState() => _FormPrestacaoContasState();

}

class _FormPrestacaoContasState extends State<FormPrestacaoContas> with PrestacaoContasValidator{

  HelperDB helperDB = HelperDB();

  Usuario usuarioLogado = Usuario();

  List<Projeto> Projetos = [];
  List<DropdownMenuItem<String>> dowpDownMenuItems_projeto;
  Projeto ProjetoSelecionado = Projeto();

  List<Despesa> Despesas = [];
  List<DropdownMenuItem<String>> dowpDownMenuItems_despesa;
  Despesa DespesaSelecionada = Despesa();

  bool validar = false;

  DateTime SelectedDate;

  final _formKey = GlobalKey<FormState>();

  MoneyMaskedTextController ValorController = new MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  TextEditingController DescricaoController = TextEditingController();

  bool carregando = true;

  @override
  void initState(){
    super.initState();

    if (widget.prestacaoContas.Data != null)
      SelectedDate = new DateTime(int.parse(widget.prestacaoContas.Data.split("/")[2]), int.parse(widget.prestacaoContas.Data.split("/")[1]), int.parse(widget.prestacaoContas.Data.split("/")[0]));

    if (widget.prestacaoContas.Valor != null)
      ValorController.updateValue(widget.prestacaoContas.Valor);

    if (widget.prestacaoContas.Descricao != null)
      DescricaoController.text = widget.prestacaoContas.Descricao;

    helperDB.getUsuarioLogado().then((usuario){

      usuarioLogado = usuario;

      helperDB.getProjetoSelecionado().then((projeto){
        if (projeto != null){
          helperDB.getDespesaByProjectUID(projeto.ProjectUID).then((despesas){
            setState(() {
              Despesas = despesas;
              ProjetoSelecionado = projeto;

              if (widget.prestacaoContas.DespesaUID != null) {
                DespesaSelecionada = Despesas.firstWhere((x) => x.DespesaUID == widget.prestacaoContas.DespesaUID);
              }

              dowpDownMenuItems_projeto = _builddowpDownMenuItemsProjeto();
              dowpDownMenuItems_despesa = _builddowpDownMenuItemsDespesa();

              carregando = false;
            });
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

  List<DropdownMenuItem<String>> _builddowpDownMenuItemsDespesa(){
    List<DropdownMenuItem<String>> items = List();

    if (Despesas.length > 0){
      for (Despesa d in Despesas){
        items.add(
            DropdownMenuItem(
                value: d.DespesaUID,
                child: Text(d.NomeDespesa)
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
        Projetos.add(p);
      }

      setState(() {
        dowpDownMenuItems_projeto = _builddowpDownMenuItemsProjeto();

        if (widget.prestacaoContas.ProjectUID != null){
          ProjetoSelecionado.ProjectUID = widget.prestacaoContas.ProjectUID;
          ProjetoSelecionado.NomeProjeto = widget.prestacaoContas.NomeProjeto;
          LoadDespesas();
        }

        carregando = false;
      });
    }
  }

  LoadDespesas () async {
    http.Response response;
    response = await http.get(baseApiURL + "PrestacaoContas/GetDespesas/?ProjectUID=" + ProjetoSelecionado.ProjectUID);

    if (response.statusCode == 200){
      var despesas = json.decode(response.body);

      Despesas = [];

      for (var item in despesas){
        Despesa d = Despesa();
        d.DespesaUID = item["DespesaUID"];
        d.ProjectUID = item["ProjectUID"];
        d.NomeDespesa = item["NomeDespesa"];
        Despesas.add(d);
      }

      setState(() {
        dowpDownMenuItems_despesa = _builddowpDownMenuItemsDespesa();

        if (widget.prestacaoContas.DespesaUID != null){
          Despesa d = Despesas.firstWhere((x) => x.DespesaUID == widget.prestacaoContas.DespesaUID, orElse: () => null);

          if (d == null)
            widget.prestacaoContas.DespesaUID = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PC - " + widget.prestacaoContas.CodigoGrupo),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
        actions: <Widget>[
          Visibility(
            visible: widget.prestacaoContas.Erros != null,
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.red,
              ),
              onPressed: () async {

                String erros = widget.prestacaoContas.Erros.replaceAll(";", "\n");

                AlertDialog alert = AlertDialog(
                  title: Text("Erros"),
                  content: Text(erros),
                  actions: [
                    FlatButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                      },
                    )
                  ],
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
            ),
          )
        ],
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
                absorbing: widget.prestacaoContas.ProjectUID != null ? true : false,
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
                      LoadDespesas();
                    });
                  },
                  items: dowpDownMenuItems_projeto,
                  validator: validatorProjeto,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Despesa"),
              ),
              DropdownButtonFormField<String>(
                value: widget.prestacaoContas.DespesaUID,
                icon: Icon(Icons.keyboard_arrow_down),
                isExpanded: true,
                iconSize: 24.0,
                elevation: 16,
                onChanged: (despesa){
                  setState(() {
                    Despesa d = Despesas.firstWhere((x) => x.DespesaUID == despesa, orElse: () => Despesa());
                    widget.prestacaoContas.DespesaUID = d.DespesaUID;
                  });
                },
                items: dowpDownMenuItems_despesa,
                validator: validateDespesa
              ),
              SizedBox(height: 20.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Data"),
              ),
              SizedBox(height: 10.0),

              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: validar && SelectedDate == null ? Colors.red : Colors.black12),
                  ),
                  alignment: Alignment.centerRight,
                  child:
                  Row(
                    children: <Widget>[
                      Text(
                        SelectedDate != null ?  "${SelectedDate.day}/${SelectedDate.month}/${SelectedDate.year}" : "-",
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
                    initialDate: SelectedDate?? DateTime.now(),
                    firstDate: DateTime.now().subtract(new Duration(days: 60)),
                    lastDate: DateTime(DateTime.now().year + 1),
                    locale: const Locale("pt","BR")
                  ).then((date) {
                    if (date != null){
                      setState(() {
                        SelectedDate = new DateTime(date.year, date.month, date.day);
                      });
                    }
                  });
                }
              ),
              Visibility(
                visible: (validar && SelectedDate == null),
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

              SizedBox(height: 20.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Valor"),
              ),
              TextFormField(
                  controller: ValorController,
                  keyboardType: TextInputType.number,
                  validator: validateValor,
              ),
              SizedBox(height: 20.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Descrição"),
              ),
              TextFormField(
                controller: DescricaoController,
                maxLines: 4,
                validator: validateDescricao,
              ),
              SizedBox(height: 20.0),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Anexo")
              ),
              SizedBox(height: 10.0),

              GestureDetector(
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: validar && (widget.prestacaoContas.AttachmentPath == null || widget.prestacaoContas.AttachmentPath.isEmpty) ? Colors.red : Colors.black12),
                    ),
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.camera_alt, size: 30.0,),
                      color: Colors.white.withAlpha(50),
                    )
                ),
                onTap: (){
                  showModalBottomSheet(context: context,
                      builder: (context) => ImageSourceSheet(
                        onImageSelected: (image){
                          setState(() {
                            if (image != null)
                              widget.prestacaoContas.AttachmentPath = image.path;
                            else
                              widget.prestacaoContas.AttachmentPath = null;
                          });
                          Navigator.of(context).pop();
                        },
                      )
                  );
                },
              ),
              Visibility(
                visible: (validar && (widget.prestacaoContas.AttachmentPath == null || widget.prestacaoContas.AttachmentPath.isEmpty)),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    "Selecione a imagem para anexo",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.red
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0),

              Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: widget.prestacaoContas.AttachmentPath != null ?
                      FileImage(File(widget.prestacaoContas.AttachmentPath)) :
                      AssetImage("assets/images/image.png"),
                      fit: BoxFit.cover
                  ),
                ),
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

          if(_formKey.currentState.validate() && SelectedDate != null && widget.prestacaoContas.AttachmentPath != null){
            widget.prestacaoContas.ProjectUID = ProjetoSelecionado.ProjectUID;
            widget.prestacaoContas.NomeProjeto = ProjetoSelecionado.NomeProjeto;
            Despesa d = Despesas.firstWhere((x) => x.DespesaUID == widget.prestacaoContas.DespesaUID);
            widget.prestacaoContas.NomeDespesa = d.NomeDespesa;
            widget.prestacaoContas.Data = "${SelectedDate.day}/${SelectedDate.month}/${SelectedDate.year}";
            widget.prestacaoContas.Valor = ValorController.numberValue;
            widget.prestacaoContas.Descricao = DescricaoController.text;
            widget.prestacaoContas.Erros = null;

            if (widget.prestacaoContas.PrestacaoContasUID != null){
              helperDB.updatePrestacaoContas(widget.prestacaoContas).then((prestacaoContas){
                Alert(message: 'Prestação de Contas editada com sucesso!').show();
                Navigator.pop(context);
              });
            }
            else  {
              widget.prestacaoContas.PrestacaoContasUID = Uuid().v1().toString();

              helperDB.savePrestacaoContas(widget.prestacaoContas).then((prestacaoContas){
                Alert(message: 'Prestação de Contas salva com sucesso!').show();
                Navigator.pop(context);
              });
            }
          }
        },
      ),
    );
  }
}
