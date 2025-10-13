unit Fb25Statement;

interface
uses
  Fb25Interfaces, FbInterfaces, fib, IB_Externals, ibase, IB_Intf, System.Classes;

type

  TFb25Statement = class(TInterfacedObject, IFb25Statement)
  private
    FAttachment: IFb25Attachment;
    FStatus    : IFb25Status;
    FHandle    : TISC_STMT_HANDLE;
    FProvider  : IFb25Provider;
    FFieldCount: Integer;
    FInputMetadata : IFb25MessageMetadata;
    FOutputMetadata: IFb25MessageMetadata;
  protected
    function GetAttachment: IFbAttachment;
    function GetStatus: IFbStatus;
    function GetType: Byte;
    procedure Close;
    procedure Drop;
    procedure Execute(ATransaction: IFbTransaction; ASqlDialect: Integer);
    function OpenCursor(ATransaction: IFbTransaction; ASqlDialect: Integer): IFbResultSet;

    procedure SetCursorName(const AName: string);
    function GetInputMetadata(ASqlDialect: integer): IFbMessageMetadata;
    function GetOutputMetadata(ASqlDialect: integer): IFbMessageMetadata;
    function GetPHandle: PISC_STMT_HANDLE;

    function GetPlan: string;
    function GetAllRowsAffected: TAllRowsAffected;
    procedure GetFieldAlias(AList: TStrings);
  public
    constructor Create(AAttachment: IFbAttachment; AHandle: TISC_STMT_HANDLE; AFieldCount: Integer);
  end;

implementation
uses
  Fb25ResultSet, Fb25MessageMetadata;

function Get_Numeric_Info(ClientLibrary: IIbClientLibrary; var buffer: PAnsiChar): integer;
var
  L: Short;
begin
  if not Assigned(ClientLibrary) then
    Result := -1
  else
  begin
    L := ClientLibrary.isc_vax_integer(buffer, 2);
    Inc(buffer, 2);
    Result := ClientLibrary.isc_vax_integer(buffer, L);
    Inc(buffer, L);
  end;
end;


function Get_String_Info(ClientLibrary: IIbClientLibrary; var SourceBuffer: PAnsiChar; DestBuffer: PAnsiChar;
  Dest_len: integer): integer;
var
  p: PAnsiChar;
begin
  if not Assigned(ClientLibrary) then
    Result := -1
  else
  begin
    FillChar(DestBuffer[0], Dest_len, 0);
    p := SourceBuffer;
    Result := ClientLibrary.isc_vax_integer(p, 2);
    if Result >= Dest_len then
      Result := Dest_len - 1;
    Move(SourceBuffer[2], DestBuffer[0], Result);
    Inc(SourceBuffer, Result + 2);
  end
end;


{ TFb25Statement }

constructor TFb25Statement.Create(AAttachment: IFbAttachment; AHandle: TISC_STMT_HANDLE; AFieldCount: Integer);
begin
  FAttachment := AAttachment as IFb25Attachment;
  FStatus     := AAttachment.Status as IFb25Status;
  FHandle     := AHandle;
  FProvider   := (FAttachment.Provider as IFb25Provider);
  FFieldCount := AFieldCount;
end;

function TFb25Statement.GetAttachment: IFbAttachment;
begin
  Result := FAttachment;
end;

procedure TFb25Statement.GetFieldAlias(AList: TStrings);
var
  Result_buffer: array[0..32766] of AnsiChar;
  PResult: PAnsiChar;
  item: PAnsiChar;
  index: Short;
  InfoRequest: array[0..4] of AnsiChar;
  vSQL: Ansistring;
  RN: Ansistring;
  tmpBuf: array[0..LENGTH_METANAMES-1] of AnsiChar;
begin
  InfoRequest[0] := AnsiChar(isc_info_sql_select);
  InfoRequest[1] := AnsiChar(isc_info_sql_describe_vars);
  InfoRequest[2] := AnsiChar(isc_info_sql_sqlda_seq);
  InfoRequest[3] := AnsiChar(frb_info_sql_relation_alias);
  InfoRequest[4] := AnsiChar(isc_info_sql_describe_end);

  FProvider.ClientLibrary.isc_dsql_sql_info(StatusVector, @FHandle, SizeOf(InfoRequest), @InfoRequest[0],
    32766, Result_buffer);

  if (Result_buffer[0] <> AnsiChar(isc_info_sql_select)) or (Result_buffer[1] <> AnsiChar(isc_info_sql_describe_vars))
    then
  begin
    Exit;
  end;

  PResult := @Result_buffer[2];
  Get_Numeric_Info(FProvider.ClientLibrary, PResult);
  index := 0;

  while PResult[0] <> AnsiChar(isc_info_end) do
  begin
    item := PResult;
    if item[0] = AnsiChar(isc_info_sql_describe_end) then
      Inc(PResult, 1)
    else
      while item[0] <> AnsiChar(isc_info_sql_describe_end) do
      begin
        Inc(PResult, 1);
        case Byte(item[0]) of
          isc_info_sql_sqlda_seq:
            begin
              index := get_numeric_info(FProvider.ClientLibrary, PResult) - 1;
            end;
          frb_info_sql_relation_alias:
            begin
              get_string_info(FProvider.ClientLibrary, PResult, @tmpBuf[0], SizeOf(tmpBuf));

              if index >= AList.Count then
              begin
                AList.Capacity := index + 1;
              end;

              if (tmpBuf <> '') then
              begin
                AList.Strings[index] := tmpBuf;
              end;
            end;
          isc_info_truncated:
            begin

            end;
        end;
        item := PResult;
      end;
  end;
end;

function TFb25Statement.GetStatus: IFbStatus;
begin
  FStatus := FStatus;
end;

procedure TFb25Statement.Close;
begin
  FProvider.ClientLibrary.isc_dsql_free_statement(StatusVector, @FHandle, DSQL_close);
end;

procedure TFb25Statement.Drop;
begin
  FProvider.ClientLibrary.isc_dsql_free_statement(FStatus.StatusVector, @FHandle, DSQL_drop);
end;

function TFb25Statement.OpenCursor(ATransaction: IFbTransaction; ASqlDialect: Integer): IFbResultSet;
begin
  FProvider.ClientLibrary.isc_dsql_execute2(FStatus.StatusVector, (ATransaction as IFb25Transaction).GetPHandle,
   @FHandle, ASqlDialect, FInputMetadata.GetPXSQLDA, FOutputMetadata.GetPXSQLDA);

  if not FStatus.HasErrors then
  begin
    Result := TFb25ResultSet.Create(FAttachment, FHandle, FOutputMetadata) as IFbResultSet;
  end;
end;

procedure TFb25Statement.Execute(ATransaction: IFbTransaction; ASqlDialect: Integer);
begin
  FProvider.ClientLibrary.isc_dsql_execute(FStatus.StatusVector, (ATransaction as IFb25Transaction).GetPHandle,
   @FHandle, ASqlDialect, FInputMetadata.GetPXSQLDA);
end;

function TFb25Statement.GetPHandle: PISC_STMT_HANDLE;
begin
  Result := @FHandle;
end;

const
 cPlanMaxLength = 16384;

function TFb25Statement.GetPlan: string;
var
  Result_buffer: array[0..cPlanMaxLength] of AnsiChar;
  Result_length: Integer;
  info_request: AnsiChar;
  Position:integer;
begin
  info_request := AnsiChar(isc_info_sql_get_plan);
  FProvider.ClientLibrary.isc_dsql_sql_info(StatusVector, @FHandle, 1, @info_request, SizeOf(Result_buffer),
    Result_buffer);

  if (FStatus.HasErrors) then
     Exit;

  Result_length := FProvider.ClientLibrary.isc_vax_integer(@Result_buffer[1], 2);

  Position := 3;
  while (Result_length > 0) and (Result_buffer[Position] in [#0, #10, #13, #9, ' ']) do
  begin
    Inc(Position);
    Dec(Result_length);
  end;

  if Result_length > 0 then
    SetString(Result, PAnsiChar(@Result_buffer[Position]), Result_length)
  else
    Result := '';
end;


function TFb25Statement.GetType: Byte;
var
  stmt_len: Integer;
  res_buffer: array[0..7] of AnsiChar;
  type_item: AnsiChar;
begin
  type_item := AnsiChar(isc_info_sql_stmt_type);
  FProvider.ClientLibrary.isc_dsql_sql_info(FStatus.StatusVector,
    @FHandle, 1, @type_item, SizeOf(res_buffer), res_buffer);

  if (not FStatus.HasErrors) then
  begin
    stmt_len := FProvider.ClientLibrary.isc_vax_integer(@res_buffer[1], 2);
    result   := FProvider.ClientLibrary.isc_vax_integer(@res_buffer[3], stmt_len);
  end;
end;

procedure TFb25Statement.SetCursorName(const AName: string);
begin
  FProvider.ClientLibrary.isc_dsql_set_cursor_name(FStatus.StatusVector,
    GetPHandle, PAnsiChar(AnsiString(AName)), 0);
end;

function TFb25Statement.GetInputMetadata(ASqlDialect: integer): IFbMessageMetadata;
begin
  if FInputMetadata <> nil then
  begin
    Exit(FInputMetadata);
  end;

  FInputMetadata := TFb25MessageMetadata.Create(FAttachment, FStatus, 0);
  FProvider.ClientLibrary.isc_dsql_describe_bind(FStatus.StatusVector, GetPHandle, ASqlDialect,
    FInputMetadata.GetPXSQLDA);

  if not FStatus.HasErrors then
  begin
    Exit(FInputMetadata);
  end
  else
  begin
    FInputMetadata := nil;
  end;
end;

function TFb25Statement.GetOutputMetadata(ASqlDialect: integer): IFbMessageMetadata;
begin
  if FOutputMetadata <> nil then
  begin
    Exit(FOutputMetadata);
  end;

  FOutputMetadata := TFb25MessageMetadata.Create(FAttachment, FStatus, FFieldCount);

  FOutputMetadata.SetCount(FFieldCount);
  //  FSQLRecord.Count := FSQLRecord.FXSQLDA^.sqld;
  FProvider.ClientLibrary.isc_dsql_describe(FStatus.StatusVector, GetPHandle, ASqlDialect,
    FOutputMetadata.GetPXSQLDA);

  if not FStatus.HasErrors then
  begin
    Exit(FOutputMetadata);
  end
  else
  begin
    FOutputMetadata := nil;
  end;


end;

function TFb25Statement.GetAllRowsAffected: TAllRowsAffected;
var
  InfoBuffer: PAnsiChar;
  AllocAddr: PAnsiChar;
  info_request: AnsiChar;
  InfoLen: integer;

  function ReadRequest: integer;
  begin
    with FProvider.ClientLibrary do
    begin
      Inc(InfoBuffer);
      InfoLen := isc_vax_integer(InfoBuffer, 2);
      Inc(InfoBuffer, 2);
      Result := isc_vax_integer(InfoBuffer, InfoLen);
      Inc(InfoBuffer, InfoLen);
    end;
  end;

begin
  InfoBuffer := AllocMem(255);
  AllocAddr := InfoBuffer;
  try
    with FProvider.ClientLibrary do
    begin
      info_request := AnsiChar(isc_info_sql_records);
      FillChar(Result, SizeOf(Result), 0);

      if isc_dsql_sql_info(StatusVector, @FHandle, 1, @info_request, 255, InfoBuffer) > 0 then
        Exit;

      if (InfoBuffer[0] = AnsiChar(isc_info_end)) then
        Exit;

      if (InfoBuffer[0] <> AnsiChar(isc_info_sql_records)) then
        FIBError(feUnknownError, [nil]);

      Inc(InfoBuffer);
      InfoLen := isc_vax_integer(InfoBuffer, 2);

      if InfoLen > 255 then
      begin
        InfoBuffer := AllocAddr;
        ReallocMem(InfoBuffer, InfoLen);
        AllocAddr := InfoBuffer;
        if isc_dsql_sql_info(StatusVector, @FHandle, 1, @info_request, InfoLen, InfoBuffer) > 0 then
          Exit;

        Inc(InfoBuffer);
      end;

      Inc(InfoBuffer, 2);

      while Byte(InfoBuffer[0]) <> isc_info_end do
        case Byte(InfoBuffer[0]) of
          isc_info_req_insert_count:
            Result.Inserts := ReadRequest;
          isc_info_req_update_count:
            Result.Updates := ReadRequest;
          isc_info_req_select_count:
            Result.Selects := ReadRequest;
          isc_info_req_delete_count:
            Result.Deletes := ReadRequest;
        else
          FIBError(feUnknownError, [nil]);
        end;
    end;
  finally
    FreeMem(AllocAddr);
  end;
end;

end.
