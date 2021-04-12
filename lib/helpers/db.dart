import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//TABELA USUARIO
final String UsuarioTable = "UsuarioTable";
final String UsuarioUIDColumn = "UsuarioUIDColumn";
final String ResourceUIDColumn = "ResourceUIDColumn";
final String NomeColumn = "NomeColumn";
final String WorkOfflineColumn = "WorkOfflineColumn";
final String IsGerenteColumn = "IsGerenteColumn";
final String AtualizadoEmColumn = "AtualizadoEmColumn";

//TABELA PROJETO
final String ProjetoTable = "ProjetoTable";
final String ProjectUIDColumn = "ProjectUIDColumn";
final String NomeProjetoColumn = "NomeProjetoColumn";

//TABELA DESPESA
final String DespesaTable = "DespesaTable";
final String DespesaUIDColumn = "DespesaUIDColumn";
final String NomeDespesaColumn = "NomeDespesaColumn";

//TABELA PRESTACAOCONTAS
final String PrestacaoContasTable = "PrestacaoContasTable";
final String PrestacaoContasUIDColumn = "PrestacaoContasUIDColumn";
final String CodigoGrupoColumn = "CodigoGrupoColumn";
final String DataColumn = "DataColumn";
final String ValorColumn = "ValorColumn";
final String DescricaoColumn = "DescricaoColumn";
final String AttachmentPathColumn = "AttachmentPathColumn";
final String LinkAnexoColumn = "LinkAnexoColumn";
final String ErrosColumn = "ErrosColumn";

//TABELA ADIANTAMENTO
final String AdiantamentoTable = "AdiantamentoTable";
final String AdiantamentoUIDColumn = "AdiantamentoUIDColumn";
final String AdiantamentoCodigoColumn= "AdiantamentoCodigoColumn";
final String DataInicioColumn= "DataInicioColumn";
final String DataFimColumn= "DataFimColumn";
final String ValorApontadoColumn= "ValorApontadoColumn";
final String JustificativaColumn= "JustificativaColumn";

//TABELA APONTAMENTO TASK
final String ApontamentoTaskTable = "ApontamentoTaskTable";
final String TaskUIDColumn = "TaskUIDColumn";
final String TaskNameColumn = "TaskNameColumn";

//TABELA APONTAMENTO ASSIGNMENT
final String ApontamentoAssignmentTable = "ApontamentoAssignmentTable";
final String AssignmentUIDColumn = "AssignmentUIDColumn";
final String TrabalhoPrevistoColumn = "TrabalhoPrevistoColumn";
final String strTrabalhoPrevistoColumn = "strTrabalhoPrevistoColumn";
final String TimeByDayColumn = "TimeByDayColumn";

//TABELA APONTAMENTO
final String ApontamentoTable = "ApontamentoTable";
final String ApontamentoUIDColumn = "ApontamentoUIDColumn";
final String NewTimeByDayColumn = "NewTimeByDayColumn";
final String HorasApontadasColumn = "HorasApontadasColumn";
final String HorasRestantesColumn = "HorasRestantesColumn";
final String ObservacoesColumn = "ObservacoesColumn";

class HelperDB {
  static final HelperDB _instance = HelperDB.internal();

  factory HelperDB() => _instance;

  HelperDB.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "mvtapp.db");

    return await openDatabase(path, version: 3, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $UsuarioTable($UsuarioUIDColumn TEXT, $ResourceUIDColumn TEXT, $NomeColumn TEXT, $WorkOfflineColumn TEXT, $IsGerenteColumn TEXT, $AtualizadoEmColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $ProjetoTable($ProjectUIDColumn TEXT, $NomeProjetoColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $DespesaTable($DespesaUIDColumn TEXT, $ProjectUIDColumn TEXT, $NomeDespesaColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $PrestacaoContasTable($PrestacaoContasUIDColumn TEXT, $DespesaUIDColumn TEXT, $NomeDespesaColumn TEXT, $ProjectUIDColumn TEXT, $NomeProjetoColumn TEXT, $CodigoGrupoColumn TEXT, $DataColumn TEXT, $ValorColumn TEXT, $DescricaoColumn TEXT, $AttachmentPathColumn TEXT, $UsuarioUIDColumn TEXT, $LinkAnexoColumn TEXT, $ErrosColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $AdiantamentoTable($AdiantamentoUIDColumn TEXT, $ProjectUIDColumn TEXT, $NomeProjetoColumn TEXT, $AdiantamentoCodigoColumn TEXT, $DataInicioColumn TEXT, $DataFimColumn TEXT, $ValorApontadoColumn TEXT, $JustificativaColumn TEXT, $UsuarioUIDColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $ApontamentoTaskTable($TaskUIDColumn TEXT, $ProjectUIDColumn TEXT, $TaskNameColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $ApontamentoAssignmentTable($AssignmentUIDColumn TEXT, $TaskUIDColumn TEXT, $TrabalhoPrevistoColumn TEXT, $strTrabalhoPrevistoColumn TEXT, $TimeByDayColumn TEXT)"
      );

      await db.execute(
          "CREATE TABLE $ApontamentoTable($ApontamentoUIDColumn TEXT, $ProjectUIDColumn TEXT, $NomeProjetoColumn TEXT, $TaskUIDColumn TEXT, $TaskNameColumn TEXT, $AssignmentUIDColumn TEXT, $ResourceUIDColumn TEXT,  $TimeByDayColumn TEXT, $NewTimeByDayColumn TEXT, $HorasApontadasColumn TEXT, $HorasRestantesColumn TEXT, $ObservacoesColumn TEXT)"
      );

    });
  }

  //Usuario
  Future<Usuario> saveUsuario(Usuario usuario) async {
    Database mvappDB = await db;
    await mvappDB.insert(UsuarioTable, usuario.toMap());
    return usuario;
  }

  Future<Usuario> getUsuarioLogado() async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(UsuarioTable,
      columns: [UsuarioUIDColumn, ResourceUIDColumn, NomeColumn, WorkOfflineColumn, IsGerenteColumn, AtualizadoEmColumn]);
    
    if (maps.length > 0)
      return Usuario.fromMap(maps.first);
    else
      return null;
  }

  Future<int> logOut() async {
    Database mvappDB = await db;

    int retorno = 0;

    retorno += await mvappDB.delete(UsuarioTable);
    retorno += await mvappDB.delete(ProjetoTable);
    retorno += await mvappDB.delete(DespesaTable);
    retorno += await mvappDB.delete(PrestacaoContasTable);
    retorno += await mvappDB.delete(AdiantamentoTable);
    retorno += await mvappDB.delete(ApontamentoTaskTable);
    retorno += await mvappDB.delete(ApontamentoAssignmentTable);
    retorno += await mvappDB.delete(ApontamentoTable);

    return retorno;
  }

  Future<int> deleteUsuarioLogado() async {
    Database mvappDB = await db;
    return await mvappDB.delete(UsuarioTable);
  }

  //Projeto
  Future<Projeto> saveProjetoSelecionado(Projeto projeto) async {
    Database mvappDB = await db;
    await mvappDB.insert(ProjetoTable, projeto.toMap());
    return projeto;
  }

  Future<Projeto> getProjetoSelecionado() async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(ProjetoTable,
        columns: [ProjectUIDColumn, NomeProjetoColumn]);

    if (maps.length > 0)
      return Projeto.fromMap(maps.first);
    else
      return null;
  }

  Future<int> deleteProjetoSelecionado() async {
    Database mvappDB = await db;
    return await mvappDB.delete(ProjetoTable);
  }

  //Despesa
  Future<Despesa> saveDespesa(Despesa despesa) async {
    Database mvappDB = await db;
    await mvappDB.insert(DespesaTable, despesa.toMap());
    return despesa;
  }

  Future<List<Despesa>> getDespesaByProjectUID(String ProjectUID) async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(DespesaTable,
        columns: [DespesaUIDColumn, ProjectUIDColumn, NomeDespesaColumn],
        where: "$ProjectUIDColumn = ?",
        whereArgs: [ProjectUID]);

    if (maps.length > 0)
    {
      List<Despesa> despesas = [];

      for (Map map in maps){
        Despesa despesa = Despesa.fromMap(map);
        despesas.add(despesa);
      }

      return despesas;
    }
    else
      return [];
  }

  Future<int> deleteDespesas() async {
    Database mvappDB = await db;
    return await mvappDB.delete(DespesaTable);
  }

  //PrestacaoContas
  Future<PrestacaoContas> savePrestacaoContas(PrestacaoContas prestacaoContas) async {
    Database mvappDB = await db;
    await mvappDB.insert(PrestacaoContasTable, prestacaoContas.toMap());
    return prestacaoContas;
  }

  Future<int> updatePrestacaoContas(PrestacaoContas prestacaoContas) async {
    Database mvappDB = await db;
    return await mvappDB.update(PrestacaoContasTable,
      prestacaoContas.toMap(),
      where: "$PrestacaoContasUIDColumn = ?",
      whereArgs: [prestacaoContas.PrestacaoContasUID]);
  }

  Future<List<PrestacaoContas>> getAllPrestacaoContas() async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(PrestacaoContasTable,
        columns: [PrestacaoContasUIDColumn, DespesaUIDColumn, NomeDespesaColumn, ProjectUIDColumn, NomeProjetoColumn, CodigoGrupoColumn, DataColumn, ValorColumn, DescricaoColumn, AttachmentPathColumn, UsuarioUIDColumn, LinkAnexoColumn, ErrosColumn]);

    List<PrestacaoContas> prestacaoContas = [];

    if (maps.length > 0){
      for (Map map in maps){
        prestacaoContas.add(PrestacaoContas.fromMap(map));
      }
    }

    return prestacaoContas;
  }

  Future<List<PrestacaoContas>> getPrestacaoContasByCodigoGrupo(String CodigoGrupo) async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(PrestacaoContasTable,
        columns: [PrestacaoContasUIDColumn, DespesaUIDColumn, NomeDespesaColumn, ProjectUIDColumn, NomeProjetoColumn, CodigoGrupoColumn, DataColumn, ValorColumn, DescricaoColumn, AttachmentPathColumn, UsuarioUIDColumn, LinkAnexoColumn, ErrosColumn],
        where: "$CodigoGrupoColumn = ?",
        whereArgs: [CodigoGrupo]);

    if (maps.length > 0)
    {
      List<PrestacaoContas> prestacaoContas = [];

      for (Map map in maps){
        PrestacaoContas p = PrestacaoContas.fromMap(map);
        prestacaoContas.add(p);
      }

      return prestacaoContas;
    }
    else
      return [];
  }

  Future<int> deletePrestacaoContas() async {
    Database mvappDB = await db;
    return await mvappDB.delete(PrestacaoContasTable);
  }

  Future<int> deletePrestacaoContasByUID(String PrestacaoContasUID) async {
    Database mvappDB = await db;
    return await mvappDB.delete(
      PrestacaoContasTable,
      where: "$PrestacaoContasUIDColumn = ?",
      whereArgs: [PrestacaoContasUID]
    );
  }

  Future<int> deletePrestacaoContasByCodigoGrupo(String CodigoGrupo) async {
    Database mvappDB = await db;
    return await mvappDB.delete(
        PrestacaoContasTable,
        where: "$CodigoGrupoColumn = ?",
        whereArgs: [CodigoGrupo]
    );
  }

  //Adiantamento
  Future<List<Adiantamento>> getAllAdiantamentos() async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(AdiantamentoTable,
        columns: [AdiantamentoUIDColumn, ProjectUIDColumn, NomeProjetoColumn, AdiantamentoCodigoColumn, DataInicioColumn, DataFimColumn, ValorApontadoColumn, JustificativaColumn, UsuarioUIDColumn]);

    List<Adiantamento> adiantamentos = [];

    if (maps.length > 0){
      for (Map map in maps){
        adiantamentos.add(Adiantamento.fromMap(map));
      }
    }

    return adiantamentos;
  }

  Future<Adiantamento> saveAdiantamento(Adiantamento adiantamento) async {
    Database mvappDB = await db;
    await mvappDB.insert(AdiantamentoTable, adiantamento.toMap());
    return adiantamento;
  }

  Future<int> updateAdiantamento(Adiantamento adiantamento) async {
    Database mvappDB = await db;
    return await mvappDB.update(AdiantamentoTable,
        adiantamento.toMap(),
        where: "$AdiantamentoUIDColumn = ?",
        whereArgs: [adiantamento.AdiantamentoUID]);
  }

  Future<int> deleteAdiantamentos() async {
    Database mvappDB = await db;
    return await mvappDB.delete(AdiantamentoTable);
  }

  Future<int> deleteAdiantamentoByUID(String AdiantamentoUID) async {
    Database mvappDB = await db;
    return await mvappDB.delete(AdiantamentoTable, where: "$AdiantamentoUIDColumn = ?", whereArgs: [AdiantamentoUID]);
  }

  //APONTAMENTO
  Future<ApontamentoTask> saveApontamentoTask(ApontamentoTask apontamentoTask) async {
    Database mvappDB = await db;
    await mvappDB.insert(ApontamentoTaskTable, apontamentoTask.toMap());
    return apontamentoTask;
  }

  Future<ApontamentoAssignment> saveApontamentoAssignment(ApontamentoAssignment apontamentoAssignment) async {
    Database mvappDB = await db;
    await mvappDB.insert(ApontamentoAssignmentTable, apontamentoAssignment.toMap());
    return apontamentoAssignment;
  }

  Future<List<ApontamentoTask>> getAllApontamentoTask() async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(ApontamentoTaskTable,
        columns: [TaskUIDColumn, ProjectUIDColumn, TaskNameColumn]);

    List<ApontamentoTask> apontamentos_task = [];

    if (maps.length > 0){
      for (Map map in maps){
        ApontamentoTask apontamentoTask = ApontamentoTask.fromMap(map);
        apontamentoTask.Assignments = await getApontamentoAssignmentsByTaskUID(apontamentoTask.TaskUID);
        apontamentos_task.add(apontamentoTask);
      }
    }

    return apontamentos_task;
  }

  Future<List<ApontamentoAssignment>> getApontamentoAssignmentsByTaskUID(String TaskUID) async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(ApontamentoAssignmentTable,
      columns: [AssignmentUIDColumn, TaskUIDColumn, TrabalhoPrevistoColumn, strTrabalhoPrevistoColumn, TimeByDayColumn],
      where: "$TaskUIDColumn = ?",
      whereArgs: [TaskUID]);

    List<ApontamentoAssignment> apontamentos_assignments = [];

    if (maps.length > 0){
      for (Map map in maps){
        apontamentos_assignments.add(ApontamentoAssignment.fromMap(map));
      }
    }

    return apontamentos_assignments;
  }

  Future<Apontamento> saveApontamento(Apontamento apontamento) async {
    Database mvappDB = await db;
    await mvappDB.insert(ApontamentoTable, apontamento.toMap());
    return apontamento;
  }

  Future<int> updateApontamento(Apontamento apontamento) async {
    Database mvappDB = await db;
    return await mvappDB.update(ApontamentoTable,
        apontamento.toMap(),
        where: "$ApontamentoUIDColumn = ?",
        whereArgs: [apontamento.ApontamentoUID]);
  }

  Future<List<Apontamento>> getAllApontamentos() async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(ApontamentoTable,
        columns: [ApontamentoUIDColumn, ProjectUIDColumn, NomeProjetoColumn, TaskUIDColumn, TaskNameColumn, AssignmentUIDColumn, ResourceUIDColumn,  TimeByDayColumn, NewTimeByDayColumn, HorasApontadasColumn, HorasRestantesColumn, ObservacoesColumn]
    );

    List<Apontamento> apontamentos = [];

    if (maps.length > 0){
      for (Map map in maps){
        apontamentos.add(Apontamento.fromMap(map));
      }
    }

    return apontamentos;
  }

  Future<List<Apontamento>> getApontamentosByProjectUID(String ProjectUID) async {
    Database mvappDB = await db;
    List<Map> maps = await mvappDB.query(
      ApontamentoTable,
      columns: [ApontamentoUIDColumn, ProjectUIDColumn, NomeProjetoColumn, TaskUIDColumn, TaskNameColumn, AssignmentUIDColumn, ResourceUIDColumn,  TimeByDayColumn, NewTimeByDayColumn, HorasApontadasColumn, HorasRestantesColumn, ObservacoesColumn],
      where: "$ProjectUIDColumn = ?",
      whereArgs: [ProjectUID]
    );

    List<Apontamento> apontamentos = [];

    if (maps.length > 0){
      for (Map map in maps){
        apontamentos.add(Apontamento.fromMap(map));
      }
    }

    return apontamentos;
  }

  Future<int> deleteApontamentoByUID(String ApontamentoUID) async {
    Database mvappDB = await db;
    return await mvappDB.delete(ApontamentoTable, where: "$ApontamentoUIDColumn = ?", whereArgs: [ApontamentoUID]);
  }

  Future<int> deleteApontamentos() async {
    Database mvappDB = await db;
    return await mvappDB.delete(ApontamentoTable);
  }

  Future<int> deleteApontamentoTask() async {
    Database mvappDB = await db;
    return await mvappDB.delete(ApontamentoTaskTable);
  }

  Future<int> deleteApontamentoAssignment() async {
    Database mvappDB = await db;
    return await mvappDB.delete(ApontamentoAssignmentTable);
  }

}

class Usuario {
  String UsuarioUID;
  String ResourceUID;
  String Nome;
  String WorkOffline;
  bool IsGerente;
  String AtualizadoEm;

  Usuario();

  Usuario.fromMap(Map map){
    UsuarioUID = map[UsuarioUIDColumn];
    ResourceUID = map[ResourceUIDColumn];
    Nome = map[NomeColumn];
    WorkOffline = map[WorkOfflineColumn];
    IsGerente = map[IsGerenteColumn] == "1" ? true : false;
    AtualizadoEm = map[AtualizadoEmColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      UsuarioUIDColumn: UsuarioUID,
      ResourceUIDColumn: ResourceUID,
      NomeColumn: Nome,
      WorkOfflineColumn: WorkOffline,
      IsGerenteColumn: IsGerente,
      AtualizadoEmColumn: AtualizadoEm
    };
    return map;
  }
}

class Projeto {
  String ProjectUID;
  String NomeProjeto;

  Projeto();

  Projeto.fromMap(Map map){
    ProjectUID = map[ProjectUIDColumn];
    NomeProjeto = map[NomeProjetoColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      ProjectUIDColumn: ProjectUID,
      NomeProjetoColumn: NomeProjeto
    };
    return map;
  }
}

class Despesa {
  String DespesaUID;
  String ProjectUID;
  String NomeDespesa;

  Despesa();

  Despesa.fromMap(Map map){
    DespesaUID = map[DespesaUIDColumn];
    ProjectUID = map[ProjectUIDColumn];
    NomeDespesa = map[NomeDespesaColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      DespesaUIDColumn: DespesaUID,
      ProjectUIDColumn: ProjectUID,
      NomeDespesaColumn: NomeDespesa
    };
    return map;
  }
}

class PrestacaoContas {
  String PrestacaoContasUID;
  String DespesaUID;
  String NomeDespesa;
  String ProjectUID;
  String NomeProjeto;
  String CodigoGrupo;
  String Data;
  double Valor;
  String Descricao;
  String AttachmentPath;
  String UsuarioUID;
  String LinkAnexo;
  String Erros;
  String JustificativaGP;

  PrestacaoContas();

  PrestacaoContas.fromMap(Map map){
    PrestacaoContasUID = map[PrestacaoContasUIDColumn];
    DespesaUID = map[DespesaUIDColumn];
    NomeDespesa = map[NomeDespesaColumn];
    ProjectUID = map[ProjectUIDColumn];
    NomeProjeto = map[NomeProjetoColumn];
    CodigoGrupo = map[CodigoGrupoColumn];
    Data = map[DataColumn];
    Valor = double.parse(map[ValorColumn]);
    Descricao = map[DescricaoColumn];
    AttachmentPath = map[AttachmentPathColumn];
    UsuarioUID = map[UsuarioUIDColumn];
    LinkAnexo = map[LinkAnexoColumn];
    Erros = map[ErrosColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      PrestacaoContasUIDColumn: PrestacaoContasUID,
      DespesaUIDColumn: DespesaUID,
      NomeDespesaColumn: NomeDespesa,
      ProjectUIDColumn: ProjectUID,
      NomeProjetoColumn: NomeProjeto,
      CodigoGrupoColumn: CodigoGrupo,
      DataColumn: Data,
      ValorColumn: Valor,
      DescricaoColumn: Descricao,
      AttachmentPathColumn: AttachmentPath,
      UsuarioUIDColumn: UsuarioUID,
      LinkAnexoColumn: LinkAnexo,
      ErrosColumn: Erros
    };
    return map;
  }

  PrestacaoContas.fromJson(Map<String, dynamic> json)
      : PrestacaoContasUID = json['PrestacaoContasUID'],
       DespesaUID = json['DespesaUID'],
       ProjectUID = json['ProjectUID'],
       CodigoGrupo = json['CodigoGrupo'],
       Data = json['Data'],
       Valor = json['Valor'],
       Descricao = json['Descricao'],
       UsuarioUID = json['UsuarioUID'],
      LinkAnexo = json['LinkAnexo']
  ;

  Map<String, dynamic> toJson() {
    return {
      'PrestacaoContasUID': PrestacaoContasUID,
      'DespesaUID': DespesaUID,
      'ProjectUID': ProjectUID,
      'CodigoGrupo': CodigoGrupo,
      'Data': Data != null ? "${Data.split("/")[2]}-${Data.split("/")[1]}-${Data.split("/")[0]}" : "",
      'Valor': Valor,
      'Descricao': Descricao,
      'UsuarioUID': UsuarioUID,
      'LinkAnexo': LinkAnexo,
      'JustificativaGP': JustificativaGP
    };
  }
}

class PrestacaoContasGrupoPost {
  List<PrestacaoContas> _PrestacaoContas;

  PrestacaoContasGrupoPost(this._PrestacaoContas);

  PrestacaoContasGrupoPost.fromJson(Map<String, dynamic> json)
      : _PrestacaoContas = json['_PrestacaoContas'];

  Map<String, dynamic> toJson() {
    return {
      '_PrestacaoContas': _PrestacaoContas
    };
  }
}

class Adiantamento {
  String AdiantamentoUID;
  String ProjectUID;
  String NomeProjeto;
  String AdiantamentoCodigo;
  String DataInicio;
  String DataFim;
  double ValorApontado;
  String Justificativa;
  String UsuarioUID;

  Adiantamento();

  Adiantamento.fromMap(Map map){
    AdiantamentoUID = map[AdiantamentoUIDColumn];
    ProjectUID = map[ProjectUIDColumn];
    NomeProjeto = map[NomeProjetoColumn];
    AdiantamentoCodigo = map[AdiantamentoCodigoColumn];
    DataInicio = map[DataInicioColumn];
    DataFim = map[DataFimColumn];
    ValorApontado = double.parse(map[ValorApontadoColumn]);
    Justificativa = map[JustificativaColumn];
    UsuarioUID = map[UsuarioUIDColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      AdiantamentoUIDColumn: AdiantamentoUID,
      ProjectUIDColumn: ProjectUID,
      NomeProjetoColumn: NomeProjeto,
      AdiantamentoCodigoColumn: AdiantamentoCodigo,
      DataInicioColumn: DataInicio,
      DataFimColumn: DataFim,
      ValorApontadoColumn: ValorApontado,
      JustificativaColumn: Justificativa,
      UsuarioUIDColumn: UsuarioUID
    };
    return map;
  }

  Adiantamento.fromJson(Map<String, dynamic> json)
      : AdiantamentoUID = json['AdiantamentoUID'],
        ProjectUID = json['ProjectUID'],
        AdiantamentoCodigo = json['AdiantamentoCodigo'],
        DataInicio = json['DataInicio'],
        DataFim = json['DataFim'],
        ValorApontado = json['ValorApontado'],
        Justificativa = json['Justificativa'],
        UsuarioUID = json['UsuarioUID']
  ;

  Map<String, dynamic> toJson() {
    return {
      'AdiantamentoUID': AdiantamentoUID,
      'ProjectUID': ProjectUID,
      'AdiantamentoCodigo': AdiantamentoCodigo,
      'DataInicio': "${DataInicio.split("/")[2]}-${DataInicio.split("/")[1]}-${DataInicio.split("/")[0]}",
      'DataFim': "${DataFim.split("/")[2]}-${DataFim.split("/")[1]}-${DataFim.split("/")[0]}",
      'ValorApontado': ValorApontado,
      'Justificativa': Justificativa,
      'UsuarioUID': UsuarioUID
    };
  }
}

class ApontamentoTask {
  String ProjectUID;
  String TaskUID;
  String TaskName;
  List<ApontamentoAssignment> Assignments;

  ApontamentoTask();

  ApontamentoTask.fromMap(Map map){
    TaskUID = map[TaskUIDColumn];
    ProjectUID = map[ProjectUIDColumn];
    TaskName = map[TaskNameColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      TaskUIDColumn: TaskUID,
      ProjectUIDColumn: ProjectUID,
      TaskNameColumn: TaskName
    };
    return map;
  }
}

class ApontamentoAssignment {
  String AssignmentUID;
  String TaskUID;
  double TrabalhoPrevisto;
  String strTrabalhoPrevisto;
  String TimeByDay;

  ApontamentoAssignment();

  ApontamentoAssignment.fromMap(Map map){
    TaskUID = map[TaskUIDColumn];
    AssignmentUID = map[AssignmentUIDColumn];
    TrabalhoPrevisto = double.parse(map[TrabalhoPrevistoColumn]);
    strTrabalhoPrevisto = map[strTrabalhoPrevistoColumn];
    TimeByDay = map[TimeByDayColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      TaskUIDColumn: TaskUID,
      AssignmentUIDColumn: AssignmentUID,
      TrabalhoPrevistoColumn: TrabalhoPrevisto,
      strTrabalhoPrevistoColumn: strTrabalhoPrevisto,
      TimeByDayColumn: TimeByDay
    };
    return map;
  }
}

class Apontamento {
  String ApontamentoUID;
  String ProjectUID;
  String NomeProjeto;
  String TaskUID;
  String TaskName;
  String AssignmentUID;
  String ResourceUID;
  String TimeByDay;
  String NewTimeByDay;
  String HorasApontadas;
  String HorasRestantes;
  String Observacoes;

  Apontamento();

  Apontamento.fromMap(Map map){
    ApontamentoUID = map[ApontamentoUIDColumn];
    ProjectUID = map[ProjectUIDColumn];
    NomeProjeto = map[NomeProjetoColumn];
    TaskUID = map[TaskUIDColumn];
    TaskName = map[TaskNameColumn];
    AssignmentUID = map[AssignmentUIDColumn];
    ResourceUID = map[ResourceUIDColumn];
    TimeByDay = map[TimeByDayColumn];
    NewTimeByDay = map[NewTimeByDayColumn];
    HorasApontadas = map[HorasApontadasColumn];
    HorasRestantes = map[HorasRestantesColumn];
    Observacoes = map[ObservacoesColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      ApontamentoUIDColumn: ApontamentoUID,
      ProjectUIDColumn: ProjectUID,
      NomeProjetoColumn: NomeProjeto,
      TaskUIDColumn: TaskUID,
      TaskNameColumn: TaskName,
      AssignmentUIDColumn: AssignmentUID,
      ResourceUIDColumn: ResourceUID,
      TimeByDayColumn: TimeByDay,
      NewTimeByDayColumn: NewTimeByDay,
      HorasApontadasColumn: HorasApontadas,
      HorasRestantesColumn: HorasRestantes,
      ObservacoesColumn: Observacoes
    };
    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'ProjectUID': ProjectUID,
      'TaskUID': TaskUID,
      'AssignmentUID': AssignmentUID,
      'ResourceUID': ResourceUID,
      'TimeByDay': TimeByDay,
      'NewTimeByDay': "${NewTimeByDay.split("/")[2]}-${NewTimeByDay.split("/")[1]}-${NewTimeByDay.split("/")[0]}",
      'HorasApontadas': HorasApontadas,
      'HorasRestantes': HorasRestantes,
      'Observacoes': Observacoes
    };
  }
}

class PrestacaoContasAprovacaoPOST {
  String PrestacaoConta_GrupoUID;
  String StatusAprovacao;
  String JustificativaAprovacao;
  List<PrestacaoContas> Pcs;

  Map<String, dynamic> toJson() {
    return {
      'PrestacaoConta_GrupoUID': PrestacaoConta_GrupoUID,
      'StatusAprovacao': StatusAprovacao,
      'JustificativaAprovacao': JustificativaAprovacao,
      'Pcs' : Pcs
    };
  }
}

class AdiantamentoAprovacaoPOST {
  String AdiantamentoUID;
  String StatusAprovacao;
  String Justificativa;

  Map<String, dynamic> toJson() {
    return {
      'AdiantamentoUID': AdiantamentoUID,
      'StatusAprovacao': StatusAprovacao,
      'Justificativa': Justificativa,
    };
  }
}

class ApontamentoAprovacaoPOST {
  String TaskUID;
  String ProjectUID;
  String ProjectName;
  String TaskName;
  List<ApontamentoAssignmentAprovacaoPOST> Assignments;

  Map<String, dynamic> toJson() {
    return {
      'TaskUID': TaskUID,
      'ProjectUID': ProjectUID,
      'ProjectName': ProjectName,
      'TaskName': TaskName,
      'Assignments': Assignments,
    };
  }
}

class ApontamentoAssignmentAprovacaoPOST {
  String AssignmentUID;
  String TimeByDay;
  String NewTimeByDay;
  String StatusAprovacao;
  String ObservacoesAprovacao;
  String ResourceUID;
  String ResourceName;

  Map<String, dynamic> toJson() {
    return {
      'AssignmentUID': AssignmentUID,
      'TimeByDay': TimeByDay,
      'NewTimeByDay': NewTimeByDay,
      'StatusAprovacao': StatusAprovacao,
      'ObservacoesAprovacao': ObservacoesAprovacao,
      'ResourceUID': ResourceUID,
      'ResourceName': ResourceName,
    };
  }
}







