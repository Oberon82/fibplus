unit Fb30Classes;

interface
uses
  FbClasses;

type


  TFb30Provider = class(TFbProvider)
  private

  public

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

end.
