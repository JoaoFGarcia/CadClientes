unit uCadCliente;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Mask,
  Vcl.DBCtrls,
  Data.DB,
  Datasnap.DBClient,
  Vcl.ComCtrls,
  System.RegularExpressions,
  System.MaskUtils,
  REST.Types,
  REST.Client,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  uValidate;

type
  TfrmCadCliente = class(TForm)
    pnlTop: TPanel;
    btnSave: TBitBtn;
    imgBtns: TImageList;
    btnCancel: TBitBtn;
    dsMain: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    dbeNome: TDBEdit;
    Label1: TLabel;
    Label3: TLabel;
    dbeCGC: TDBEdit;
    Label5: TLabel;
    dbeLogradouro: TDBEdit;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    dbeEmail: TDBEdit;
    Label8: TLabel;
    Label10: TLabel;
    dbeBairro: TDBEdit;
    Label11: TLabel;
    dbeNumero: TDBEdit;
    Label12: TLabel;
    dbeMunicipio: TDBEdit;
    Label13: TLabel;
    dbeTelefone: TDBEdit;
    Label16: TLabel;
    dbeCEP: TDBEdit;
    Label14: TLabel;
    dbeComplemento: TDBEdit;
    rstRequest: TRESTRequest;
    rstClient: TRESTClient;
    rstResponse: TRESTResponse;
    Label2: TLabel;
    dbePais: TDBEdit;
    dbeUF: TDBEdit;
    Label4: TLabel;
    dbeIdentidade: TDBEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure dbeTelefoneEnter(Sender: TObject);
    procedure cdsMainemailValidate(Sender: TField);
    procedure cdsMaintelefoneChange(Sender: TField);
    procedure btnSaveClick(Sender: TObject);
    procedure dbeCEPExit(Sender: TObject);
  private
    rRotine     : TRotine;
  public
    { Public declarations }
  end;

var
  frmCadCliente: TfrmCadCliente;

  function Execute(Rotina : TRotine; ID : String = '') : Boolean;

implementation

{$R *.dfm}

uses uMainDM;

function Execute(Rotina : TRotine; ID : String = '') : Boolean;
begin
  frmCadCliente             := TfrmCadCliente.Create(nil);
  try
    with frmCadCliente do
    begin
      rRotine := Rotina;
      if (Rotina = rtEdit) then
      begin
        mainDM.cdsMain.Edit;
        dbeCGC.ReadOnly := True;
      end else if (Rotina = rtInsert) then
      begin
        mainDM.cdsMain.Append;
      end;

      Result := ShowModal = mrOk;
    end;
  finally
    FreeAndNil(frmCadCliente);
  end;
end;

procedure TfrmCadCliente.btnCancelClick(Sender: TObject);
begin
  mainDM.cdsMain.Cancel;
  ModalResult := mrCancel;
  Self.Close;
end;

procedure TfrmCadCliente.btnSaveClick(Sender: TObject);
var
  rRegex : TRegex;
begin
  if (rRotine = rtInsert) and (IDS.IndexOf(mainDM.cdsMain.FieldByName('ID').AsString) <> -1) then
    raise Exception.Create('CPF já cadastrado!');

  if not validateCPF(mainDM.cdsMain.FieldByName('ID').AsString) then
    raise Exception.Create('CPF inválido!');

  if (Trim(mainDM.cdsMain.FieldByName('TELEFONE').AsString) <> EmptyStr) and not (validatePhone(mainDM.cdsMain.FieldByName('TELEFONE').AsString)) then
    raise Exception.Create('Telefone inválido!');

  if (Trim(mainDM.cdsMain.FieldByName('EMAIL').AsString) <> EmptyStr) and not (validateEmail(mainDM.cdsMain.FieldByName('EMAIL').AsString)) then
    raise Exception.Create('E-mail inválido!');

  IDS.Add(mainDM.cdsMain.FieldByName('ID').AsString);

  mainDM.cdsMain.Post;
  ModalResult := mrOk;
end;

procedure TfrmCadCliente.cdsMainemailValidate(Sender: TField);
var
  rRegex: TRegex;
  bRet  : Boolean;
begin
end;

procedure TfrmCadCliente.cdsMaintelefoneChange(Sender: TField);
begin
  if Length(Sender.AsString) = 10 then
    mainDM.cdsMaintelefone.EditMask := '(99) 9999-9999;0;'
  else
    mainDM.cdsMaintelefone.EditMask := '(99) #9999-9999;0;'
end;

procedure TfrmCadCliente.dbeCEPExit(Sender: TObject);
var
  rRegex  : TRegex;
  sValue  : String;
  iValue  : Integer;
  dValue  : Double;
begin
  if (Trim(mainDM.cdsMain.FieldByName('CEP').AsString) = '') or
     (Length(Trim(mainDM.cdsMain.FieldByName('CEP').AsString)) <> 8) then
    Exit;

  try
    rstRequest.Params[0].Value := dbeCEP.Text;
    rstRequest.Execute;

    rstResponse.GetSimpleValue('erro', sValue);
    if (UpperCase(sValue) = 'true') or (rstResponse.Status.ClientErrorBadRequest_400) then
    begin
      raise Exception.Create('Não foi possível obter o CEP informado!');
    end
    else
    begin
      rstResponse.JSONValue.FindValue('logradouro').TryGetValue<String>(sValue);
      mainDM.cdsMain.FieldByName('LOGRADOURO').AsString  := sValue;

      rstResponse.JSONValue.FindValue('complemento').TryGetValue<String>(sValue);
      mainDM.cdsMain.FieldByName('COMPLEMENTO').AsString := sValue;

      rstResponse.JSONValue.FindValue('bairro').TryGetValue<String>(sValue);
      mainDM.cdsMain.FieldByName('BAIRRO').AsString      := sValue;

      rstResponse.JSONValue.FindValue('localidade').TryGetValue<String>(sValue);
      mainDM.cdsMain.FieldByName('CIDADE').AsString   := sValue;

      rstResponse.JSONValue.FindValue('uf').TryGetValue<String>(sValue);
      mainDM.cdsMain.FieldByName('ESTADO').AsString := sValue;
    end;
  except

  end;
end;

procedure TfrmCadCliente.dbeTelefoneEnter(Sender: TObject);
begin
  mainDM.cdsMaintelefone.EditMask := '(99) #9999-9999;0;';
end;

end.
