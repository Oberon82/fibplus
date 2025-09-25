unit FbClasses;

interface

type

  TFbAttachmentParams = class(TObject)

  end;

  TFbAttachment = class(TObject)
  private
  public
    function GetInfo(AInfoCode: Integer): string; virtual; abstract;
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

  TFbStatus = class(TObject)

  end;

  TFbResultSet = class(TObject)

  end;

  TFbMessageMetadata = class(TObject)

  end;

  TFbProvider = class(TObject)
    function AttachDatabase(AFileName: string): TFbAttachment; virtual; abstract;
    function CreateDatabase(AFileName: string): TFbAttachment; virtual; abstract;
    function GetAttachmentParams: TFbAttachmentParams; virtual; abstract;
    function GetTransactionParams: TFbTransactionParams; virtual; abstract;
    function LibraryFilePath: string; virtual; abstract;

  end;

implementation

end.
