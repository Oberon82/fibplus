unit Fb25Classes;

interface
uses
  FbClasses,
  IB_Intf,
  System.SysUtils;

type


  TFb25Provider = class(TFbProvider)
  private
    FClientLibrary:IIBClientLibrary;
  public
    constructor Create(AClientLibrary:IIBClientLibrary);
    property ClientLibrary:IIBClientLibrary read FClientLibrary;
  end;

  TFb25ClientLibrary = class(TObject)
    class function GetProvider(ALibraryName: string): TFb25Provider;
  end;

implementation

constructor TFb25Provider.Create(AClientLibrary:IIBClientLibrary);
begin
  FClientLibrary := AClientLibrary;
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



end.
