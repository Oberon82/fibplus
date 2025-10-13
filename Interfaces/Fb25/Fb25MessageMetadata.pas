unit Fb25MessageMetadata;

interface
uses
  Fb25Interfaces, FbInterfaces, ibase;

type

  TFb25MessageMetadata = class(TInterfacedObject, IFb25MessageMetadata)
  private
    FAttachment: IFbAttachment;
    FStatus    : IFbStatus;
    FXSQLDA    : PXSQLDA;
    FCount     : Integer;
  protected
    function GetAttachment: IFbAttachment;
    function GetStatus: IFbStatus;
    procedure SetCount(ACount: Integer);

    function GetCount: Integer;
    function GetField(AIndex: Cardinal): string;
    function GetRelation(AIndex: Cardinal): string;
    function GetOwner(AIndex: Cardinal): string;
    function GetAlias(AIndex: Cardinal): string;
    function GetType(AIndex: Cardinal): Cardinal;
    function IsNullable(AIndex: Cardinal): Boolean;
    function GetSubType(AIndex: Cardinal): Cardinal;
    function GetLenth(AIndex: Cardinal): Cardinal;
    function GetScale(AIndex: Cardinal): Integer;
    function GetCharSet(AIndex: Cardinal): Cardinal;
    function GetOffset(AIndex: Cardinal): Cardinal;
    function GetNullOffset(AIndex: Cardinal): Cardinal;
    function GetMessageLength(AIndex: Cardinal): Cardinal;
  public
    constructor Create(AAttachment: IFbAttachment; AStatus: IFbStatus; AInitialFieldCount: Integer);
    destructor Destroy; override;
    function GetPXSQLDA: PXSQLDA;
  end;

implementation

{ TFb25MessageMetadata }
uses fib;

constructor TFb25MessageMetadata.Create(AAttachment: IFbAttachment; AStatus: IFbStatus; AInitialFieldCount: Integer);
begin
  FAttachment := AAttachment;
  FStatus     := AStatus;
  FIBAlloc(FXSQLDA, 0, XSQLDA_LENGTH(AInitialFieldCount + 1));
  FXSQLDA^.version := SQLDA_VERSION_CURRENT;
  FCount := AInitialFieldCount;
end;

destructor TFb25MessageMetadata.Destroy;
var
  i: integer;
begin
  for i := 0 to FXSQLDA^.sqln - 1 do
  begin
    FIBAlloc(FXSQLDA^.sqlvar[i].sqldata, 0, 0);
    FIBAlloc(FXSQLDA^.sqlvar[i].sqlind, 0, 0);
  end;
  FIBAlloc(FXSQLDA, 0, 0);
  inherited;
end;

function TFb25MessageMetadata.GetAlias(AIndex: Cardinal): string;
begin
//  if not Assigned(FParent) or FParent.FIsParams then
//   Result := ''
//  else
//  with FParent.FXSQLVARs[FIndex].Data^ do
//    SetString(Result, aliasname, aliasname_length)
end;

function TFb25MessageMetadata.GetAttachment: IFbAttachment;
begin
  Result := FAttachment;
end;

function TFb25MessageMetadata.GetCharSet(AIndex: Cardinal): Cardinal;
begin
//  if not Assigned(FParent) then
//   Result :=UnknownStr
//  else
//  with FParent.FXSQLVARs[FIndex].Data^ do
//  begin
//    if  (Byte(sqlsubtype)<61) then
//     Result:=IBStdCharacterSets[Byte(sqlsubtype)]
//    else
//     Result :=UnknownStr
//  end
end;

function TFb25MessageMetadata.GetCount: Integer;
begin
  Result := FCount;
end;

function TFb25MessageMetadata.GetField(AIndex: Cardinal): string;
begin
//  if not Assigned(FParent) or FParent.FIsParams then
//   Result := ''
//  else
//  with FParent.FXSQLVARs[FIndex].Data^ do
//    SetString(Result, sqlname, sqlname_length)
end;

function TFb25MessageMetadata.GetLenth(AIndex: Cardinal): Cardinal;
begin

end;

function TFb25MessageMetadata.GetMessageLength(AIndex: Cardinal): Cardinal;
begin

end;

function TFb25MessageMetadata.GetNullOffset(AIndex: Cardinal): Cardinal;
begin

end;

function TFb25MessageMetadata.GetOffset(AIndex: Cardinal): Cardinal;
begin

end;

function TFb25MessageMetadata.GetOwner(AIndex: Cardinal): string;
begin

end;

function TFb25MessageMetadata.GetPXSQLDA: PXSQLDA;
begin
  Result := FXSQLDA;
end;

function TFb25MessageMetadata.GetRelation(AIndex: Cardinal): string;
begin
//  if not Assigned(FParent) or FParent.FIsParams then
//   Result := ''
//  else
//  with FParent.FXSQLVARs[FIndex].Data^ do
//    SetString(Result, relname, relname_length)
end;

function TFb25MessageMetadata.GetScale(AIndex: Cardinal): Integer;
begin
//  Result:=FXSQLVAR^.sqlscale
end;

function TFb25MessageMetadata.GetStatus: IFbStatus;
begin
  Result := FStatus;
end;

function TFb25MessageMetadata.GetSubType(AIndex: Cardinal): Cardinal;
begin
//  Result := FXSQLVAR^.sqlsubtype;
end;

function TFb25MessageMetadata.GetType(AIndex: Cardinal): Cardinal;
begin
//  Result := FXSQLVAR^.sqltype and (not 1);
end;

function TFb25MessageMetadata.IsNullable(AIndex: Cardinal): Boolean;
begin
//  Result := not IsMacro and (FXSQLVAR^.sqltype and 1 = 1);
////  Result := (FXSQLVAR^.sqltype and 1 = 1);
//  if Result and not Assigned(FXSQLVAR^.sqlind) then
//   FIBAlloc(FXSQLVAR^.sqlind, 0, SizeOf(Short));
end;

procedure TFb25MessageMetadata.SetCount(ACount: Integer);
begin
  FIBAlloc(FXSQLDA, XSQLDA_LENGTH(FCount + 1), XSQLDA_LENGTH(ACount + 1));
  FXSQLDA^.version := SQLDA_VERSION_CURRENT;

  if (ACount > 0) then
  begin
    FXSQLDA^.sqln := ACount;
    FXSQLDA^.sqld := ACount;
  end;
end;

end.
