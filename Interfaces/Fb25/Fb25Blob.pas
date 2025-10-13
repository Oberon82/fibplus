unit Fb25Blob;

interface
uses
  Fb25Interfaces, FbInterfaces;

type

  TFb25Blob = class(TInterfacedObject, IFb25Blob)
  private
    FAttachment: IFbAttachment;
    FStatus    : IFbStatus;
  protected
    function GetAttachment: IFbAttachment;
    function GetStatus: IFbStatus;
  public
    constructor Create(AAttachment: IFbAttachment; AStatus: IFbStatus);
  end;

implementation

{ TFb25Blob }

constructor TFb25Blob.Create(AAttachment: IFbAttachment; AStatus: IFbStatus);
begin
  FAttachment := AAttachment;
  FStatus     := AStatus;
end;

function TFb25Blob.GetAttachment: IFbAttachment;
begin
  Result := FAttachment;
end;

function TFb25Blob.GetStatus: IFbStatus;
begin
  Result := FStatus;
end;

end.
