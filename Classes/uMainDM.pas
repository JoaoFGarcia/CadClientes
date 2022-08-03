unit uMainDM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient, Datasnap.Provider,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  DataSetConverter4D,
  DataSetConverter4D.Impl,
  JSON;

type
  TmainDM = class(TDataModule)
    cdsMain: TClientDataSet;
    cdsMainID: TStringField;
    cdsMainNOME: TStringField;
    cdsMainTELEFONE: TStringField;
    cdsMainEMAIL: TStringField;
    cdsMainCEP: TStringField;
    cdsMainLOGRADOURO: TStringField;
    cdsMainCOMPLEMENTO: TStringField;
    cdsMainBAIRRO: TStringField;
    cdsMainCIDADE: TStringField;
    cdsMainPAIS: TStringField;
    cdsMainNUMERO: TStringField;
    cdsMainESTADO: TStringField;
    cdsMainRG: TStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  mainDM: TmainDM;
  IDs   : TStringList;
const
  sFileName = 'data.json';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TmainDM.DataModuleCreate(Sender: TObject);
var
  jArray   : TJSONArray;
  vContent : TStrings;
begin
  IDs := TStringList.Create;

  if not (cdsMain.Active) then
    cdsMain.CreateDataSet;

  if not FileExists(sFileName) then
    Exit;

  cdsMain.DisableControls;
  vContent := TStringList.Create;
  try
    vContent.LoadFromFile(sFileName);

    jArray := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(vContent.Text), 0) as TJSONArray;

    TConverter.New.JSON.Source(jArray).ToDataSet(cdsMain);

    cdsMain.First;
    while not (cdsMain.Eof) do
    begin
      IDs.Add(cdsMain.FieldByName('ID').AsString);
      cdsMain.Next;
    end;
    cdsMain.First;
  finally
    FreeAndNil(jArray);
    cdsMain.EnableControls;
  end;
end;

procedure TmainDM.DataModuleDestroy(Sender: TObject);
var
  jArray   : TJSONArray;
  vContent : TStrings;
begin
  if cdsMain.IsEmpty then
  begin
    DeleteFile(sFileName);
    Exit;
  end;

  cdsMain.DataSetField := nil;
  vContent := TStringList.Create;
  try
    jArray := TConverter.New.DataSet(cdsMain).AsJSONArray;
    vContent.Text := jArray.ToString;
    vContent.SaveToFile(sFileName);
  finally
    FreeAndNil(jArray);
  end;

end;

end.
