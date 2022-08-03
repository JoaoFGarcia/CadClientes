unit uConfig;

interface

uses
  REST.Json,
  REST.Json.Types,
  System.Classes,
  SysUtils,
  JSON,
  System.TypInfo,
  StrUtils;

type
  TConfigEmail = class
  private
    FServidor : String;
    FPorta    : Integer;
    FUsuario  : String;
    FSenha    : String;
    FSSL      : Boolean;
    FTLS      : Boolean;
    FAssunto  : String;
  public
    property Servidor: String read FServidor write FServidor;
    property Porta   : Integer read FPorta write FPorta;
    property Usuario : String read FUsuario write FUsuario;
    property Senha   : String read FSenha write FSenha;
    property SSL     : Boolean read FSSL write FSSL;
    property TLS     : Boolean read FTLS write FTLS;
    property Assunto : String read FAssunto write FAssunto;
  end;

type
  TConfig = class(TObject)
  private
    FEmail         : TConfigEmail;
    [JSONMarshalled(False)]
    Arquivo        : String;
  published
    property Email : TConfigEmail read FEmail write FEmail;
  public
    procedure Carregar;
    procedure Salvar(Caminho : String = '');
    constructor Create(const Arquivo : String);
  end;

var
  Config : TConfig;

implementation

{ Configuracao }

procedure TConfig.Carregar;
var
  vConteudo    : TStrings;
  jObj         : TJsonObject;
label
  lInitialize;
begin
  vConteudo := TStringList.Create;
  try
    try
      if not FileExists(Arquivo) then
        goto lInitialize;

      vConteudo.LoadFromFile(Arquivo);

      if not vConteudo.Text.StartsWith('{') then vConteudo.Text := vConteudo[0];

      jObj := TJsonObject.ParseJSONValue(vConteudo.Text) as TJsonObject;
      TJson.JsonToObject(Self, jObj,  [joIndentCaseLower]);

      lInitialize:
      if not Assigned(FEmail) then
      begin
        Self.FEmail        := TConfigEmail.Create();
      end;
    finally
      if Assigned(vConteudo) then
        FreeAndNil(vConteudo);
    end;
  except
    on E: Exception
    do begin
      raise Exception.Create('Ocorreu um erro ao salvar o arquivo de configuração: ' + E.Message);
    end;
  end;
end;

constructor TConfig.Create(const Arquivo : String);
begin
  Self.Arquivo          := Arquivo;
  Carregar;
end;

procedure TConfig.Salvar(Caminho : String = '');
var
  vConteudo : TStrings;
  sLine     : String;
begin
  vConteudo := TStringList.Create;
  try
    vConteudo.Text := (StringReplace((TJson.ObjectToJsonObject(Self, [joIndentCaseLower]).ToString), '\/', '/', [rfReplaceAll]));
    vConteudo.SaveToFile(IfThen(Caminho <> '', Caminho, Arquivo));
  finally
    FreeAndNil(vConteudo);
  end;
end;

{ TManifestBalancaArquivos }

function StrDef(const AValue: string; const ADefault: string): string;
begin
  if AValue = '' then
    Result := ADefault
  else
    Result := AValue;
end;

initialization
  Config := TConfig.Create(ExtractFilePath(ParamStr(0)) + 'conf.json')

finalization
  FreeAndNil(Config);

end.


