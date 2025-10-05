unit Fb25Statement;

interface

implementation
uses
  Fb25Interfaces;

type

  TFb25Statement = class(TInterfacedObject, IFb25Statement)

  end;

  TFb25Blob = class(TInterfacedObject, IFb25Blob)

  end;

  TFb25Array = class(TInterfacedObject, IFb25Array)

  end;

  TFb25ResultSet = class(TInterfacedObject, IFb25ResultSet)

  end;

  TFb25MessageMetadata = class(TInterfacedObject, IFb25MessageMetadata)

  end;

end.
