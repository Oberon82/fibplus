unit Fb25Provider;

interface
uses
  FbInterfaces, IB_Intf, IB_Externals, Fb25Interfaces, ibase, Fb25Attachment, Fb25Transaction, System.SysUtils;

type

  TFb25Status = class(TInterfacedObject, IFbStatus)
  protected
    function StatusVector: PISC_STATUS;
    function GetStatusVector: TStatusVector;
    function CheckStatus(ErrorCodes: array of LongInt): Boolean;
    function GetStatus: Integer;
  public
    function HasErrors: boolean;
  end;

  TFb25Provider = class(TInterfacedObject, IFb25Provider)
  private
    FClientLibrary:IIBClientLibrary;
  protected
  public
    constructor Create(AClientLibrary:IIBClientLibrary);
    function AttachDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams): IFbAttachment;
    function CreateDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams): IFbAttachment;
    function GetAttachmentParams: IFbAttachmentParams;
    function GetTransactionParams: IFbTransactionParams;
    function GetStatus: IFbStatus;
    function GetLibraryFilePath: string;
    function GetClientLibrary: IIBClientLibrary;
  end;

  TFb25ClientLibrary = class
    class function GetProvider(ALibraryName: string): IFbProvider;
  end;


implementation
threadvar
  FStatusVector : TStatusVector;   // TODO: Remove in FIB

{ TFb25Status }

function TFb25Status.CheckStatus(ErrorCodes: array of LongInt): Boolean;
var
  p: PISC_STATUS;
  i: Integer;
  procedure NextP(i: Integer);
  begin
    p := PISC_STATUS(PAnsiChar(p) + (i * SizeOf(ISC_STATUS)));
  end;
begin
  p := StatusVector;
  Result := False;
  while (p^ <> 0) and (not Result) do
    case p^ of
      3: NextP(3);
      1, 4:
      begin
        NextP(1);
        i := 0;
        while (i <= High(ErrorCodes)) and (not Result) do
        begin
          Result := p^ = ErrorCodes[i];
          Inc(i);
        end;
        NextP(1);
      end;
    else
        NextP(2);
    end;
end;

function TFb25Status.GetStatus: Integer;
begin

end;

function TFb25Status.GetStatusVector: TStatusVector;
begin
  Result := FStatusVector;
end;

function TFb25Status.HasErrors: boolean;
begin
  Result := ((FStatusVector[0] = 1) and (FStatusVector[1] > 0));
end;

function TFb25Status.StatusVector: PISC_STATUS;
begin
  Result := PISC_STATUS(@FStatusVector);
end;

constructor TFb25Provider.Create(AClientLibrary:IIBClientLibrary);
begin
  FClientLibrary := AClientLibrary;
end;

function TFb25Provider.AttachDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams):
    IFbAttachment;
var
  db_handle: TISC_DB_HANDLE;
  FDBName: AnsiString;
  StatusVector: PISC_STATUS;
  tmpAttachment: IFb25Attachment;
begin
  Result := nil;
  db_handle := nil;
  FDBName := AFileName;
  StatusVector  := (AStatus as IFb25Status).StatusVector;
  FClientLibrary.isc_attach_database(StatusVector, Length(FDBName), PAnsiChar(FDBName), @db_handle,
    (AParams as IFb25AttachmentParams).GetDPBLength, (AParams as IFb25AttachmentParams).GetDPB);

  if not AStatus.HasErrors then
  begin
    tmpAttachment := TFb25Attachment.Create(Self as IFbProvider, db_handle) as IFb25Attachment;
    Result := tmpAttachment;
  end;
end;

function TFb25Provider.CreateDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams):
    IFbAttachment;
var
  tr_handle: TISC_TR_HANDLE;
  db_handle: TISC_DB_HANDLE;
begin
  Result := nil;
  tr_handle := nil;
  db_handle := nil;
  FClientLibrary.isc_dsql_execute_immediate((AStatus as IFb25Status).StatusVector, @db_handle, @tr_handle, 0,
     PAnsiChar('CREATE DATABASE ''' + AFileName + ''' ' //+AnsiString(DBParams.Text) //TODO: use dbParams
    ), 3, nil);  // TODO: AddDBParams and dialect

  if not AStatus.HasErrors then
  begin
    Result := TFb25Attachment.Create(Self as IFbProvider, db_handle) as IFbAttachment;
  end;
end;

function TFb25Provider.GetAttachmentParams: IFbAttachmentParams;
begin
  Result := TFb25AttachmentParams.Create as IFbAttachmentParams;
end;

function TFb25Provider.GetClientLibrary: IIBClientLibrary;
begin
  Result := FClientLibrary;
end;

function TFb25Provider.GetLibraryFilePath: string;
begin
  Result := FClientLibrary.LibraryFilePath;
end;

function TFb25Provider.GetStatus: IFbStatus;
begin
  Result := TFb25Status.Create as IFbStatus;
end;

function TFb25Provider.GetTransactionParams: IFbTransactionParams;
begin
  Result := TFb25TransactionParams.Create as IFbTransactionParams;
end;


{ TFb25ClientLibrary }

class function TFb25ClientLibrary.GetProvider(ALibraryName: string): IFbProvider;
var
  XLibraryName: Ansistring;
  _ClientLibrary: IIBClientLibrary;
begin
  XLibraryName   := ALibraryName;
  _ClientLibrary := IB_Intf.GetClientLibrary(XLibraryName);


  if not Assigned(_ClientLibrary) then
    raise Exception.Create('Cannot load client library');

   Result := TFb25Provider.Create(_ClientLibrary) as IFbProvider;
end;


end.
