unit Fb25ResultSet;

interface
uses
  Fb25Interfaces, FbInterfaces, fib, IB_Externals, ibase, IB_Intf, System.Classes;

type

  TFb25ResultSet = class(TInterfacedObject, IFbResultSet)
  private
    FHandle: TISC_STMT_HANDLE;
    FAttachment: IFbAttachment;
    FStatus: IFb25Status;
    FProvider: IFb25Provider;
    FMessageMetadata: IFb25MessageMetadata;
  public
    constructor Create(AAttachment: IFb25Attachment; AHandle: TISC_STMT_HANDLE; AMessageMetadata: IFb25MessageMetadata);
    destructor Destroy; override;
    procedure Fetch(ASqlDialect: Integer);
  end;


implementation

constructor TFb25ResultSet.Create(AAttachment: IFb25Attachment; AHandle: TISC_STMT_HANDLE; AMessageMetadata:
    IFb25MessageMetadata);
begin
  FAttachment := AAttachment;
  FStatus := AAttachment.GetStatus as IFb25Status;
  FHandle := AHandle;
  FProvider := (FAttachment.Provider as IFb25Provider);
  FMessageMetadata := AMessageMetadata;
end;

{ TFb25ResultSet }

destructor TFb25ResultSet.Destroy;
begin
  FAttachment := nil;
  FStatus     := nil;
  FHandle     := nil;
  FProvider   := nil;
  inherited;
end;

procedure TFb25ResultSet.Fetch(ASqlDialect: Integer);
begin
  FProvider.ClientLibrary.isc_dsql_fetch(FStatus.StatusVector, @FHandle, ASqlDialect,
      FMessageMetadata.GetPXSQLDA);
end;

end.
