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
    procedure Test05ReadAndWriteData;

    [Test]
    procedure TestDbInfo();
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

procedure TFibDatabaseTests.Test05ReadAndWriteData;
begin
  FFibDatabase.ConnectParams.UserName := 'sysdba';
  FFibDatabase.ConnectParams.Password := 'masterkey';
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'localhost:C:\Users\Sancho\Documents\Embarcadero\Studio\Projects\fibplus\Tests\Win32\Debug\testBase.fdb';

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
  FWriteQuery.ExecQuery;

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

procedure TFibDatabaseTests.TestDbInfo;
begin
  FFibDatabase.ConnectParams.UserName := 'sysdba';
  FFibDatabase.ConnectParams.Password := 'masterkey';
  FFibDatabase.LibraryName  := 'fbclient.dll';
  FFibDatabase.DatabaseName := 'localhost:C:\Users\Sancho\Documents\Embarcadero\Studio\Projects\fibplus\Tests\Win32\Debug\testBase.fdb';

  FFibDatabase.Open;

  Assert.AreNotEqual(0, FFibDatabase.AttachmentID);
  Assert.AreNotEqual(0, FFibDatabase.Allocation);
  Assert.AreNotEqual(0, FFibDatabase.BaseLevel);
  Assert.AreEqual(Ansistring('C:\Users\Sancho\Documents\Embarcadero\Studio\Projects\fibplus\Tests\Win32\Debug\testBase.fdb'), FFibDatabase.DBFileName, true);
  Assert.AreEqual(Ansistring('sanchopc'), FFibDatabase.DBSiteName, true);
  Assert.AreEqual(True, FFibDatabase.IsRemoteConnect);
  Assert.AreNotEqual(0, FFibDatabase.DBImplementationNo);
  Assert.AreNotEqual(0, FFibDatabase.DBImplementationClass);
  Assert.AreEqual(0, FFibDatabase.NoReserve);
  Assert.AreEqual(1, FFibDatabase.ODSMinorVersion);
  Assert.AreEqual(13, FFibDatabase.ODSMajorVersion);
  Assert.AreNotEqual(0, FFibDatabase.PageSize);
  Assert.AreEqual(AnsiString('WI-V6.3.3.1683 Firebird 5.0'), FFibDatabase.Version);
  Assert.AreEqual(AnsiString('WI-V5.0.3.1683 Firebird 5.0'), FFibDatabase.FBVersion);
  Assert.AreEqual(0, FFibDatabase.FBAttachCharsetID);
  Assert.AreEqual(5, FFibDatabase.ServerMajorVersion);
  Assert.AreEqual(0, FFibDatabase.ServerMinorVersion);
  Assert.AreNotEqual(0, FFibDatabase.ServerBuild);
  Assert.AreNotEqual(0, FFibDatabase.ServerRelease);
  Assert.AreNotEqual(0, FFibDatabase.CurrentMemory);
  Assert.AreNotEqual(0, FFibDatabase.ForcedWrites);
  Assert.AreNotEqual(0, FFibDatabase.MaxMemory);
  Assert.AreNotEqual(0, FFibDatabase.NumBuffers);
  Assert.AreNotEqual(0, FFibDatabase.SweepInterval);
  Assert.AreNotEqual(0, FFibDatabase.UserNames.Count);


  Assert.AreNotEqual(0, FFibDatabase.Fetches);
  Assert.AreNotEqual(0, FFibDatabase.Marks);
  Assert.AreNotEqual(0, FFibDatabase.Reads);
  Assert.AreNotEqual(0, FFibDatabase.Writes);

  Assert.AreNotEqual(1, FFibDatabase.BackoutCount.Count);
  Assert.AreNotEqual(1, FFibDatabase.DeleteCount.Count);
  Assert.AreNotEqual(1, FFibDatabase.ExpungeCount.Count);
  Assert.AreNotEqual(1, FFibDatabase.InsertCount.Count);
  Assert.AreNotEqual(1, FFibDatabase.PurgeCount.Count);
  Assert.AreNotEqual(0, FFibDatabase.ReadIdxCount.Count);
  Assert.AreNotEqual(0, FFibDatabase.ReadSeqCount.Count);
  Assert.AreNotEqual(1, FFibDatabase.UpdateCount.Count);
  Assert.AreNotEqual(1, FFibDatabase.PurgeCount.Count);

  Assert.AreNotEqual(2, FFibDatabase.AllModifications);

  Assert.AreNotEqual(1, FFibDatabase.LogFile);
  Assert.AreEqual(AnsiString(''), FFibDatabase.CurLogFileName);
  Assert.AreNotEqual(1, FFibDatabase.CurLogPartitionOffset);
  Assert.AreNotEqual(1, FFibDatabase.NumWALBuffers);
  Assert.AreNotEqual(1, FFibDatabase.WALBufferSize);

  Assert.AreNotEqual(1, FFibDatabase.WALCheckpointLength);
  Assert.AreNotEqual(1, FFibDatabase.WALCurCheckpointInterval);
  Assert.AreEqual(AnsiString(''), FFibDatabase.WALPrvCheckpointFilename);
  Assert.AreNotEqual(1, FFibDatabase.WALPrvCheckpointPartOffset);
  Assert.AreNotEqual(1, FFibDatabase.WALGroupCommitWaitUSecs);

  Assert.AreNotEqual(1, FFibDatabase.WALNumIO);
  Assert.AreNotEqual(1, FFibDatabase.WALAverageIOSize);
  Assert.AreNotEqual(1, FFibDatabase.WALNumCommits);
  Assert.AreNotEqual(1, FFibDatabase.WALAverageGroupCommitSize);

  Assert.AreNotEqual(word(1), FFibDatabase.DBSQLDialect);
  Assert.AreNotEqual(1, FFibDatabase.ReadOnly);
  Assert.AreNotEqual(AnsiString(''), FFibDatabase.DatabaseName);

  Assert.AreNotEqual(Double(1), FFibDatabase.DifferenceTime);
  Assert.AreNotEqual(2, FFibDatabase.ServerActiveTransactions.Count);
  Assert.AreNotEqual(0, FFibDatabase.OldestTransactionID);
  Assert.AreNotEqual(0, FFibDatabase.OldestActiveTransactionID);
end;

initialization
  TDUnitX.RegisterTestFixture(TFibDatabaseTests);

end.

