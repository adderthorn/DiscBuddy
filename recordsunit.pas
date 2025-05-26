unit RecordsUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TVideoRecord = class(TObject)
  private
    FFileName, FFilePath: string;
    FIndex: integer;
    FAttr: longint;
    FSize: int64;
    FTime: TDateTime;
  public
    constructor Create(FileName, FilePath: string; Index: integer); virtual;
    function RenameRecord(NewName: string): boolean;
    property FileName: string read FFileName write FFileName;
    property FilePath: string read FFilePath write FFilePath;
    property Attr: longint read FAttr write FAttr;
    property Time: TDateTime read FTime write FTime;
    property Size: int64 read FSize write FSize;
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

const
  kInvalidChars: set of char = ['\', '/', ':', '*', '?', '"', '<', '>', '|'];

implementation

constructor TVideoRecord.Create(FileName, FilePath: string; Index: integer);
begin
  Self.FileName:=FileName;
  Self.FilePath:=FilePath;
  Self.Index:=Index;
end;

function TVideoRecord.RenameRecord(NewName: string): boolean;
var
  FullPath, NewFullName: string;
begin
  FullPath:=ConcatPaths([FilePath, FileName]);
  NewFullName:=ConcatPaths([FilePath, NewName]);
  Result:=RenameFile(FullPath, NewFullName);
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

