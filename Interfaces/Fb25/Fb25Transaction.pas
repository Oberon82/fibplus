unit Fb25Transaction;

interface
uses
  IB_Intf,
  System.SysUtils, IB_Externals, ibase, System.Classes, StrUtil,
  FbInterfaces, Fb25Interfaces;

type

  TFb25TransactionParams = class(TInterfacedObject, IFb25TransactionParams)
  private
    FTPB      : PAnsiChar;
    FTPBLength: Short;
    TPB       : AnsiString;
    vTPBArray : array of Ansistring;
    FTebArray : array of TISC_TEB;
  protected
    function GetTPBLength: Short;
    function GetTPB: PAnsiChar;
    function GetTPBString: AnsiString;
    function GetPTebArray: PISC_TEB_ARRAY;
    function GetPTeb: PISC_TEB;
  public
    procedure GenerateParams(AParams: TStrings; IsFB21orMore: boolean);
    procedure GenerateDistributedParams(Attachment: IFbAttachment; const ATransactionParams: IFbTransactionParams);
  end;

  TFb25Transaction = class(TInterfacedObject, IFb25Transaction)
  private
    FHandle: TISC_TR_HANDLE;
    FAttachment: IFbAttachment;
    FStatus: IFb25Status;
    FProvider: IFb25Provider;
  protected
    function GetHandle: TISC_TR_HANDLE;
    function GetPHandle: PISC_TR_HANDLE;
    function GetAttachment: IFbAttachment;
    function GetStatus: IFbStatus;
    function GetTransactionId: Integer;
  public
    constructor Create(AAttachment: IFbAttachment; AHandle: TISC_TR_HANDLE);
    procedure Commit;
    procedure CommitRetaining;
    procedure Rollback;
    procedure RollbackRetaining;
  end;


implementation
var
  TPBConstants    :TStringList;

const

  TPBPrefix = 'isc_tpb_';
  TPBConstantNames: array[1..isc_tpb_last_tpb_constant] of String = (
    'consistency',
    'concurrency',
    'shared',
    'protected',
    'exclusive',
    'wait',
    'nowait',
    'read',
    'write',
    'lock_read',
    'lock_write',
    'verb_time',
    'commit_time',
    'ignore_limbo',
    'read_committed',
    'autocommit',
    'rec_version',
    'no_rec_version',
    'restart_requests',
    'no_auto_undo',
    'no_savepoint'
  );

{ TFb25TransactionParams }

procedure TFb25TransactionParams.GenerateDistributedParams(Attachment: IFbAttachment; const ATransactionParams:
    IFbTransactionParams);
var
  vTPBLength:Short;
  dbHandle: PISC_DB_HANDLE;
  tmpLength, tmpTebLen: Integer;
begin
  dbHandle := (Attachment as IFB25Attachment).GetPHandle;

  tmpTebLen := Length(FTebArray);
  SetLength(FTebArray, tmpTebLen);
  FTebArray[tmpTebLen].db_handle := dbHandle;

  vTPBLength := (ATransactionParams as IFb25TransactionParams).GetTPBLength;


  if ((ATransactionParams = nil) or (vTPBLength > 0)) then
  begin
    FTebArray[tmpTebLen].tpb_address := FTPB;
    FTebArray[tmpTebLen].tpb_length  := FTPBLength;
  end
  else
  begin
    // COPY Transaction paramString to preserve pointer to it
    tmpLength := Length(vTPBArray);
    SetLength(vTPBArray, tmpLength + 1);
    vTPBArray[tmpLength] := (ATransactionParams as IFb25TransactionParams).GetTPBString;

    // We can use dynamic array as padding and alignment is not required
    FTebArray[tmpTebLen].tpb_address := @vTPBArray[tmpLength][1];
    FTebArray[tmpTebLen].tpb_length  := vTPBLength;
  end;
end;

procedure TFb25TransactionParams.GenerateParams(AParams: TStrings; IsFB21orMore:boolean);
var
  i, j, TPBVal, ParamLength: Integer;
  param_name, param_value: AnsiString;
  LT:word;
begin
  TPB := '';
  if (AParams.Count = 0) then
    FTPBLength := 0
  else
  begin
    FTPBLength := AParams.Count + 1;
    TPB := TPB + AnsiChar(isc_tpb_version3);
  end;


  for i := 0 to AParams.Count - 1 do
  begin
    AParams[i] := FastTrim(AParams[i]);

    if AParams[i] = '' then
    begin
      Dec(FTPBLength);
      Continue;
    end;

    GetNameAndValue(AParams[i], param_name, param_value);
    DoLowerCase(param_name);

    if (Pos(TPBPrefix, param_name) = 1) then
      param_name := FastCopy(param_name, Length(TPBPrefix) + 1, MaxInt);

    if TPBConstants.Find(param_name, j) then
      TPBVal := Integer(TPBConstants.Objects[j])
    else
      TPBVal := 0;

    (* Now act on it *)
    case TPBVal of
      isc_tpb_consistency, isc_tpb_exclusive, isc_tpb_protected,
      isc_tpb_concurrency, isc_tpb_shared, isc_tpb_wait, isc_tpb_nowait,
      isc_tpb_read, isc_tpb_write, isc_tpb_ignore_limbo,
      isc_tpb_read_committed, isc_tpb_rec_version, isc_tpb_no_rec_version,
      isc_tpb_no_auto_undo{,isc_tpb_no_savepoint}:
        begin
          TPB := TPB + AnsiChar(TPBVal);
        end;
      isc_tpb_lock_read, isc_tpb_lock_write:
        begin
          TPB := TPB + AnsiChar(TPBVal);
          // Now set the string parameter
          ParamLength := Length(param_value);
          Inc(FTPBLength, ParamLength + 1);
          TPB := TPB + AnsiChar(ParamLength) + param_value;
        end;
      else
        begin
          if (TPBVal > 0) and (TPBVal <= isc_tpb_last_tpb_constant) then
          begin
            if TPBVal <> isc_tpb_no_savepoint {isc_tpb_lock_timeout} then
            begin
              raise Exception.Create('Unknown parameter');  //TODO: Parameter must be checked before this routine
              //FIBError(feTPBConstantNotSupported,   //TODO: Parameter must be checked before this routine
              //         [TPBConstantNames[TPBVal]]);
            end
            else
            begin
              if IsFB21orMore then
              begin
                // isc_tpb_lock_timeout
                TPB := TPB + AnsiChar(TPBVal);
                TPB := TPB + #2 ;
                LT:=StrToIntDef(param_value,10);

                TPB  := TPB  + PAnsiChar(@LT)[0] + PAnsiChar(@LT)[1] ;
                Inc(FTPBLength, 1+SizeOf(Word));
              end
              else
                TPB := TPB + AnsiChar(TPBVal); // isc_tpb_no_savepoint
            end;
          end
          else
          begin
            raise Exception.Create('Unknown parameter');  //TODO: Parameter must be checked before this routine
            //FIBError(feTPBConstantUnknown, [param_name]);
          end;
        end;
    end;
  end;

  FTPB := @TPB[1];
end;


function TFb25TransactionParams.GetPTeb: PISC_TEB;
begin
  Result := @FTebArray[0];
end;

function TFb25TransactionParams.GetPTebArray: PISC_TEB_ARRAY;
begin
  Result := @FTebArray[0];
end;

function TFb25TransactionParams.GetTPB: PAnsiChar;
begin
  Result := FTPB;
end;

function TFb25TransactionParams.GetTPBLength: Short;
begin
  Result := FTPBLength;
end;

function TFb25TransactionParams.GetTPBString: AnsiString;
begin
  Result := TPB;
end;

{ TFb25Transaction }

constructor TFb25Transaction.Create(AAttachment: IFbAttachment; AHandle: TISC_TR_HANDLE);
begin
  FAttachment := AAttachment;
  FStatus := AAttachment.GetStatus as IFb25Status;
  FHandle := AHandle;
  FProvider := (FAttachment.Provider as IFb25Provider);
end;

function TFb25Transaction.GetAttachment: IFbAttachment;
begin
  Result := FAttachment;
end;

function TFb25Transaction.GetStatus: IFbStatus;
begin
  FStatus := FStatus;
end;

procedure TFb25Transaction.Commit;
begin
  FProvider.ClientLibrary.isc_commit_transaction(FStatus.StatusVector, GetPHandle);
end;

procedure TFb25Transaction.CommitRetaining;
begin
  FProvider.ClientLibrary.isc_commit_retaining(FStatus.StatusVector, GetPHandle);
end;

function TFb25Transaction.GetHandle: TISC_TR_HANDLE;
begin
  Result := FHandle;
end;

function TFb25Transaction.GetPHandle: PISC_TR_HANDLE;
begin
  Result := @FHandle;
end;

function TFb25Transaction.GetTransactionId: Integer;
var tra_items: AnsiChar;
    tra_info :array [0..31] of AnsiChar;
begin
  Result := 0;
  tra_items:=AnsiChar(isc_info_tra_id);
  FProvider.ClientLibrary.isc_transaction_info(FStatus.StatusVector, GetPHandle,
    sizeof (tra_items),
    @tra_items,
    sizeof (tra_info),
    tra_info
   );

  if not FStatus.HasErrors then
  begin
    Result := PInteger(tra_info+3)^;
  end;
end;

procedure TFb25Transaction.Rollback;
begin
  inherited;
  FProvider.ClientLibrary.isc_rollback_transaction(FStatus.StatusVector, GetPHandle);
end;

procedure TFb25Transaction.RollbackRetaining;
begin
  FProvider.ClientLibrary.isc_rollback_retaining(FStatus.StatusVector, GetPHandle);
end;

procedure InitTPBConstantsList;
var i:integer;
begin
  TPBConstants:= TStringList.Create;
  with TPBConstants do
  begin
   Capacity:=isc_tpb_last_tpb_constant;
   for i:=1 to isc_tpb_last_tpb_constant do
    AddObject(TPBConstantNames[i],TObject(i));

   AddObject('lock_timeout',TObject(isc_tpb_lock_timeout));
   Sorted:=true;
  end;
end;

initialization
  InitTPBConstantsList;
finalization
  FreeAndNil(TPBConstants);
end.
