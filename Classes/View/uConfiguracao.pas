unit uConfiguracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.DBCtrls, Vcl.Mask,
  Vcl.ComCtrls, System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfrmConfiguracao = class(TForm)
    pgcMain: TPageControl;
    tbsMain: TTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    edtServidor: TEdit;
    edtPorta: TEdit;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    edtAssunto: TEdit;
    imgBtns: TImageList;
    pnlTop: TPanel;
    btnSave: TBitBtn;
    btnCancel: TBitBtn;
    chkSsl: TCheckBox;
    chkTLS: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;

implementation

uses
  uConfig;

{$R *.dfm}

procedure TfrmConfiguracao.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmConfiguracao.btnSaveClick(Sender: TObject);
begin
  Config.Email.Servidor := edtServidor.Text;
  Config.Email.Porta    := StrToIntDef(edtPorta.Text, 0);
  Config.Email.Usuario  := edtUsuario.Text;
  Config.Email.Senha    := edtSenha.Text;
  Config.Email.SSL      := chkSSL.Checked;
  Config.Email.TLS      := chkTLS.Checked;
  Config.Email.Assunto  := edtAssunto.Text;
  Config.Salvar;
  ModalResult := mrOk;
end;

procedure TfrmConfiguracao.FormCreate(Sender: TObject);
begin
  edtServidor.Text := Config.Email.Servidor;
  edtPorta.Text    := IntToStr(Config.Email.Porta);
  edtUsuario.Text  := Config.Email.Usuario;
  edtSenha.Text    := Config.Email.Senha;
  chkSSL.Checked   := Config.Email.SSL;
  chkTLS.Checked   := Config.Email.TLS;
  edtAssunto.Text  := Config.Email.Assunto;
end;

end.
