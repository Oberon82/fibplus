unit FbClasses;

interface
uses
  System.SysUtils, System.Classes;

type

  TFbAttachmentParams = class(TObject)
  private

  protected

  public
    procedure GenerateParams(AParams: TStringList; IsFireBird: Boolean); virtual; abstract;
  end;

  TFbStatus = class(TObject)
  public
    function HasErrors: boolean; virtual; abstract;
  end;

  TFbAttachment = class(TObject)
  private
  public
    procedure DropDatabase(AFbStatus: TFbStatus); virtual; abstract;
    procedure DetachDatabase(AFbStatus: TFbStatus); virtual; abstract;
    function GetAttachmentID(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetAllocation(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetBaseLevel(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetDBFileName(AStatus: TFbStatus): Ansistring; virtual; abstract;
    function GetDBSiteName(AStatus: TFbStatus): Ansistring; virtual; abstract;
    function GetIsRemoteConnect(AStatus: TFbStatus): boolean; virtual; abstract;
    function GetDBImplementationNo(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetDBImplementationClass(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetNoReserve(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetODSMinorVersion(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetODSMajorVersion(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetPageSize(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetVersion(AStatus: TFbStatus): string; virtual; abstract;
    function GetCurrentMemory(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetForcedWrites(AStatus: TFbStatus): LongInt;virtual; abstract;
    function GetMaxMemory(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetNumBuffers(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetSweepInterval(AStatus: TFbStatus): LongInt; virtual; abstract;
    procedure GetUserNames(AStatus: TFbStatus; AList: TStringList);virtual; abstract;

    function GetFetches(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetMarks(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetReads(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWrites(AStatus: TFbStatus): LongInt; virtual; abstract;
    procedure GetBackoutCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetDeleteCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetExpungeCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetInsertCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetPurgeCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetReadIdxCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetReadSeqCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    procedure GetUpdateCount(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    function GetAllModifications(AStatus: TFbStatus):integer; virtual; abstract;

    function GetLogFile(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetCurLogFileName(AStatus: TFbStatus): string; virtual; abstract;
    function GetCurLogPartitionOffset(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetNumWALBuffers(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALBufferSize(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALCheckpointLength(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALCurCheckpointInterval(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALPrvCheckpointFilename(AStatus: TFbStatus): string; virtual; abstract;
    function GetWALPrvCheckpointPartOffset(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALGroupCommitWaitUSecs(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALNumIO(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALAverageIOSize(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALNumCommits(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetWALAverageGroupCommitSize(AStatus: TFbStatus): LongInt; virtual; abstract;

    //Firebird Info
    procedure GetActiveTransactions(AStatus: TFbStatus; AList: TStringList); virtual; abstract;
    function GetOldestTransaction(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetOldestActive(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetOldestSnapshot(AStatus: TFbStatus): LongInt; virtual; abstract;
    function GetFBVersion(AStatus: TFbStatus): string; virtual; abstract;
    function GetAttachCharset(AStatus: TFbStatus): integer; virtual; abstract;

    function  GetDBSQLDialect(AStatus: TFbStatus):Word; virtual; abstract;
    function  GetReadOnly(AStatus: TFbStatus): LongInt; virtual; abstract;

  end;

  TFbTransactionParams = class(TObject)

  end;

  TFbTransaction = class(TObject)

  end;

  TFbStatement = class(TObject)

  end;

  TFbBlob = class(TObject)

  end;

  TFbArray = class(TObject)

  end;



  TFbResultSet = class(TObject)

  end;

  TFbMessageMetadata = class(TObject)

  end;

  TFbProvider = class(TObject)
    function AttachDatabase(AFbStatus: TFbStatus; AFileName: string; AParams: TFbAttachmentParams): TFbAttachment; virtual;
        abstract;
    function CreateDatabase(AFbStatus: TFbStatus; AFileName: string; AParams: TFbAttachmentParams): TFbAttachment; virtual;
        abstract;
    function GetAttachmentParams: TFbAttachmentParams; virtual; abstract;
    function GetTransactionParams: TFbTransactionParams; virtual; abstract;
    function GetStatus: TFbStatus; virtual; abstract;
    function LibraryFilePath: string; virtual; abstract;

  end;

  TFbError = class(Exception);

implementation

end.
