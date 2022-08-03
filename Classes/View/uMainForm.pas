unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.BaseImageCollection, Vcl.ImageCollection, System.ImageList, Vcl.ImgList,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Tabs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Datasnap.DBClient,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  uValidate, Vcl.Menus, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase,
  IdSMTP,
  IdSSLOpenSSL,
  IdMessage,
  IdText,
  IdAttachmentFile,
  XMLDoc,
  XMLIntf,
  MaskUtils;

type
  TformMain = class(TForm)
    pnlTop: TPanel;
    btnEdit: TBitBtn;
    imgBtns: TImageList;
    btnInsert: TBitBtn;
    btnDelete: TBitBtn;
    btnClose: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    pnlSearch: TPanel;
    btnSearch: TBitBtn;
    cboFilterType: TComboBox;
    edtSearchValue: TEdit;
    dsMain: TDataSource;
    Panel1: TPanel;
    dbgMain: TDBGrid;
    btnDefinitions: TBitBtn;
    btnMail: TBitBtn;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dsMainStateChange(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure edtSearchValueKeyPress(Sender: TObject; var Key: Char);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnDefinitionsClick(Sender: TObject);
    procedure btnMailClick(Sender: TObject);
  private
    procedure SetButtons;
    procedure Maintenance(Rotina: TRotine);
    procedure LoadData;
    procedure GeraXML;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

uses uCadCliente, uMainDM, uConfiguracao, uConfig;

procedure TformMain.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TformMain.btnDefinitionsClick(Sender: TObject);
begin
  frmConfiguracao := TfrmConfiguracao.Create(nil);
  try
    frmConfiguracao.ShowModal;
  finally
    FreeAndNil(frmConfiguracao);
  end;
end;

procedure TformMain.btnDeleteClick(Sender: TObject);
begin
  IDs.Delete(IDs.IndexOf(MainDM.cdsMain.FieldByName('ID').AsString));
  MainDM.cdsMain.Delete;
end;

procedure TformMain.btnEditClick(Sender: TObject);
begin
  Maintenance(rtEdit);
end;

procedure TformMain.btnInsertClick(Sender: TObject);
begin
  Maintenance(rtInsert);
end;

//<summary>Gera arquivo XML somente com o registro selecionado no GRID</summary>
procedure TformMain.GeraXML();
var
  i         : integer;
  xml       : TXMLDocument;
  reg,
  campo     : IXMLNode;
begin
  xml := TXMLDocument.Create(nil);
  try
    xml.Active := True;
    xml.DocumentElement := xml.CreateElement('DADOS','');
    mainDM.CdsMain.First;

    reg := xml.DocumentElement.AddChild('CLIENTE');
    for i := 0 to mainDM.CdsMain.Fields.Count - 1 do
    begin
      campo := reg.AddChild(
        mainDM.CdsMain.Fields[i].DisplayLabel);
      campo.Text := mainDM.CdsMain.Fields[i].DisplayText;
    end;
    xml.SaveToFile('dadoscliente.xml');
  finally
    xml.free;
  end;
end;

procedure TformMain.btnMailClick(Sender: TObject);
var
  IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
  IdSMTP               : TIdSMTP;
  IdMessage            : TIdMessage;
  IdText               : TIdText;
  sAnexo               : String;
  sBody                : String;
begin
  if Trim(mainDM.cdsMain.FieldByName('EMAIL').AsString) = EmptyStr then
  begin
    raise Exception.Create('O cliente selecionado não possui um e-mail válido cadastrado!');
  end;

  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  IdSMTP               := TIdSMTP.Create(Self);
  IdMessage            := TIdMessage.Create(Self);
  try
    if (Config.Email.SSL) or (Config.Email.TLS ) then
    begin
      IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
      IdSSLIOHandlerSocket.SSLOptions.Mode   := sslmClient;
      IdSMTP.IOHandler                       := IdSSLIOHandlerSocket;
    end;

    if Config.Email.TLS then
      IdSMTP.UseTLS  := utUseImplicitTLS;
    IdSMTP.AuthType  := satDefault;
    IdSMTP.Port      := Config.Email.Porta;
    IdSMTP.Host      := Config.Email.Servidor;
    IdSMTP.Username  := Config.Email.Usuario;
    IdSMTP.Password  := Config.Email.Senha;

    IdMessage.From.Address           := Config.Email.Usuario;
    IdMessage.From.Name              := 'Lorem Ipsum Sistemas';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    IdMessage.Recipients.Add.Text    := mainDM.CdsMain.FieldByName('EMAIL').AsString;
    IdMessage.Subject                := Config.Email.Assunto;
    IdMessage.Encoding               := meMIME;

    IdText := TIdText.Create(IdMessage.MessageParts);
    sBody := '<!DOCTYPE html><html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office"> <head> <meta charset="utf-8"> <meta name="viewport" content="width=device-width,initial-scale=1">' +
             '<meta name="x-apple-disable-message-reformatting"> <title></title><!--[if mso]> <style>table{border-collapse:collapse;border-spacing:0;border:none;margin:0;}div, td{padding:0;}div{margin:0 !important;}</style> <noscript>' +
             '<xml> <o:OfficeDocumentSettings> <o:PixelsPerInch>96</o:PixelsPerInch> </o:OfficeDocumentSettings> </xml> </noscript><![endif]--> <style>table, td, div, h1, p{font-family: Arial, sans-serif;}@media screen and ' +
             '(max-width: 530px){.unsub{display: block; padding: 8px; margin-top: 14px; border-radius: 6px; background-color: #555555; text-decoration: none !important; font-weight: bold;}.col-lge{max-width: 100% !important;}}'+
             '@media screen and (min-width: 531px){.col-sml{max-width: 27% !important;}.col-lge{max-width: 73% !important;}}</style> </head> <body style="margin:0;padding:0;word-spacing:normal;background-color:#FFA500;"> '+
             '<div role="article" aria-roledescription="email" lang="en" style="text-size-adjust:100%;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;background-color:#FFA500;"> <table role="presentation" '+
             'style="width:100%;border:none;border-spacing:0;"> <tr> <td align="center" style="padding:0;"><!--[if mso]> <table role="presentation" align="center" style="width:600px;"> <tr> <td><![endif]--> '+
             '<table role="presentation" style="width:94%;max-width:600px;border:none;border-spacing:0;text-align:left;font-family:Arial,sans-serif;font-size:16px;line-height:22px;color:#363636;"> <tr> '+
             '<td style="padding:40px 30px 30px 30px;text-align:center;font-size:24px;font-weight:bold;"></td></tr><tr> <td style="padding:30px;padding-bottom:0px;background-color:#ffffff;"> '+
             '<h1 style="margin-top:0;margin-bottom:16px;font-size:26px;line-height:32px;font-weight:bold;letter-spacing:-0.02em;"><center>Encaminhamento de dados cadastrais<center></h1> '+
             '<p style="margin:0;">Prezado(a) {{NOME}}, seguem dados inseridos no sistema:</p><p><b>CPF: </b>{{CPF}}</p><p><b>RG: </b>{{RG}}</p></td></tr><tr> <td style="padding:30px;padding-top:0px;padding-bottom:0px;background-color:#ffffff;">'+
             '<h3 style="margin-top:0;margin-bottom:16px;font-size:20px;line-height:24px;font-weight:bold;letter-spacing:-0.02em;"><center>Endereço<center></h3> <p><b>CEP: </b>{{CEP}}</p><p><b>Logradouro: </b>{{LOGRADOURO}}</p><p><b>Número: </b>'+
             '{{NUMERO}}</p><p><b>Bairro: </b>{{BAIRRO}}</p><p><b>Complemento: </b>{{COMPLEMENTO}}</p><p><b>País: </b>{{PAIS}}</p><p><b>UF: </b>{{UF}}</p><p><b>Cidade: </b>{{CIDADE}}</p></td></tr><tr> <td style="padding:30px;padding-top:0px;padding-bottom:'+
             '0px;background-color:#ffffff;"> <h3 style="margin-top:0;margin-bottom:16px;font-size:20px;line-height:24px;font-weight:bold;letter-spacing:-0.02em;"><center>Contato<center></h3> <p><b>Telefone: </b>{{FONE}}</p><p><b>E-mail: </b>{{EMAIL}}</p><p>'+
             '<center>O anexo contém arquivo XML correspondente aos dados.<center></p></td></tr><tr> <td style="padding:30px;text-align:center;font-size:12px;background-color:#FF4500;color:#ffffff;"> <p style="margin:0;font-size:14px;line-height:20px;font-weight:bold;'+
             'letter-spacing:-0.02em;">{{RAZAOSOCIAL}}</p><p style="margin:0;font-size:14px;line-height:20px;font-weight:bold;letter-spacing:-0.02em;">{{CONTATO}}</p></td></tr></table><!--[if mso]> </td></tr></table><![endif]-->'+
             ' </td></tr></table> </div></body></html>';

    sBody := StringReplace(sBody, '{{CPF}}'        , FormatMaskText('999.999.999\-99;0;_', mainDM.cdsMain.FieldByName('ID').AsString), [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{RG}}'         , FormatMaskText('99.999.999-9;0;_', mainDM.cdsMain.FieldByName('RG').AsString), [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{NOME}}'       , mainDM.cdsMain.FieldByName('NOME').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{CEP}}'        , FormatMaskText('99999\-999;0;_', mainDM.cdsMain.FieldByName('CEP').AsString), [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{LOGRADOURO}}' , mainDM.cdsMain.FieldByName('LOGRADOURO').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{NUMERO}}'     , mainDM.cdsMain.FieldByName('NUMERO').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{BAIRRO}}'     , mainDM.cdsMain.FieldByName('BAIRRO').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{COMPLEMENTO}}', mainDM.cdsMain.FieldByName('COMPLEMENTO').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{PAIS}}'       , mainDM.cdsMain.FieldByName('PAIS').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{UF}}'         , mainDM.cdsMain.FieldByName('ESTADO').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{CIDADE}}'     , mainDM.cdsMain.FieldByName('CIDADE').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{FONE}}'       , FormatMaskText('(99) #9999-9999;0;', mainDM.cdsMain.FieldByName('TELEFONE').AsString), [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{EMAIL}}'      , mainDM.cdsMain.FieldByName('EMAIL').AsString, [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{RAZAOSOCIAL}}', 'Lorem Ipsum Sistemas', [rfReplaceAll]);
    sBody := StringReplace(sBody, '{{CONTATO}}'    , '(01) 0102-0304', [rfReplaceAll]);

    IdText.Body.Text := sBody;

    IdText.ContentType := 'text/html; charset=iso-8859-1';


    GeraXML();
    sAnexo := 'dadoscliente.xml';
    if FileExists(sAnexo) then
    begin
      TIdAttachmentFile.Create(IdMessage.MessageParts, sAnexo);
    end;

    try
      IdSMTP.Connect;
      IdSMTP.Authenticate;
    except
      on E:Exception do
      begin
        MessageDlg('Erro na conexão ou autenticação: ' + E.Message, mtWarning, [mbOK], 0);
        Exit;
      end;
    end;

    try
      IdSMTP.Send(IdMessage);
      MessageDlg('Mensagem enviada com sucesso!', mtInformation, [mbOK], 0);
    except
      On E:Exception do
      begin
        MessageDlg('Erro ao enviar a mensagem: ' + E.Message, mtWarning, [mbOK], 0);
      end;
    end;
  finally
    IdSMTP.Disconnect;
    UnLoadOpenSSLLibrary;
    FreeAndNil(IdMessage);
    FreeAndNil(IdSSLIOHandlerSocket);
    FreeAndNil(IdSMTP);
  end;
end;

procedure TformMain.Maintenance(Rotina : TRotine);
var
  iID : String;
begin
  if Rotina in [rtEdit, rtRemove] then
    iID := mainDM.cdsMain.FieldByName('ID').AsString;

  uCadCliente.Execute(Rotina, iID);
  LoadData();
  mainDM.cdsMain.Locate('ID', iID, []);
end;

procedure TformMain.btnSearchClick(Sender: TObject);
var
  vsSearchField : String;
begin
  case cboFilterType.ItemIndex of
    0: vsSearchField := 'ID';
    1: vsSearchField := 'NOME';
  end;

  mainDM.cdsMain.Filter   := 'UPPER(' + vsSearchField + ') LIKE UPPER(''%' + edtSearchValue.Text + '%'')';
  mainDM.cdsMain.Filtered := True;
end;

procedure TformMain.btnUpdateClick(Sender: TObject);
begin
  LoadData();
end;

procedure TformMain.dsMainStateChange(Sender: TObject);
begin
  SetButtons();
end;

procedure TformMain.edtSearchValueKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
    Key:= #0;
    btnSearchClick(Self);
  end;
end;

procedure TformMain.FormCreate(Sender: TObject);
begin
  LoadData;
end;

procedure TformMain.LoadData();
begin
  if not(mainDM.cdsMain.Active) and (mainDM.cdsMain.Fields.Count > 0) then
    mainDM.cdsMain.CreateDataSet;

  mainDM.cdsMain.Open;

  UpdateGridTitles(dbgMain, mainDM.cdsMain);

  btnSearchClick(Self);

  SetButtons();
end;

procedure TformMain.SetButtons();
begin
  btnInsert.Enabled := true;
  btnEdit.Enabled   := (mainDM.cdsMain.RecordCount > 0);
  btnDelete.Enabled := (mainDM.cdsMain.RecordCount > 0);
  btnMail.Enabled   := (mainDM.cdsMain.RecordCount > 0);
end;

end.
