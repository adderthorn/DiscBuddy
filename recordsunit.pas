unit RecordsUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TVideoRecord = class(TObject)
  private
    FFileName: string;
    FFilePath: string;
    FIndex: integer;
  public
    constructor Create(FileName, FilePath: string; Index: integer); virtual;
    procedure RenameRecord(NewName: string);
    property FileName: string read FFileName write FFileName;
    property FilePath: string read FFilePath write FFilePath;
    property Index: integer read FIndex write FIndex;
  end;

type

  PVideoRecord=^TVideoRecord;

  TVideoRecords = class(TFPList)
  private
    function Get(Index: integer): TVideoRecord;
  public
    destructor Destroy; override;
    function Add(AVideoRecord: TVideoRecord): integer;
    function FindFileName(const FileName: string): TVideoRecord;
    property Items[Index: integer]: TVideoRecord read Get; default;
  end;

implementation

constructor TVideoRecord.Create(FileName, FilePath: string; Index: integer);
begin
  Self.FileName:=FileName;
  Self.FilePath:=FilePath;
  Self.Index:=Index;
end;

procedure TVideoRecord.RenameRecord(NewName: string);
var
  FullPath, NewFullName: string;
begin
  FullPath:=ConcatPaths([FilePath, FileName]);
  NewFullName:=ConcatPaths([FilePath, NewName]);
  RenameFile(FullPath, NewFullName);
end;

function TVideoRecords.Get(Index: integer): TVideoRecord;
begin
  Result:=TVideoRecord(inherited Get(Index));
end;

function TVideoRecords.Add(AVideoRecord: TVideoRecord): integer;
begin
  Result:=inherited Add(AVideoRecord);
end;

function TVideoRecords.FindFileName(const FileName: string): TVideoRecord;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to Count - 1 do
    if Items[i].FileName = FileName then exit(Items[i]);
end;

destructor TVideoRecords.Destroy;
var
  i: integer;
begin
  for i:=Count - 1 downto 0 do
  begin
    Items[i].Free;
  end;
  inherited Destroy;
end;

end.

