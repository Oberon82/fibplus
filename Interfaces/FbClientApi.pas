unit FbClientApi;

interface
uses
  FbClasses;

type

  TFbClientApi = class(TObject)
  private

  public
    class function GetProvider(ALibraryName: string; UseLegacyApi: Boolean): TFbProvider;
  end;

implementation
uses
  Fb30Classes, Fb25Classes;

{ TFbClientApi }

class function TFbClientApi.GetProvider(ALibraryName: string; UseLegacyApi: Boolean): TFbProvider;
begin
  if UseLegacyApi then
    Result := TFb25ClientLibrary.GetProvider(ALibraryName)
  else
    Result := TFb30ClientLibrary.GetProvider(ALibraryName);
end;

end.
