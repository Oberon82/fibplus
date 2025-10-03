unit Fb25Classes;

interface
uses
  FbClasses,
  IB_Intf,
  System.SysUtils, IB_Externals, ibase, System.Classes, StrUtil;

type

  TStatusVector  = array[0..19] of ISC_STATUS;
  PStatusVector  = ^TStatusVector;

  TFb25AttachmentParams = class(TFbAttachmentParams)
  private
    FDPB      : PAnsiChar;
    FDPBLength: Short;
    DPB: AnsiString;
  protected

  public
    procedure GenerateParams(AParams: TStringList; IsFireBird: Boolean); override;
  end;

  TFb25Attachment = class(TFbAttachment)
  private
    FClientLibrary:IIBClientLibrary;
    FHandle: TISC_DB_HANDLE;
    function GetProtectLongDBInfo(DBInfoCommand: Integer;var Success:boolean): Long;
    function GetStringDBInfo(DBInfoCommand: Integer): string;
    function GetLongDBInfo(DBInfoCommand: Integer): Long;
  protected
  public
    function GetAttachmentID: LongInt; override;
    constructor Create(AClientLibrary:IIBClientLibrary; AHandle: TISC_DB_HANDLE);
    property Handle: TISC_DB_HANDLE read FHandle; // TODO: remove
    procedure DropDatabase(AFbStatus: TFbStatus); override;
    procedure DetachDatabase(AFbStatus: TFbStatus); override;
  end;

  TFb25TransactionParams = class(TFbTransactionParams)

  end;

  TFb25Transaction = class(TFbTransaction)

  end;

  TFb25Statement = class(TFbStatement)

  end;

  TFb25Blob = class(TFbBlob)

  end;

  TFb25Array = class(TFbArray)

  end;

  TFb25Status = class(TFbStatus)
  private
  public
    function StatusVector: PISC_STATUS;
    function HasErrors: boolean; override;
    function GetStatusVector: TStatusVector;
  end;

  TFb25ResultSet = class(TFbResultSet)

  end;

  TFb25MessageMetadata = class(TFbMessageMetadata)

  end;

  TFb25Provider = class(TFbProvider)
  private
    FClientLibrary:IIBClientLibrary;
  protected
  public
    constructor Create(AClientLibrary:IIBClientLibrary);
    function AttachDatabase(AStatus: TFbStatus; AFileName: string; AParams: TFbAttachmentParams): TFbAttachment; override;
    function CreateDatabase(AStatus: TFbStatus; AFileName: string; AParams: TFbAttachmentParams): TFbAttachment; override;
    function GetAttachmentParams: TFbAttachmentParams; override;
    function GetTransactionParams: TFbTransactionParams; override;
    function GetStatus: TFbStatus; override;
    property ClientLibrary:IIBClientLibrary read FClientLibrary;
  end;

  TFb25ClientLibrary = class(TObject)
    class function GetProvider(ALibraryName: string): TFb25Provider;
  end;

implementation
uses
  FIBPlatforms;

threadvar
  FStatusVector : TStatusVector;   // TODO: Remove in FIB

const
  (* For building buffers to send to IB *)
  CRLF = #13#10;
  FIBLocalBufferLength = 512;
  FIBBigLocalBufferLength = FIBLocalBufferLength * 2;
  FIBHugeLocalBufferLength = FIBBigLocalBufferLength * 20;
  (* Default "Prefix" to show in error messages. *)

DPBPrefix = 'isc_dpb_';
  DPBConstantNames: array[1..isc_dpb_last_dpb_constant] of String = (
    'cdd_pathname',
    'allocation',
    'journal',
    'page_size',
    'num_buffers',
    'buffer_length',
    'debug',
    'garbage_collect',
    'verify',
    'sweep',
    'enable_journal',
    'disable_journal',
    'dbkey_scope',
    'number_of_users',
    'trace',
    'no_garbage_collect',
    'damaged',
    'license',
    'sys_user_name',
    'encrypt_key',
    'activate_shadow',
    'sweep_interval',
    'delete_shadow',
    'force_write',
    'begin_log',
    'quit_log',
    'no_reserve',
    'user_name',
    'password',
    'password_enc',
    'sys_user_name_enc',
    'interp',
    'online_dump',
    'old_file_size',
    'old_num_files',
    'old_file',
    'old_start_page',
    'old_start_seqno',
    'old_start_file',
    'drop_walfile',
    'old_dump_id',
    'wal_backup_dir',
    'wal_chkptlen',
    'wal_numbufs',
    'wal_bufsize',
    'wal_grp_cmt_wait',
    'lc_messages',
    'lc_ctype',
    'cache_manager',
    'shutdown',
    'online',
    'shutdown_delay',
    'reserved',
    'overwrite',
    'sec_attach',
    'disable_wal',
    'connect_timeout',
    'dummy_packet_interval',
    'gbak_attach',
    'sql_role_name',
    'set_page_buffers',
    'working_directory',
    'sql_dialect',
    'set_db_readonly',
    'set_db_sql_dialect',
    'gfix_attach',
    'gstat_attach',
//IB2007
    'gbak_ods_version',
    'gbak_ods_minor_version',
    'set_group_commit',
    'gbak_validate',
    'client_interbase_var',
    'admin_option',
    'flush_interval',
    'instance_name',
    'old_overwrite',
    'archive_database',
    'archive_journals',
    'archive_sweep',
    'archive_dumps',
    'archive_recover',
    'recover_until',
    'force'
  );

function GetDPBShutParamValue(const ParamString:Ansistring):integer;
var i,j:integer;
    s:Ansistring;

function CurParamValue:integer;
begin
  Result:=-1;
  s:=LowerCase(s);
  case s[1] of
   '0'..'9':
        Result:=StrToInt(s);
   'a': if s='attachment' then
         Result:=isc_dpb_shut_attachment;
   'c': if s='cache' then
         Result:=isc_dpb_shut_cache;
   'f': if s='force' then
          Result:=isc_dpb_shut_force
        else
        if s='full' then
          Result:=isc_dpb_shut_full;

   'm': if s='mode_mask' then
          Result:=isc_dpb_shut_mode_mask
        else
        if s='multi' then
          Result:=isc_dpb_shut_multi;
   'n': if s='normal' then
         Result:=isc_dpb_shut_normal;

   's': if s='single' then
         Result:=isc_dpb_shut_single;

   't':if s='transaction' then
         Result:=isc_dpb_shut_transaction;

  end;
end;

begin
  Result:=0; j:=1;
  for i:=1 to Length(ParamString) do
  begin
    if ParamString[i] in[',',';'] then
    begin
      if (i-j>0) then
      begin
        SetLength(s,i-j);
        Move(ParamString[j],s[1],i-j);
        Result:=Result or  CurParamValue
      end;
      j:=i+1;
    end
  end;
  i:=Length(ParamString);
  if j<i then
  begin
     i:=Length(ParamString);
     SetLength(s,i-j+1);
     Move(ParamString[j],s[1],i-j+1);
     Result:=Result or  CurParamValue
  end;
end;

var
  DPBConstants    :TStringList;



procedure TFb25AttachmentParams.GenerateParams(AParams: TStringList; IsFireBird: Boolean);
var
  i : integer;
  j, DPBVal:integer;
  param_name, param_value: AnsiString;
  pval: Integer;

  procedure ApplyStrParam;
  begin
        DPB := DPB +
               AnsiChar(DPBVal) +
               AnsiChar(Length(param_value)) +
               param_value;
        Inc(FDPBLength, 2 + Length(param_value));
  end;
begin
  (*
   * The DPB is initially empty, with the exception that
   * the DPB version must be the first byte of the string.
   *)
  FDPBLength := 1;
  DPB := AnsiChar(isc_dpb_version1);
  (*
   * Iterate through the textual database parameters, constructing
   * a DPB on-the-fly.
   *)
  for i := 0 to AParams.Count - 1 do
  begin
    (*
     * Get the parameter's name and value from the list,
     * and make sure that the name is all lowercase with
     * no leading 'isc_dpb_' prefix
     *)
    AParams[i]:=Trim(AParams[i]);
    if AParams[i]='' then Continue;

    GetNameAndValue(AParams[i],param_name,param_value);
    DoLowerCase(param_name);

    if (Pos(DPBPrefix, param_name) = 1) then
       param_name:=FastCopy(param_name,Length(DPBPrefix)+1,MaxInt);
//      Delete(param_name, 1, Length(DPBPrefix));
    (*
     * We want to translate the parameter name to some integer
     * value. We do this by scanning through a list of known
     * database parameter names (DPBConstantNames, defined above).
     *)
//    if DPBConstants.Find(param_name,j) then
    j:= NonAnsiIndexOf(DPBConstants,param_name);
    if j>-1 then
      DPBVal :=Integer(DPBConstants.Objects[j])
    else
      DPBVal := 0;

    (*
     * A database parameter either contains a string value (case 1)
     * or an integer value (case 2)
     * or no value at all (case 3)
     * or an error needs to be generated (case else)
     *)
    case DPBVal of
      isc_dpb_user_name, isc_dpb_password, isc_dpb_password_enc,
      isc_dpb_sys_user_name, isc_dpb_license, isc_dpb_encrypt_key,
      isc_dpb_lc_messages, isc_dpb_lc_ctype,
      isc_dpb_sql_role_name,isc_dpb_sql_dialect,
      isc_dpb_old_file,isc_dpb_sys_encrypt_password:
      begin
        if DPBVal = isc_dpb_sql_dialect then
          param_value[1] := AnsiChar(Ord(param_value[1]) - 48);
        ApplyStrParam
      end;
      isc_dpb_instance_name:
      begin
      // or isc_dpb_trusted_role
       if not IsFirebird then
       begin
        //IB 2007
        ApplyStrParam;
       end
      end;
      isc_dpb_set_db_charset:
      begin
       // or isc_dpb_gbak_ods_version
        if IsFirebird then
        begin
        //FB2
          ApplyStrParam;
        end;
      end;


      isc_dpb_num_buffers, isc_dpb_dbkey_scope, isc_dpb_force_write,
      isc_dpb_no_reserve, isc_dpb_damaged, isc_dpb_verify,
      isc_dpb_dummy_packet_interval, isc_dpb_connect_timeout,
      isc_dpb_online_dump, isc_dpb_overwrite, isc_dpb_old_file_size,isc_dpb_shutdown_delay
      :
      begin
        DPB := DPB +AnsiChar(DPBVal) +#1+AnsiChar(StrToInt(param_value));
        Inc(FDPBLength, 3);
      end;
      isc_dpb_sweep:
      begin
        DPB := DPB +AnsiChar(DPBVal) +#1 +AnsiChar(isc_dpb_records);
        Inc(FDPBLength, 3);
      end;
      isc_dpb_sweep_interval:
      begin
        pval := StrToInt(param_value);
        DPB := DPB +AnsiChar(DPBVal) +#4 +
               PAnsiChar(@pval)[0] +
               PAnsiChar(@pval)[1] +
               PAnsiChar(@pval)[2] +
               PAnsiChar(@pval)[3];
        Inc(FDPBLength, 6);
      end;
      isc_dpb_activate_shadow, isc_dpb_delete_shadow, isc_dpb_begin_log,
      isc_dpb_quit_log:
      begin
        DPB := DPB +AnsiChar(DPBVal) +#1#0;
        Inc(FDPBLength, 3);
      end;

      isc_dpb_utf8_filename: // FB2
      begin
      // or isc_dpb_archive_database
        if IsFirebird then
        begin
         DPB := DPB + AnsiChar(DPBVal) + #0;
         Inc(FDPBLength, 2);
        end
      end;

      isc_dpb_no_db_triggers: // FB2
      begin
  // or isc_dpb_client_interbase_var
        if IsFirebird then
        begin
         DPB := DPB + AnsiChar(DPBVal) + #1#1;
         Inc(FDPBLength, 3);
        end
      end;

      //
      isc_dpb_no_garbage_collect,isc_dpb_garbage_collect:
      begin
        DPB := DPB + AnsiChar(DPBVal) + #1#1;
        Inc(FDPBLength, 3);
      end;
      isc_dpb_shutdown:
      begin
        if Length(param_value)=0 then
        begin
         DPB := DPB + AnsiChar(DPBVal) + #0;
         Inc(FDPBLength, 2);
        end
        else
        begin
         DPB := DPB + AnsiChar(DPBVal) + #1+
          Ansichar(GetDPBShutParamValue(param_value));
         Inc(FDPBLength, 3);
        end;
      end;
      isc_dpb_online:
      begin
        DPB := DPB + AnsiChar(DPBVal) +#0;
        Inc(FDPBLength, 2);
      end;
    else
      begin
      // TODO: Implement this
//        if (DPBVal > 0) and (DPBVal <= isc_dpb_last_dpb_constant) then
//          FIBError(feDPBConstantNotSupported,[DPBConstantNames[DPBVal]])
//        else
//          FIBError(feDPBConstantUnknown, [param_name]);
      end;
    end;
  end;

  FDPB := @DPB[1];
end;


{ TFb25Status }

function TFb25Status.GetStatusVector: TStatusVector;
begin
  Result := FStatusVector;
end;

function TFb25Provider.AttachDatabase(AStatus: TFbStatus; AFileName: string; AParams: TFbAttachmentParams):
    TFbAttachment;
var
  DPB: AnsiString;
  tr_handle: TISC_TR_HANDLE;
  db_handle: TISC_DB_HANDLE;
  FDBName: AnsiString;
  StatusVector: PISC_STATUS;
begin
  Result := nil;
  tr_handle := nil;
  db_handle := nil;
  FDBName := AFileName;
  StatusVector  := (AStatus as TFb25Status).StatusVector;
  ClientLibrary.isc_attach_database(StatusVector, Length(FDBName), PAnsiChar(FDBName), @db_handle,
    (AParams as TFb25AttachmentParams).FDPBLength, (AParams as TFb25AttachmentParams).FDPB);

  if not AStatus.HasErrors then
  begin
    Result := TFb25Attachment.Create(ClientLibrary, db_handle);
  end;
end;

constructor TFb25Provider.Create(AClientLibrary:IIBClientLibrary);
begin
  FClientLibrary := AClientLibrary;
end;

function TFb25Provider.CreateDatabase(AStatus: TFbStatus; AFileName: string; AParams: TFbAttachmentParams):
    TFbAttachment;
var
  tr_handle: TISC_TR_HANDLE;
  db_handle: TISC_DB_HANDLE;
begin
  Result := nil;
  tr_handle := nil;
  db_handle := nil;
  ClientLibrary.isc_dsql_execute_immediate((AStatus as TFb25Status).StatusVector, @db_handle, @tr_handle, 0,
     PAnsiChar('CREATE DATABASE ''' + AFileName + ''' ' //+AnsiString(DBParams.Text)
    ), 3, nil);  // TODO: AddDBParams and dialect

  if not AStatus.HasErrors then
  begin
    Result := TFb25Attachment.Create(ClientLibrary, db_handle);
  end;
end;

function TFb25Provider.GetAttachmentParams: TFbAttachmentParams;
begin
  Result := TFb25AttachmentParams.Create;
end;

function TFb25Provider.GetStatus: TFbStatus;
begin
  Result := TFb25Status.Create;
end;

function TFb25Provider.GetTransactionParams: TFbTransactionParams;
begin
  Result := TFb25TransactionParams.Create;
end;

function TFb25Status.HasErrors: boolean;
begin
  Result := ((FStatusVector[0] = 1) and (FStatusVector[1] > 0));
end;

function TFb25Status.StatusVector: PISC_STATUS;
begin
  Result := PISC_STATUS(@FStatusVector);
end;

{ TFb25ClientLibrary }

class function TFb25ClientLibrary.GetProvider(ALibraryName: string): TFb25Provider;
var
  XLibraryName: Ansistring;
  _ClientLibrary: IIBClientLibrary;
begin
  XLibraryName   := ALibraryName;
  _ClientLibrary := IB_Intf.GetClientLibrary(XLibraryName);


  if not Assigned(_ClientLibrary) then
    raise Exception.Create('Cannot load client library');

   Result := TFb25Provider.Create(_ClientLibrary);
end;


{ TFb25Attachment }

constructor TFb25Attachment.Create(AClientLibrary:IIBClientLibrary; AHandle: TISC_DB_HANDLE);
begin
  FClientLibrary := AClientLibrary;
  FHandle := AHandle;
end;

procedure TFb25Attachment.DetachDatabase(AFbStatus: TFbStatus);
begin
  FClientLibrary.isc_detach_database((AFbStatus as TFb25Status).StatusVector, @FHandle);
end;

procedure TFb25Attachment.DropDatabase(AFbStatus: TFbStatus);
begin
  FClientLibrary.isc_drop_database((AFbStatus as TFb25Status).StatusVector, @FHandle);
end;

function TFb25Attachment.GetAttachmentID: LongInt;
begin
  Result:= GetLongDBInfo(isc_info_attachment_id);
end;

function TFb25Attachment.GetLongDBInfo(DBInfoCommand: Integer): Long;
var Success:boolean;
begin
  Result := GetProtectLongDBInfo(DBInfoCommand,Success);
end;

function TFb25Attachment.GetProtectLongDBInfo(DBInfoCommand: Integer; var Success: boolean): Long;
var
  local_buffer: array[0..FIBLocalBufferLength - 1] of AnsiChar;
  length: Integer;
  _DBInfoCommand: AnsiChar;
begin
//  _DBInfoCommand := AnsiChar(DBInfoCommand);
//  FClientLibrary.isc_database_info(StatusVector, @FHandle, 1, @_DBInfoCommand,
//                         FIBLocalBufferLength, local_buffer);
//  Success:=local_buffer[0] = _DBInfoCommand;
//  length := FClientLibrary.isc_vax_integer(@local_buffer[1], 2);
//  Result := FClientLibrary.isc_vax_integer(@local_buffer[3], length);
end;

function TFb25Attachment.GetStringDBInfo(DBInfoCommand: Integer): string;
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  _DBInfoCommand: AnsiChar;
begin
//  _DBInfoCommand := AnsiChar(DBInfoCommand);
//  FClientLibrary.isc_database_info(StatusVector, @FHandle, 1, @_DBInfoCommand,
//                         FIBBigLocalBufferLength, local_buffer);
//  local_buffer[4 + Int(local_buffer[3])] := #0;
//  Result := PAnsiChar(@local_buffer[4]);
end;

procedure InitDPBConstantsList;
var i:integer;
begin
  DPBConstants:= TStringList.Create;
  with DPBConstants do
  begin
   Capacity:=isc_dpb_last_dpb_constant;
   for i:=1 to isc_dpb_last_dpb_constant do
    AddObject(DPBConstantNames[i],TObject(i));

   AddObject('no_db_triggers',TObject(isc_dpb_no_db_triggers));
   AddObject('set_db_charset',TObject(isc_dpb_set_db_charset));
   AddObject('utf8_filename',TObject(isc_dpb_utf8_filename));


  // Sorted:=true;
  end;
end;

initialization
  InitDPBConstantsList;

finalization
  FreeAndNil(DPBConstants);

end.
