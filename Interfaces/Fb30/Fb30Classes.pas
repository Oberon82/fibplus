unit Fb30Classes;

interface
uses
  FbInterfaces;

type


  TFb30Provider = class(TInterfacedObject, IFbProvider)
  private

  public
    function AttachDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams): IFbAttachment;
    function CreateDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams): IFbAttachment;
    function GetAttachmentParams: IFbAttachmentParams;
    function GetTransactionParams: IFbTransactionParams;
    function GetStatus: IFbStatus;
    function GetLibraryFilePath: string;
    function GetProvider: IFbProvider;
  end;


  TFb30ClientLibrary = class(TObject)
  private

  public
    class function GetProvider(ALibraryName: string): TFb30Provider;
  end;

implementation

{ TFb30ClientLibrary }

class function TFb30ClientLibrary.GetProvider(ALibraryName: string): TFb30Provider;
begin

end;

{ TFb30Provider }

function TFb30Provider.AttachDatabase(AStatus: IFbStatus; AFileName: string;
  AParams: IFbAttachmentParams): IFbAttachment;
begin

end;

function TFb30Provider.CreateDatabase(AStatus: IFbStatus; AFileName: string;
  AParams: IFbAttachmentParams): IFbAttachment;
begin

end;

function TFb30Provider.GetAttachmentParams: IFbAttachmentParams;
begin

end;

function TFb30Provider.GetLibraryFilePath: string;
begin

end;

function TFb30Provider.GetProvider: IFbProvider;
begin

end;

function TFb30Provider.GetStatus: IFbStatus;
begin

end;

function TFb30Provider.GetTransactionParams: IFbTransactionParams;
begin

end;

end.
