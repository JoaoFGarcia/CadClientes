object mainDM: TmainDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 84
  Width = 120
  object cdsMain: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 16
    Top = 16
    object cdsMainID: TStringField
      Alignment = taCenter
      DisplayLabel = 'CPF'
      FieldName = 'ID'
      EditMask = '999.999.999\-99;0;_'
      Size = 11
    end
    object cdsMainNOME: TStringField
      DisplayLabel = 'Nome'
      FieldName = 'NOME'
      Size = 150
    end
    object cdsMainTELEFONE: TStringField
      DisplayLabel = 'Telefone'
      FieldName = 'TELEFONE'
    end
    object cdsMainEMAIL: TStringField
      DisplayLabel = 'E-mail'
      FieldName = 'EMAIL'
      Size = 100
    end
    object cdsMainCEP: TStringField
      Alignment = taCenter
      FieldName = 'CEP'
      EditMask = '99999\-999;0;_'
      Size = 8
    end
    object cdsMainLOGRADOURO: TStringField
      DisplayLabel = 'Logradouro'
      FieldName = 'LOGRADOURO'
      Size = 150
    end
    object cdsMainCOMPLEMENTO: TStringField
      DisplayLabel = 'Complemento'
      FieldName = 'COMPLEMENTO'
      Size = 200
    end
    object cdsMainBAIRRO: TStringField
      DisplayLabel = 'Bairro'
      FieldName = 'BAIRRO'
      Size = 100
    end
    object cdsMainCIDADE: TStringField
      DisplayLabel = 'Cidade'
      FieldName = 'CIDADE'
      Size = 150
    end
    object cdsMainPAIS: TStringField
      DisplayLabel = 'Pa'#237's'
      FieldName = 'PAIS'
      Size = 100
    end
    object cdsMainNUMERO: TStringField
      DisplayLabel = 'N'#250'mero'
      FieldName = 'NUMERO'
      Size = 10
    end
    object cdsMainESTADO: TStringField
      Alignment = taCenter
      DisplayLabel = 'Estado'
      FieldName = 'ESTADO'
      Size = 50
    end
    object cdsMainRG: TStringField
      FieldName = 'RG'
      EditMask = '99.999.999-9;0;_'
      Size = 11
    end
  end
end
