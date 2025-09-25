unit FibDatabaseTests;

interface

uses
  DUnitX.TestFramework,
  FIBDatabase, pFIBDatabase, pFIBQuery,
  System.SysUtils,
  System.Classes;

type
  [TestFixture]
  TFibDatabaseTests = class
  private

  public
    FFibDatabase: TpFibDatabase;
    FReadFibTransaction: TpFIBTransaction;
    FWriteFibTransaction: TpFIBTransaction;
    FReadQuery: TpFIBQuery;
    FWriteQuery: TpFIBQuery;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test01CreateAndDropDatabaseLegacy;
    [Test]
    procedure Test03ConnectToRemoteBase;
    [Test]
    procedure Test04StartAndCommitTransation;

    [Test]
    procedure Test05ReadData;
    //[Test]
    procedure Test01CreateAndDropDatabaseNewApi;
  end;

implementation

procedure TFibDatabaseTests.Setup;
begin
  FFibDatabase := TpFIBDatabase.Create(nil);
  FFibDatabase.SQLDialect := 3;
  FReadFibTransaction := TpFIBTransaction.Create(nil);
  FReadFibTransaction.DefaultDatabase := FFibDatabase;

  FWriteFibTransaction := TpFIBTransaction.Create(nil);
  FWriteFibTransaction.DefaultDatabase := FFibDatabase;

  FReadQuery := TpFIBQuery.Create(nil);
  FReadQuery.Transaction := FReadFibTransaction;
  FReadQuery.Database := FFibDatabase;
  FWriteQuery := TpFIBQuery.Create(nil);
  FWriteQuery.Transaction := FWriteFibTransaction;
  FWriteQuery.Database := FFibDatabase;
end;

procedure TFibDatabaseTests.TearDown;
begin
  FWriteQuery.Free;
  FReadQuery.Free;
  FReadFibTransaction.Free;
  FWriteFibTransaction.Free;
  FFibDatabase.Free;
end;

procedure TFibDatabaseTests.Test01CreateAndDropDatabaseLegacy;
begin
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'lobalbase.fdb';
  FFibDatabase.UseLegacyApi := True;

  if FileExists(FFibDatabase.DatabaseName) then
  begin
    DeleteFile(FFibDatabase.DatabaseName);
  end;

  FFibDatabase.CreateDatabase;
  Assert.IsTrue(FileExists(FFibDatabase.DatabaseName));

  FFibDatabase.Close;
  Assert.IsFalse(FFibDatabase.Connected);

  FFibDatabase.Open;
  Assert.IsTrue(FFibDatabase.Connected);

  FFibDatabase.DropDatabase;
  Assert.IsFalse(FileExists(FFibDatabase.DatabaseName));
end;

procedure TFibDatabaseTests.Test01CreateAndDropDatabaseNewApi;
begin
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'TestBase2.fdb';
  FFibDatabase.UseLegacyApi := False;

  if FileExists(FFibDatabase.DatabaseName) then
  begin
    DeleteFile(FFibDatabase.DatabaseName);
  end;

  FFibDatabase.CreateDatabase;
  Assert.IsTrue(FileExists(FFibDatabase.DatabaseName));

  FFibDatabase.Close;
  Assert.IsFalse(FFibDatabase.Connected);

  FFibDatabase.Open;
  Assert.IsTrue(FFibDatabase.Connected);

  FFibDatabase.DropDatabase;
  Assert.IsFalse(FileExists(FFibDatabase.DatabaseName));
end;

procedure TFibDatabaseTests.Test03ConnectToRemoteBase;
begin
  FFibDatabase.ConnectParams.UserName := 'sysdba';
  FFibDatabase.ConnectParams.Password := 'masterkey';
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'localhost:C:\Users\Sancho\Documents\Embarcadero\Studio\Projects\fibplus\Tests\Win32\Debug\testBase.fdb';
  FFibDatabase.UseLegacyApi := True;

  FFibDatabase.Open;
  Assert.IsTrue(FFibDatabase.Connected);

  FFibDatabase.Close;
  Assert.IsFalse(FFibDatabase.Connected);
end;

procedure TFibDatabaseTests.Test04StartAndCommitTransation;
begin
  FFibDatabase.ConnectParams.UserName := 'sysdba';
  FFibDatabase.ConnectParams.Password := 'masterkey';
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'localhost:C:\Users\Sancho\Documents\Embarcadero\Studio\Projects\fibplus\Tests\Win32\Debug\testBase.fdb';
  FFibDatabase.UseLegacyApi := True;

  FFibDatabase.Open;
  Assert.IsTrue(FFibDatabase.Connected);

  FReadFibTransaction.StartTransaction;
  Assert.IsTrue(FReadFibTransaction.Active);
  FReadFibTransaction.Commit;

  Assert.IsFalse(FReadFibTransaction.Active);

  FFibDatabase.Close;
  Assert.IsFalse(FFibDatabase.Connected);
end;

procedure TFibDatabaseTests.Test05ReadData;
begin
  FFibDatabase.ConnectParams.UserName := 'sysdba';
  FFibDatabase.ConnectParams.Password := 'masterkey';
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'localhost:C:\Users\Sancho\Documents\Embarcadero\Studio\Projects\fibplus\Tests\Win32\Debug\testBase.fdb';
  FFibDatabase.UseLegacyApi := True;

  FFibDatabase.Open;
  FWriteFibTransaction.StartTransaction;

  FWriteQuery.SQL.Text := 'INSERT INTO TESTTABLE (INTCOLUMN, BIGCOLUMN, BOOLCOLUMN, DECCOLUMN, CHARCOLUMN, BLOBCOLUMN) ' +
    ' VALUES (:INTCOLUMN, :BIGCOLUMN, :BOOLCOLUMN, :DECCOLUMN, :CHARCOLUMN, :BLOBCOLUMN)';
  FWriteQuery.Prepare;
  FWriteQuery.ParamByName('INTCOLUMN').Value := 3;
  FWriteQuery.ParamByName('BIGCOLUMN').Value := 64;
  FWriteQuery.ParamByName('BOOLCOLUMN').AsBoolean := True;
  FWriteQuery.ParamByName('DECCOLUMN').AsExtended := 3.14;
  FWriteQuery.ParamByName('CHARCOLUMN').AsString  := 'Koka';
  FWriteQuery.ParamByName('BLOBCOLUMN').AsString  := 'Mega long string';

  FWriteFibTransaction.Commit;

  FReadFibTransaction.StartTransaction;

  FReadQuery.SQL.Text := 'SELECT a.IDENTCOLUMN, a.INTCOLUMN, a.BIGCOLUMN, a.BOOLCOLUMN, a.DECCOLUMN, ' +
    ' a.CHARCOLUMN, a.BLOBCOLUMN ' +
    ' FROM TESTTABLE a' +
    ' WHERE'+
    ' a.IDENTCOLUMN = ''1''';

  FReadQuery.ExecQuery;


  Assert.AreEqual(1, FReadQuery.FieldByName('IDENTCOLUMN').AsInteger);
  Assert.AreEqual(3, FReadQuery.FieldByName('INTCOLUMN').AsInteger);
  Assert.AreEqual(64, FReadQuery.FieldByName('BIGCOLUMN').AsInteger);
  Assert.AreEqual(True, FReadQuery.FieldByName('BOOLCOLUMN').AsBoolean);
  Assert.AreEqual(3.14, FReadQuery.FieldByName('DECCOLUMN').AsExtended);
  Assert.AreEqual('Koka', FReadQuery.FieldByName('CHARCOLUMN').AsString);
  Assert.AreEqual('Mega long string', FReadQuery.FieldByName('BLOBCOLUMN').AsString);

  FFibDatabase.Close;
  Assert.IsFalse(FFibDatabase.Connected);
end;

initialization
  TDUnitX.RegisterTestFixture(TFibDatabaseTests);

end.
