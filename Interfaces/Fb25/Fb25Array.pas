unit Fb25Array;

interface
uses
  Fb25Interfaces, FbInterfaces;

type

  TFb25Array = class(TInterfacedObject, IFb25Array)
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

{ TFb25Array }

constructor TFb25Array.Create(AAttachment: IFbAttachment; AStatus: IFbStatus);
begin
  FAttachment := AAttachment;
  FStatus     := AStatus;
end;

function TFb25Array.GetAttachment: IFbAttachment;
begin
  Result := FAttachment;
end;

function TFb25Array.GetStatus: IFbStatus;
begin
  Result := FStatus;
end;

end.
