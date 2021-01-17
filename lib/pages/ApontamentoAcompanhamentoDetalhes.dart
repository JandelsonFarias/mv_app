import 'package:flutter/material.dart';

class ApontamentoAcompanhamentoDetalhes extends StatefulWidget {

  Map apontamento;

  ApontamentoAcompanhamentoDetalhes(this.apontamento);

  @override
  _ApontamentoAcompanhamentoDetalhesState createState() => _ApontamentoAcompanhamentoDetalhesState();
}

class _ApontamentoAcompanhamentoDetalhesState extends State<ApontamentoAcompanhamentoDetalhes> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Apontamento"),
        backgroundColor: Color.fromRGBO(36, 177, 139, 1),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Nome do Projeto", widget.apontamento["ProjectName"] != null ? widget.apontamento["ProjectName"] : "-"),
            SizedBox(height: 10.0),
            _buildInfoRow("Atividade", widget.apontamento["TaskName"] != null ? widget.apontamento["TaskName"] : "-"),
            SizedBox(height: 10.0),
            _buildInfoRow("Data do Apontamento", _getDateString(DateTime.parse(widget.apontamento["NewTimeByDay"]))),
            SizedBox(height: 10.0),
            _buildInfoRow("Horas Apontadas", widget.apontamento["HoraMinuto"]),
            SizedBox(height: 10.0),
            _buildInfoRow("Status da Aprovação", widget.apontamento["StatusAprovacao"]),
            SizedBox(height: 10.0),
            _buildInfoRow("Observações do Apontamento", widget.apontamento["ObservacoesApontamento"] != null ? widget.apontamento["ObservacoesApontamento"] : ""),
            SizedBox(height: 10.0),
            _buildInfoRow("Observações da Aprovação", widget.apontamento["ObservacoesAprovacao"] != null ? widget.apontamento["ObservacoesAprovacao"] : ""),
          ],
        ),
      ),
    );
  }
}
