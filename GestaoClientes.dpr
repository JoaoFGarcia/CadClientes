program GestaoClientes;

uses
  Vcl.Forms,
  uMainForm in 'Classes\View\uMainForm.pas' {formMain},
  uCadCliente in 'Classes\View\uCadCliente.pas' {frmCadCliente},
  uValidate in 'Classes\uValidate.pas',
  uMainDM in 'Classes\uMainDM.pas' {mainDM: TDataModule},
  DataSetConverter4D.Helper in 'Classes\DataSetConverter4Delphi\DataSetConverter4D.Helper.pas',
  DataSetConverter4D.Impl in 'Classes\DataSetConverter4Delphi\DataSetConverter4D.Impl.pas',
  DataSetConverter4D in 'Classes\DataSetConverter4Delphi\DataSetConverter4D.pas',
  DataSetConverter4D.Util in 'Classes\DataSetConverter4Delphi\DataSetConverter4D.Util.pas',
  uConfiguracao in 'Classes\View\uConfiguracao.pas' {frmConfiguracao},
  uConfig in 'Classes\uConfig.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'GEST - Gestão de Fornecedores';
  Application.CreateForm(TmainDM, mainDM);
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
  Application.Run;
end.
