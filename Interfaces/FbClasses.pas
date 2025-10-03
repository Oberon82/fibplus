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
    function GetAttachmentID: LongInt; virtual; abstract;
    procedure DropDatabase(AFbStatus: TFbStatus); virtual; abstract;
    procedure DetachDatabase(AFbStatus: TFbStatus); virtual; abstract;
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
