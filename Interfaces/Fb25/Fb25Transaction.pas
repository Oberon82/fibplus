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
    TPB: AnsiString;
  protected

  public
    procedure GenerateParams(AParams: TStrings; IsFB21orMore:boolean);
    procedure GenerateDistributedParams(Attachment: IFbAttachment);
  end;

  TFb25Transaction = class(TInterfacedObject, IFb25Transaction)
  private
    FHandle: TISC_TR_HANDLE;
  protected
    function GetHandle: TISC_TR_HANDLE;
    function GetPHandle: PISC_TR_HANDLE;
  public
    procedure Commit(AStatus: IFbStatus);
    procedure CommitRetaining(AStatus: IFbStatus);
    procedure Rollback(AStatus: IFbStatus);
    procedure RollbackRetaining(AStatus: IFbStatus);
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

procedure TFb25TransactionParams.GenerateDistributedParams(Attachment: IFbAttachment);
var
  pteb: PISC_TEB_ARRAY;
  TPB: Ansistring;
  i: Integer;
  vTRParams1:TStrings;
  vTPBLength:Short;
  vIsFB21orMore:boolean;
  transactionParams: IFbTransactionParams;
begin
//  for i := 0 to DatabaseCount - 1 do
//  begin
//    pteb^[i].db_handle   := (Databases[i].PHandle);
//    if vTRParams[i]='' then
//    begin
//     pteb^[i].tpb_address := FTPB;
//     pteb^[i].tpb_length  := FTPBLength;
//    end
//    else
//    begin
//     if vTRParams1=nil then
//      vTRParams1:=TStringList.Create;
//     vTRParams1.Text:=vTRParams[i];
//
//     SetLength(vTPBArray,i+1);
//     GenerateTPB(vTRParams1, vTPBArray[i], vTPBLength,vIsFB21orMore);
//     if Length(vTPBArray[i])>0 then
//     begin
//      pteb^[i].tpb_address := @vTPBArray[i][1];
//      pteb^[i].tpb_length  := vTPBLength;
//     end
//     else
//     begin
//      pteb^[i].tpb_address := FTPB;
//      pteb^[i].tpb_length  := FTPBLength;
//     end
//    end;
//  end;
end;

procedure TFb25TransactionParams.GenerateParams(AParams: TStrings; IsFB21orMore:boolean);
var
  i, j, TPBVal, ParamLength: Integer;
  param_name, param_value: AnsiString;
  LT:word;
begin
//  TPB := '';
//  if (sl.Count = 0) then
//    TPBLength := 0
//  else
//  begin
//    TPBLength := sl.Count + 1;
//    TPB := TPB + AnsiChar(isc_tpb_version3);
//  end;
//  for i := 0 to sl.Count - 1 do
//  begin
//    sl[i]:=FastTrim(sl[i]);
//    if sl[i]='' then
//    begin
//     Dec(TPBLength);
//     Continue;
//    end;
//    GetNameAndValue(sl[i],param_name,param_value);
//    DoLowerCase(param_name);
//
//    if (Pos(TPBPrefix, param_name) = 1) then
//       param_name:=FastCopy(param_name,Length(TPBPrefix)+1,MaxInt);
//
//    if TPBConstants.Find(param_name,j) then
//      TPBVal :=Integer(TPBConstants.Objects[j])
//    else
//      TPBVal := 0;
//    (* Now act on it *)
//    case TPBVal of
//      isc_tpb_consistency, isc_tpb_exclusive, isc_tpb_protected,
//      isc_tpb_concurrency, isc_tpb_shared, isc_tpb_wait, isc_tpb_nowait,
//      isc_tpb_read, isc_tpb_write, isc_tpb_ignore_limbo,
//      isc_tpb_read_committed, isc_tpb_rec_version, isc_tpb_no_rec_version,
//      isc_tpb_no_auto_undo{,isc_tpb_no_savepoint}:
//        TPB := TPB + AnsiChar(TPBVal);
//      isc_tpb_lock_read, isc_tpb_lock_write:
//      begin
//        TPB := TPB + AnsiChar(TPBVal);
//        // Now set the string parameter
//        ParamLength := Length(param_value);
//        Inc(TPBLength, ParamLength + 1);
//        TPB := TPB + AnsiChar(ParamLength) + param_value;
//      end;
//    else
//      begin
//        if (TPBVal > 0) and
//           (TPBVal <= isc_tpb_last_tpb_constant) then
//        begin
//         if TPBVal<>isc_tpb_no_savepoint {isc_tpb_lock_timeout} then
//          FIBError(feTPBConstantNotSupported,
//                   [TPBConstantNames[TPBVal]])
//         else
//         begin
//          if IsFB21orMore then
//          begin
//          // isc_tpb_lock_timeout
//            TPB := TPB + AnsiChar(TPBVal);
//            TPB := TPB + #2 ;
//            LT:=StrToIntDef(param_value,10);
//
//           TPB  := TPB  + PAnsiChar(@LT)[0] + PAnsiChar(@LT)[1] ;
//           Inc(TPBLength, 1+SizeOf(Word));
//          end
//          else
//           TPB := TPB + AnsiChar(TPBVal); // isc_tpb_no_savepoint
//         end;
//        end
//        else
//          FIBError(feTPBConstantUnknown, [param_name]);
//      end;
//    end;
//  end;
end;

{ TFb25Transaction }

procedure TFb25Transaction.Commit(AStatus: IFbStatus);
begin
//  status := Call(IIbClientLibrary(MainDatabase).isc_commit_transaction(StatusVector, GetPHandle), False);
end;

procedure TFb25Transaction.CommitRetaining(AStatus: IFbStatus);
begin
//  Call(IIbClientLibrary(MainDatabase).isc_commit_retaining(StatusVector, GetPHandle), True);
end;

function TFb25Transaction.GetHandle: TISC_TR_HANDLE;
begin
  Result := FHandle;
end;

function TFb25Transaction.GetPHandle: PISC_TR_HANDLE;
begin
  Result := @FHandle;
end;

procedure TFb25Transaction.Rollback(AStatus: IFbStatus);
begin
  inherited;
//  status := Call(IIbClientLibrary(MainDatabase).isc_rollback_transaction(StatusVector, GetPHandle), False)
end;

procedure TFb25Transaction.RollbackRetaining(AStatus: IFbStatus);
begin
//  Call(IIbClientLibrary(MainDatabase).isc_rollback_retaining(StatusVector, GetPHandle), True);
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
