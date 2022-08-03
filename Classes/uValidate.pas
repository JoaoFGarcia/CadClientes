unit uValidate;

interface

uses
  Vcl.DBGrids,
  Datasnap.DBClient,
  System.RegularExpressions;

type
  TRotine = (rtInsert, rtEdit, rtRemove);

function validateCNPJ(CNPJ: string): boolean;
function validateCPF(ACPF: string): Boolean;
procedure UpdateGridTitles(Grid: TDBGrid; DataSet : TClientDataSet);
function validatePhone(APhone : String) : Boolean;
function validateEmail(AEmail : String) : boolean;

implementation

uses SysUtils;

procedure UpdateGridTitles(Grid: TDBGrid; DataSet : TClientDataSet);
var
  i       : Integer;
begin
  for i := 0 to Grid.Columns.Count - 1 do
  begin
    try
      Grid.Columns[i].Title.Caption := DataSet.FindField(Grid.Columns[i].FieldName).DisplayLabel;
    except
    end;
  end;
end;

function validatePhone(APhone : String) : Boolean;
var
  rRegex            : TRegex;
begin
  if APhone <> '' then
  begin
    Result := rRegex.IsMatch(APhone, '^([0-9]{2})(?:[0-9]{4}|9[0-9]{4})[0-9]{4}$');
  end;
end;

function validateEmail(AEmail : String) : boolean;
var
  rRegex            : TRegex;
begin
  if AEmail<> '' then
  begin
    Result := rRegex.IsMatch(AEmail, '^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]*[a-zA-Z0-9]+$');
  end;
end;

function validateCPF(ACPF: string): Boolean;
var
  dig10,
  dig11 : string;
  s,
  i,
  r,
  peso  : integer;
begin
  if ((ACPF = '00000000000') or (ACPF = '11111111111') or
      (ACPF = '22222222222') or (ACPF = '33333333333') or
      (ACPF = '44444444444') or (ACPF = '55555555555') or
      (ACPF = '66666666666') or (ACPF = '77777777777') or
      (ACPF = '88888888888') or (ACPF = '99999999999') or
      (length(ACPF) <> 11))
  then
  begin
    validateCPF := false;
    Exit;
  end;

  try
    s := 0;
    peso := 10;
    for i := 1 to 9 do
    begin

      s := s + (StrToInt(ACPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
       then dig10 := '0'
    else str(r:1, dig10);


    s := 0;
    peso := 11;
    for i := 1 to 10 do
    begin
      s := s + (StrToInt(ACPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
       then dig11 := '0'
    else str(r:1, dig11);


    if ((dig10 = ACPF[10]) and (dig11 = ACPF[11]))
       then validateCPF := true
    else validateCPF := false;
  except
    validateCPF := false
  end;
end;

function validateCNPJ(CNPJ: string): boolean;
var
  dig13, dig14: string;
  sm, i, r, peso: integer;
begin
  if ((CNPJ = '00000000000000') or (CNPJ = '11111111111111') or
    (CNPJ = '22222222222222') or (CNPJ = '33333333333333') or
    (CNPJ = '44444444444444') or (CNPJ = '55555555555555') or
    (CNPJ = '66666666666666') or (CNPJ = '77777777777777') or
    (CNPJ = '88888888888888') or (CNPJ = '99999999999999') or
    (length(CNPJ) <> 14)) then
  begin
    validateCNPJ := false;
    exit;
  end;
  try

    sm := 0;
    peso := 2;
    for i := 12 downto 1 do
    begin
      sm := sm + (StrToInt(CNPJ[i]) * peso);
      peso := peso + 1;
      if (peso = 10) then
        peso := 2;
    end;
    r := sm mod 11;
    if ((r = 0) or (r = 1)) then
      dig13 := '0'
    else
      str((11 - r): 1, dig13);

    sm := 0;
    peso := 2;
    for i := 13 downto 1 do
    begin
      sm := sm + (StrToInt(CNPJ[i]) * peso);
      peso := peso + 1;
      if (peso = 10) then
        peso := 2;
    end;
    r := sm mod 11;
    if ((r = 0) or (r = 1)) then
      dig14 := '0'
    else
      str((11 - r): 1, dig14);

    if ((dig13 = CNPJ[13]) and (dig14 = CNPJ[14])) then
      validateCNPJ := true
    else
      validateCNPJ := false;
  except
    validateCNPJ := false
  end;
end;

end.
