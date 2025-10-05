unit Fb25Attachment;

interface
uses
  FbInterfaces, Fb25Interfaces, IB_Intf, IB_Externals, ibase, System.Classes;

type

  TFb25AttachmentParams = class(TInterfacedObject, IFb25AttachmentParams)
  private
    FDPB      : PAnsiChar;
    FDPBLength: Short;
    DPB: AnsiString;
  protected

  public
    procedure GenerateParams(AParams: TStrings; IsFireBird: Boolean);
    function GetDPBLength: Short;
    function GetDPB      : PAnsiChar;
  end;

  TFb25Attachment = class(TInterfacedObject, IFb25Attachment)
  private
    FClientLibrary:IIBClientLibrary;
    FHandle: TISC_DB_HANDLE;
    function GetProtectLongDBInfo(DBInfoCommand: Integer;var Success:boolean; AStatus: IFbStatus): Long;
    function GetStringDBInfo(DBInfoCommand: Integer; AStatus: IFbStatus): string;
    function GetLongDBInfo(DBInfoCommand: Integer; AStatus: IFbStatus): Long;
    function GetOperationCounts(DBInfoCommand: Integer; AStatus: IFbStatus; var FOperation: TStringList): TStringList;
  protected
    function GetHandle: TISC_DB_HANDLE;
    function GetPHandle: PISC_DB_HANDLE;
  public
    constructor Create(AClientLibrary:IIBClientLibrary; AHandle: TISC_DB_HANDLE);
    procedure DropDatabase(AFbStatus: IFbStatus);
    procedure DetachDatabase(AFbStatus: IFbStatus);
    function GetAttachmentID(AStatus: IFbStatus): LongInt;
    function GetAllocation(AStatus: IFbStatus): LongInt;
    function GetBaseLevel(AStatus: IFbStatus): LongInt;
    function GetDBFileName(AStatus: IFbStatus): Ansistring;
    function GetDBSiteName(AStatus: IFbStatus): Ansistring;
    function GetIsRemoteConnect(AStatus: IFbStatus): boolean;

    function GetDBImplementationNo(AStatus: IFbStatus): LongInt;
    function GetDBImplementationClass(AStatus: IFbStatus): LongInt;
    function GetNoReserve(AStatus: IFbStatus): LongInt;
    function GetODSMinorVersion(AStatus: IFbStatus): LongInt;
    function GetODSMajorVersion(AStatus: IFbStatus): LongInt;
    function GetPageSize(AStatus: IFbStatus): LongInt;
    function GetVersion(AStatus: IFbStatus): string;
    function GetCurrentMemory(AStatus: IFbStatus): LongInt;
    function GetForcedWrites(AStatus: IFbStatus): LongInt;
    function GetMaxMemory(AStatus: IFbStatus): LongInt;
    function GetNumBuffers(AStatus: IFbStatus): LongInt;
    function GetSweepInterval(AStatus: IFbStatus): LongInt;
    procedure GetUserNames(AStatus: IFbStatus; AList: TStringList);

    function GetFetches(AStatus: IFbStatus): LongInt;
    function GetMarks(AStatus: IFbStatus): LongInt;
    function GetReads(AStatus: IFbStatus): LongInt;
    function GetWrites(AStatus: IFbStatus): LongInt;
    procedure GetBackoutCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetDeleteCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetExpungeCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetInsertCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetPurgeCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetReadIdxCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetReadSeqCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetUpdateCount(AStatus: IFbStatus; AList: TStringList);

    function GetAllModifications(AStatus: IFbStatus):integer;

    function GetLogFile(AStatus: IFbStatus): LongInt;
    function GetCurLogFileName(AStatus: IFbStatus): string;
    function GetCurLogPartitionOffset(AStatus: IFbStatus): LongInt;
    function GetNumWALBuffers(AStatus: IFbStatus): LongInt;
    function GetWALBufferSize(AStatus: IFbStatus): LongInt;
    function GetWALCheckpointLength(AStatus: IFbStatus): LongInt;
    function GetWALCurCheckpointInterval(AStatus: IFbStatus): LongInt;
    function GetWALPrvCheckpointFilename(AStatus: IFbStatus): string;
    function GetWALPrvCheckpointPartOffset(AStatus: IFbStatus): LongInt;
    function GetWALGroupCommitWaitUSecs(AStatus: IFbStatus): LongInt;
    function GetWALNumIO(AStatus: IFbStatus): LongInt;
    function GetWALAverageIOSize(AStatus: IFbStatus): LongInt;
    function GetWALNumCommits(AStatus: IFbStatus): LongInt;
    function GetWALAverageGroupCommitSize(AStatus: IFbStatus): LongInt;

    //Firebird Info
    procedure GetActiveTransactions(AStatus: IFbStatus; AList: TStringList);
    function GetOldestTransaction(AStatus: IFbStatus): LongInt;
    function GetOldestActive(AStatus: IFbStatus): LongInt;
    function GetOldestSnapshot(AStatus: IFbStatus): LongInt;
    function GetFBVersion(AStatus: IFbStatus): string;
    function GetAttachCharset(AStatus: IFbStatus): integer;

    function GetDBSQLDialect(AStatus: IFbStatus): Word;
    function GetReadOnly(AStatus: IFbStatus): LongInt;

    function StartTransaction(AStatus: IFbStatus; AParams: IFbTransactionParams): IFbTransaction;
    function StartDistributedTransaction(AStatus: IFbStatus; AParams: IFbTransactionParams): IFbTransaction;
  end;

implementation
uses
  System.SysUtils, StrUtil, fib;

var
  DPBConstants    :TStringList;

const

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

procedure TFb25AttachmentParams.GenerateParams(AParams: TStrings; IsFireBird: Boolean);
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

function TFb25AttachmentParams.GetDPB: PAnsiChar;
begin
  Result := FDPB;
end;

function TFb25AttachmentParams.GetDPBLength: Short;
begin
  Result := FDPBLength;
end;

{ TFb25Attachment }

constructor TFb25Attachment.Create(AClientLibrary:IIBClientLibrary; AHandle: TISC_DB_HANDLE);
begin
  FClientLibrary := AClientLibrary;
  FHandle := AHandle;
end;

procedure TFb25Attachment.DetachDatabase(AFbStatus: IFbStatus);
begin
  FClientLibrary.isc_detach_database((AFbStatus as IFb25Status).StatusVector, @FHandle);
end;

procedure TFb25Attachment.DropDatabase(AFbStatus: IFbStatus);
begin
  FClientLibrary.isc_drop_database((AFbStatus as IFb25Status).StatusVector, @FHandle);
end;

procedure TFb25Attachment.GetActiveTransactions(AStatus: IFbStatus; AList: TStringList);
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
  i:integer;
  L:integer;
begin
  DBInfoCommand := AnsiChar(frb_info_active_transactions);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBLocalBufferLength, local_buffer);

  if not (AStatus.HasErrors) then
  begin
    i:=0;

    while local_buffer[i] = AnsiChar(frb_info_active_transactions) do
    begin
      Inc(i,3);
      L      := FClientLibrary.isc_vax_integer(@local_buffer[i], 4);
      AList.Add(IntToStr(L));
      Inc(i,4);
    end;
  end;
end;

function TFb25Attachment.GetAllModifications(AStatus: IFbStatus): integer;
var
  local_buffer: array[0..FIBHugeLocalBufferLength - 1] of AnsiChar;
  _DBInfoCommand: AnsiChar;
  i, qtd_tables: Integer;
  j:byte;
begin
  Result := 0;
  for j:=isc_info_insert_count to isc_info_delete_count do
  begin
    _DBInfoCommand:=AnsiChar(j);
    FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @_DBInfoCommand,
                           FIBHugeLocalBufferLength, local_buffer);

    if not (AStatus.HasErrors) then
    begin
      // 1. 1 byte specifying the item type requested (e.g., isc_info_insert_count).
      // 2. 2 bytes telling how many bytes compose the subsequent value pairs.
      // 3. A pair of values for each table in the database on wich the requested
      //    type of operation has occurred since the database was last attached.
      // Each pair consists of:
      // 1. 2 bytes specifying the table ID.
      // 2. 4 bytes listing the number of operations (e.g., inserts) done on that table.
      qtd_tables := trunc(FClientLibrary.isc_vax_integer(@local_buffer[1],2)/6);
      for i := 0 to qtd_tables - 1 do
      begin
        Inc(Result,FClientLibrary.isc_vax_integer(@local_buffer[5+(i*6)],4));
      end;
    end;
  end;
end;

function TFb25Attachment.GetAllocation(AStatus: IFbStatus): Long;
begin
  Result := GetLongDBInfo(isc_info_allocation, AStatus);
end;

function TFb25Attachment.GetAttachCharset(AStatus: IFbStatus): integer;
var
  Success:boolean ;
begin
 Result:=GetProtectLongDBInfo(frb_info_att_charset,Success, AStatus);
 if not Success then
  Result := -1
end;

function TFb25Attachment.GetAttachmentID(AStatus: IFbStatus): LongInt;
begin
  Result:= GetLongDBInfo(isc_info_attachment_id, AStatus);
end;

procedure TFb25Attachment.GetBackoutCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_backout_count, AStatus, AList);
end;

function TFb25Attachment.GetBaseLevel(AStatus: IFbStatus): LongInt;
var
  local_buffer: array[0..FIBLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_base_level);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                         FIBLocalBufferLength, local_buffer);
  if not (AStatus.HasErrors) then
    Result := FClientLibrary.isc_vax_integer(@local_buffer[4], 1);
end;

function TFb25Attachment.GetCurLogFileName(AStatus: IFbStatus): string;
begin
  Result := GetStringDBInfo(isc_info_cur_logfile_name, AStatus);
end;

function TFb25Attachment.GetCurLogPartitionOffset(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_cur_log_part_offset, AStatus);
end;

function TFb25Attachment.GetCurrentMemory(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_current_memory, AStatus);
end;

function TFb25Attachment.GetDBFileName(AStatus: IFbStatus): Ansistring;
var
  local_buffer: array[0..FIBLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_db_id);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                         FIBLocalBufferLength, local_buffer);
  if not (AStatus.HasErrors) then
  begin
    local_buffer[5 + Int(local_buffer[4])] := #0;
    Result := PAnsiChar(@local_buffer[5]);
  end;
end;

function TFb25Attachment.GetDBImplementationClass(AStatus: IFbStatus): LongInt;
var
  local_buffer: array[0..FIBLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_implementation);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                         FIBLocalBufferLength, local_buffer);

  if not (AStatus.HasErrors) then
  begin
  Result := FClientLibrary.isc_vax_integer(@local_buffer[4], 1);
  end;
end;

function TFb25Attachment.GetDBImplementationNo(AStatus: IFbStatus): LongInt;
var
  local_buffer: array[0..FIBLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_implementation);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBLocalBufferLength, local_buffer);
  if not (AStatus.HasErrors) then
  begin
    Result := FClientLibrary.isc_vax_integer(@local_buffer[3], 1);
  end;
end;

function TFb25Attachment.GetDBSiteName(AStatus: IFbStatus): Ansistring;
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  p: PAnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_db_id);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBLocalBufferLength, local_buffer);
  if not (AStatus.HasErrors) then
  begin
    p := @local_buffer[5 + Int(local_buffer[4])]; // DBSiteName Length
    p := p + Int(p^) + 1;                         // End of DBSiteName
    p^ := #0;                                     // Null it.
    Result := PAnsiChar(@local_buffer[6 + Int(local_buffer[4])]);
  end;
end;

function TFb25Attachment.GetDBSQLDialect(AStatus: IFbStatus): Word;
var Success:boolean;
begin
 Result:=GetProtectLongDBInfo(isc_info_db_SQL_dialect,Success, AStatus);
 if not Success then Result:=1
end;

procedure TFb25Attachment.GetDeleteCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_delete_count, AStatus, AList);
end;

procedure TFb25Attachment.GetExpungeCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_expunge_count, AStatus, AList);
end;

function TFb25Attachment.GetFBVersion(AStatus: IFbStatus): string;
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(frb_info_firebird_version);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBLocalBufferLength, local_buffer);

  if not (AStatus.HasErrors) then
  begin
    if DBInfoCommand=local_buffer[0] then
    begin
     local_buffer[5 + Int(local_buffer[4])] := #0;
     Result:= PAnsiChar(@local_buffer[5]);
    end
    else
     Result:= '';
  end;
end;

function TFb25Attachment.GetFetches(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_fetches, AStatus);
end;

function TFb25Attachment.GetForcedWrites(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_forced_writes, AStatus);
end;

function TFb25Attachment.GetHandle: TISC_DB_HANDLE;
begin
  Result := FHandle;
end;

procedure TFb25Attachment.GetInsertCount(AStatus: IFbStatus; AList: TStringList);
begin
  inherited;
  GetOperationCounts(isc_info_insert_count,AStatus, AList);
end;

function TFb25Attachment.GetIsRemoteConnect(AStatus: IFbStatus): boolean;
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_db_id);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBLocalBufferLength, local_buffer);
  if not (AStatus.HasErrors) then
  begin
    Result:=Int(local_buffer[3])=4;
  end;
end;

function TFb25Attachment.GetLogFile(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_logfile, AStatus);
end;

function TFb25Attachment.GetLongDBInfo(DBInfoCommand: Integer; AStatus: IFbStatus): Long;
var Success:boolean;
begin
  Result := GetProtectLongDBInfo(DBInfoCommand,Success, AStatus);
end;

function TFb25Attachment.GetMarks(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_marks, AStatus);
end;

function TFb25Attachment.GetMaxMemory(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_max_memory, AStatus);
end;

function TFb25Attachment.GetNoReserve(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_no_reserve, AStatus);
end;

function TFb25Attachment.GetNumBuffers(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_num_buffers, AStatus);
end;

function TFb25Attachment.GetNumWALBuffers(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_num_wal_buffers, AStatus);
end;

function TFb25Attachment.GetODSMajorVersion(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_ods_version, AStatus);
end;

function TFb25Attachment.GetODSMinorVersion(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_ods_minor_version, AStatus);
end;

function TFb25Attachment.GetOldestActive(AStatus: IFbStatus): LongInt;
var
  Success:boolean;
begin
 Result := GetProtectLongDBInfo(frb_info_oldest_active,Success, AStatus);
end;

function TFb25Attachment.GetOldestSnapshot(AStatus: IFbStatus): LongInt;
var
  Success:boolean;
begin
 Result:=GetProtectLongDBInfo(frb_info_oldest_snapshot,Success, AStatus);
end;

function TFb25Attachment.GetOldestTransaction(AStatus: IFbStatus): LongInt;
var
  Success:boolean;
begin
 Result:=GetProtectLongDBInfo(frb_info_oldest_transaction,Success, AStatus);
end;

function TFb25Attachment.GetOperationCounts(DBInfoCommand: Integer; AStatus: IFbStatus; var FOperation: TStringList):
    TStringList;
var
  local_buffer: array[0..FIBHugeLocalBufferLength - 1] of AnsiChar;
  _DBInfoCommand: AnsiChar;
  i, qtd_tables, id_table, qtd_operations: Integer;
begin
  if FOperation = nil then FOperation := TStringList.Create;
  Result := FOperation;
  _DBInfoCommand := AnsiChar(DBInfoCommand);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @_DBInfoCommand,
                         FIBHugeLocalBufferLength, local_buffer);

  if (not AStatus.HasErrors) then
  begin
    FOperation.Clear;
    // 1. 1 byte specifying the item type requested (e.g., isc_info_insert_count).
    // 2. 2 bytes telling how many bytes compose the subsequent value pairs.
    // 3. A pair of values for each table in the database on wich the requested
    //    type of operation has occurred since the database was last attached.
    // Each pair consists of:
    // 1. 2 bytes specifying the table ID.
    // 2. 4 bytes listing the number of operations (e.g., inserts) done on that table.
    qtd_tables := trunc(FClientLibrary.isc_vax_integer(@local_buffer[1],2)/6);
    for i := 0 to qtd_tables - 1 do
    begin
      id_table := FClientLibrary.isc_vax_integer(@local_buffer[3+(i*6)],2);
      qtd_operations := FClientLibrary.isc_vax_integer(@local_buffer[5+(i*6)],4);
      FOperation.Add(IntToStr(id_table)+'='+IntToStr(qtd_operations));
    end;
  end;
end;

function TFb25Attachment.GetPageSize(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_page_size, AStatus);
end;

function TFb25Attachment.GetPHandle: PISC_DB_HANDLE;
begin
  Result := @FHandle;
end;

function TFb25Attachment.GetProtectLongDBInfo(DBInfoCommand: Integer;var Success:boolean; AStatus: IFbStatus): Long;
var
  local_buffer: array[0..FIBLocalBufferLength - 1] of AnsiChar;
  length: Integer;
  _DBInfoCommand: AnsiChar;
begin
  _DBInfoCommand := AnsiChar(DBInfoCommand);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @_DBInfoCommand,
                         FIBLocalBufferLength, local_buffer);
  Success:=local_buffer[0] = _DBInfoCommand;
  length := FClientLibrary.isc_vax_integer(@local_buffer[1], 2);
  Result := FClientLibrary.isc_vax_integer(@local_buffer[3], length);
end;

procedure TFb25Attachment.GetPurgeCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_purge_count, AStatus, AList);
end;

procedure TFb25Attachment.GetReadIdxCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_read_idx_count, AStatus, AList);
end;

function TFb25Attachment.GetReadOnly(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_db_read_only, AStatus);
end;

function TFb25Attachment.GetReads(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_reads, AStatus);
end;

procedure TFb25Attachment.GetReadSeqCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_read_seq_count,AStatus, AList);
end;

function TFb25Attachment.GetStringDBInfo(DBInfoCommand: Integer; AStatus: IFbStatus): string;
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  _DBInfoCommand: AnsiChar;
begin
  _DBInfoCommand := AnsiChar(DBInfoCommand);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @_DBInfoCommand,
                         FIBBigLocalBufferLength, local_buffer);
  local_buffer[4 + Int(local_buffer[3])] := #0;
  Result := PAnsiChar(@local_buffer[4]);
end;

function TFb25Attachment.GetSweepInterval(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_sweep_interval, AStatus);
end;

procedure TFb25Attachment.GetUpdateCount(AStatus: IFbStatus; AList: TStringList);
begin
  GetOperationCounts(isc_info_update_count,AStatus, AList);
end;

procedure TFb25Attachment.GetUserNames(AStatus: IFbStatus; AList: TStringList);
var
  local_buffer: array[0..FIBHugeLocalBufferLength - 1] of AnsiChar;
  temp_buffer: array[0..FIBLocalBufferLength - 2] of AnsiChar;
  DBInfoCommand: AnsiChar;
  i, user_length: Integer;
begin
  DBInfoCommand := AnsiChar(isc_info_user_names);
  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBHugeLocalBufferLength, local_buffer);

  if not (AStatus.HasErrors) then
  begin
    AList.Clear;
    i := 0;
    while local_buffer[i] = AnsiChar(isc_info_user_names) do
    begin
      Inc(i, 3);
      // skip "isc_info_user_names byte" & two unknown bytes of structure (see below)
      user_length := Long(local_buffer[i]);
      Inc(i,1);
      Move(local_buffer[i], temp_buffer[0], user_length);
      Inc(i, user_length);
      temp_buffer[user_length] := #0;
      AList.Add(Ansistring(temp_buffer));
    end;
  end;
end;

function TFb25Attachment.GetVersion(AStatus: IFbStatus): string;
var
  local_buffer: array[0..FIBBigLocalBufferLength - 1] of AnsiChar;
  DBInfoCommand: AnsiChar;
begin
  DBInfoCommand := AnsiChar(isc_info_version);

  FClientLibrary.isc_database_info((AStatus as IFb25Status).StatusVector, @FHandle, 1, @DBInfoCommand,
                        FIBBigLocalBufferLength, local_buffer);
  if not (AStatus.HasErrors) then
  begin
    local_buffer[5 + Int(local_buffer[4])] := #0;
    Result := PAnsiChar(@local_buffer[5]);
  end;
end;

function TFb25Attachment.GetWALAverageGroupCommitSize(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_avg_grpc_size, AStatus);
end;

function TFb25Attachment.GetWALAverageIOSize(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_avg_io_size, AStatus);
end;

function TFb25Attachment.GetWALBufferSize(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_buffer_size, AStatus);
end;

function TFb25Attachment.GetWALCheckpointLength(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_ckpt_length, AStatus);
end;

function TFb25Attachment.GetWALCurCheckpointInterval(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_cur_ckpt_interval, AStatus);
end;

function TFb25Attachment.GetWALGroupCommitWaitUSecs(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_grpc_wait_usecs, AStatus);
end;

function TFb25Attachment.GetWALNumCommits(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_num_commits, AStatus);
end;

function TFb25Attachment.GetWALNumIO(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_num_io, AStatus);
end;

function TFb25Attachment.GetWALPrvCheckpointFilename(AStatus: IFbStatus): string;
begin
  Result := GetStringDBInfo(isc_info_wal_prv_ckpt_fname, AStatus);
end;

function TFb25Attachment.GetWALPrvCheckpointPartOffset(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_wal_prv_ckpt_poffset, AStatus);
end;

function TFb25Attachment.GetWrites(AStatus: IFbStatus): LongInt;
begin
  Result := GetLongDBInfo(isc_info_writes, AStatus);
end;

function TFb25Attachment.StartDistributedTransaction(AStatus: IFbStatus; AParams: IFbTransactionParams): IFbTransaction;
var
  StatusVector: PISC_STATUS;
begin
//  StatusVector  := (AStatus as IFb25Status).StatusVector;
//
//  if FClientLibrary.isc_start_multiple(StatusVector, @FHandle,
//                                     0, PISC_TEB(pteb)), False) > 0)
//
//
//  ClientLibrary.isc_attach_database(StatusVector, Length(FDBName), PAnsiChar(FDBName), @db_handle,
//    (AParams as TFb25AttachmentParams).FDPBLength, (AParams as TFb25AttachmentParams).FDPB);
//
//  if not AStatus.HasErrors then
//  begin
//    Result := TFb25Attachment.Create(ClientLibrary, db_handle);
//  end;
end;

function TFb25Attachment.StartTransaction(AStatus: IFbStatus; AParams: IFbTransactionParams): IFbTransaction;
begin

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
