import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrestacaoContasAcompanhamentoDetalhes extends StatefulWidget {

  Map prestacaoContas;

  PrestacaoContasAcompanhamentoDetalhes(this.prestacaoContas);

  @override
  _PrestacaoContasAcompanhamentoDetalhesState createState() => _PrestacaoContasAcompanhamentoDetalhesState();
}

class _PrestacaoContasAcompanhamentoDetalhesState extends State<PrestacaoContasAcompanhamentoDetalhes> {

  var currency = new NumberFormat.currency(locale: "pt_BR", symbol: "R\$");

  Widget _buildInfoRow(String label, String value){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Text(value)
        )
      ],
    );
  }

  String _getDateString(DateTime data){
    if (data == null){
      return "-";
    }
    else {
      return data.day.toString() + "/" + data.month.toString() + "/" + data.year.toString();
    }
  }

  String _getDateTimeString(DateTime data){
    if (data == null){
      return "-";
    }
    else {
      return data.day.toString() + "/" + data.month.toString() + "/" + data.year.toString() + " " + data.hour.toString() + ":" + data.minute.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PC - ${widget.prestacaoContas["GrupoCodigo"]}"),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Nome do Projeto", widget.prestacaoContas["NomeProjeto"]),
            SizedBox(height: 10.0),
            _buildInfoRow("Data da Solicitação", _getDateString(DateTime.parse(widget.prestacaoContas["DataGrupoEncerrado"]))),
            SizedBox(height: 10.0),
            _buildInfoRow("Gerente do Projeto", widget.prestacaoContas["GerenteProjeto"]),
            SizedBox(height: 10.0),
            _buildInfoRow("Data aprovação/reprovação GP", _getDateTimeString(widget.prestacaoContas["DataAprovacaoGP"].toString() != "null" ? DateTime.parse(widget.prestacaoContas["DataAprovacaoGP"]) : null)),
            SizedBox(height: 10.0),
            _buildInfoRow("Data aprovação/reprovação Financeiro", _getDateTimeString(widget.prestacaoContas["DataAprovacaoFinanceiro"].toString() != "null" ? DateTime.parse(widget.prestacaoContas["DataAprovacaoFinanceiro"]) : null)),
            SizedBox(height: 10.0),
            _buildInfoRow("Data de Recebimento do Doc Físico", _getDateTimeString(widget.prestacaoContas["DateEmailEnviado"].toString() != "null" ? DateTime.parse(widget.prestacaoContas["DateEmailEnviado"]) : null)),
            SizedBox(height: 10.0),
            _buildInfoRow("Valor Aprovado", currency.format(widget.prestacaoContas["ValorAprovado"]))
          ],
        ),
      ),
    );
  }
}
