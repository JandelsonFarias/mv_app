class ApontamentoValidator {
  String validatorProjeto(String ProjectUID){
    if(ProjectUID == null || ProjectUID.isEmpty) return "Informe o Projeto";
    return null;
  }

  String validateObservacoes(String Observacoes){
    if(Observacoes == null || Observacoes.isEmpty) return "Informe as Observações";
    return null;
  }

  String validateHorasApontadas(String HorasApontadas){
    if(HorasApontadas == null || HorasApontadas.isEmpty)
      return "Informe as Horas trabalhadas";
    else {

      if (HorasApontadas.split(':').length != 2)
        return "Valor inválido";

      int horas = int.parse(HorasApontadas.split(':')[0]);
      int minutos = int.parse(HorasApontadas.split(':')[1]);

      if (horas == 0 && minutos < 30)
        return "O valor mínimo é de 00:30";
      if (horas > 24 || minutos > 60)
        return "O valor máximo é de 24:00";
      else if (horas == 24 && minutos > 0)
        return "O valor máximo é de 24:00";
    }

    return null;
  }

  String validateHorasRestantes(String HorasRestantes){
    if(HorasRestantes != null && HorasRestantes.isNotEmpty) {

      if (HorasRestantes.split(':').length != 2)
        return "Valor inválido";

      int horas = int.parse(HorasRestantes.split(':')[0]);
      int minutos = int.parse(HorasRestantes.split(':')[1]);

      if (horas == 0 && minutos < 30)
        return "O valor mínimo é de 00:30";
      if (horas > 24 || minutos > 60)
        return "O valor máximo é de 24:00";
      else if (horas == 24 && minutos > 0)
        return "O valor máximo é de 24:00";
    }

    return null;
  }

}