class PrestacaoContasValidator {

  String validatorProjeto(String ProjectUID){
    if(ProjectUID == null || ProjectUID.isEmpty) return "Informe o Projeto";
    return null;
  }

  String validateDespesa(String DespesaUID){
    if(DespesaUID == null || DespesaUID.isEmpty) return "Informe a Despesaa";
    return null;
  }

  String validateData(String Data){
    if(Data == null || Data.isEmpty) return "Informe a Data";
    return null;
  }

  String validateValor(String Valor){
    if(Valor == null || Valor.isEmpty) return "Informe o Valor";
    else {

      String teste = Valor.replaceAll(".", "").replaceAll(",", ".");

      double valor = double.tryParse(teste);
      if (valor == null || valor == 0)
        return "O valor deve ser maior que 0";
    }
    return null;
  }

  String validateDescricao(String Descricao){
    if(Descricao == null || Descricao.isEmpty) return "Informe a Descrição";
    return null;
  }

  String validateAttachmentPath(String AttachmentPath){
    if(AttachmentPath == null || AttachmentPath.isEmpty) return "Selecione o Anexo";
    return null;
  }

  String validateObservacoes(String Observacoes){
    if(Observacoes == null || Observacoes.isEmpty) return "Informe a Justificativa";
    return null;
  }
}