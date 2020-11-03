class AdiantamentoValidator {
  String validatorProjeto(String ProjectUID){
    if(ProjectUID == null || ProjectUID.isEmpty) return "Informe o Projeto";
    return null;
  }

  String validateValorApontado(String ValorApontado){
    if(ValorApontado == null || ValorApontado.isEmpty) return "Informe o Valor Solicitado";
    else {

      String teste = ValorApontado.replaceAll(".", "").replaceAll(",", ".");

      double valor = double.tryParse(teste);
      if (valor == null || valor == 0)
        return "O valor solicitado deve ser maior que 0";
    }
    return null;
  }

  String validateJustificativa(String Justificativa){
    if(Justificativa == null || Justificativa.isEmpty) return "Informe a Justificativa";
    return null;
  }

}