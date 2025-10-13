unit FbClientApi;

interface
uses
  FbInterfaces;

type

  TFbClientApi = class(TObject)
  private

  public
    class function GetProvider(ALibraryName: string; UseLegacyApi: Boolean): IFbProvider;
  end;

implementation
uses
  Fb30Classes, Fb25Provider;

{ TFbClientApi }

class function TFbClientApi.GetProvider(ALibraryName: string; UseLegacyApi: Boolean): IFbProvider;
begin
  if UseLegacyApi then
    Result := TFb25ClientLibrary.GetProvider(ALibraryName)
  else
    Result := TFb30ClientLibrary.GetProvider(ALibraryName);
end;

end.
