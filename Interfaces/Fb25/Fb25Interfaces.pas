unit Fb25Interfaces;

interface
uses
 IB_Intf, FbInterfaces, IB_Externals, ibase;

type

  TStatusVector  = array[0..19] of ISC_STATUS;
  PStatusVector  = ^TStatusVector;

  IFb25Status = interface(IFbStatus)
    ['{0F8D53D3-50A0-44E6-868B-711B0E408B95}']
    function StatusVector: PISC_STATUS;
    function GetStatusVector: TStatusVector;
    function CheckStatus(ErrorCodes: array of LongInt): Boolean;
  end;

  IFb25AttachmentParams = interface(IFbAttachmentParams)
    ['{862E7904-42D5-453D-BE3F-CF9F97709F5A}']
    function GetDPBLength: Short;
    function GetDPB      : PAnsiChar;
  end;

  IFb25TransactionParams = interface(IFbTransactionParams)
    ['{62168520-A962-4C51-8C0A-45A12E5D0D37}']
    function GetTPBLength: Short;
    function GetTPB: PAnsiChar;
    function GetTPBString: AnsiString;
    function GetPTebArray: PISC_TEB_ARRAY;
    function GetPTeb: PISC_TEB;
  end;

  IFb25Transaction = interface(IFbTransaction)
    ['{B9A91911-39A0-40F2-846F-20C75C341BC6}']
    function GetHandle: TISC_TR_HANDLE;
    function GetPHandle: PISC_TR_HANDLE;
    property Handle: TISC_TR_HANDLE read GetHandle; // TODO: remove
  end;

  IFb25Statement = interface(IFbStatement)
    ['{3BD11C6F-84F2-4C01-AE74-E88B6D63485E}']
    function GetPHandle: PISC_STMT_HANDLE;
  end;

  IFb25Blob = interface(IFbBlob)
    ['{6FA9AAFB-CDB0-44E1-A51C-FE6423AA769D}']

  end;

  IFb25Array = interface(IFbArray)
    ['{3D3B6013-2829-4EA4-A4FE-5EF2A1988735}']

  end;

  IFb25MessageMetadata = interface(IFbMessageMetadata)
    ['{8CEDA8C7-D5BD-4A75-A54B-2023036F0891}']
    function GetPXSQLDA: PXSQLDA;
    procedure SetCount(ACount: Integer);
  end;

  IFb25Attachment = interface(IFbAttachment)
    ['{F1A24EAA-7377-49A0-83A0-D1C68AE64FF1}']
    function GetHandle: TISC_DB_HANDLE;
    property Handle: TISC_DB_HANDLE read GetHandle;
    function GetPHandle: PISC_DB_HANDLE;
  end;

  IFb25Provider = interface(IFbProvider)
  ['{41C4F376-FB0A-43BD-A866-57BEFBB379FE}']
    function GetClientLibrary: IIBClientLibrary;
    property ClientLibrary:IIBClientLibrary read GetClientLibrary;
  end;





implementation

end.
