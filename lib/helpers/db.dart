import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//TABELA USUARIO
final String UsuarioTable = "UsuarioTable";
final String UsuarioUIDColumn = "UsuarioUIDColumn";
final String ResourceUIDColumn = "ResourceUIDColumn";
final String NomeColumn = "NomeColumn";
final String WorkOfflineColumn = "WorkOfflineColumn";

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
    final path = join(databasesPath, "mvapp.db");

    return await openDatabase(path, version: 2, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $UsuarioTable($UsuarioUIDColumn TEXT, $ResourceUIDColumn TEXT, $NomeColumn TEXT, $WorkOfflineColumn TEXT)"
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
      columns: [UsuarioUIDColumn, ResourceUIDColumn, NomeColumn, WorkOfflineColumn]);
    
    if (maps.length > 0)
      return Usuario.fromMap(maps.first);
    else
      return null;
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
}

class Usuario {
  String UsuarioUID;
  String ResourceUID;
  String Nome;
  String WorkOffline;

  Usuario();

  Usuario.fromMap(Map map){
    UsuarioUID = map[UsuarioUIDColumn];
    ResourceUID = map[ResourceUIDColumn];
    Nome = map[NomeColumn];
    WorkOffline = map[WorkOfflineColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      UsuarioUIDColumn: UsuarioUID,
      ResourceUIDColumn: ResourceUID,
      NomeColumn: Nome,
      WorkOfflineColumn: WorkOffline
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
      'Data': "${Data.split("/")[2]}-${Data.split("/")[1]}-${Data.split("/")[0]}",
      'Valor': Valor,
      'Descricao': Descricao,
      'UsuarioUID': UsuarioUID,
      'LinkAnexo' : LinkAnexo
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
