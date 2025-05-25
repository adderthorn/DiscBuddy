unit DiscInfoUnit;

interface

uses SysUtils, Classes, fpJSON;

type

  TTitlesItemItemChapters = array of boolean;

function CreateTTitlesItemItemChapters(AJSON: TJSONData): TTitlesItemItemChapters;


type


  { -----------------------------------------------------------------------
    TTitlesItemItem
    -----------------------------------------------------------------------}

  TTitlesItemItem = class(TObject)
  private
    FTitle: string;
    F_Type: string;
    FChapters: TTitlesItemItemChapters;
    FSeason: string;
    FEpisode: string;
  public
    constructor CreateFromJSON(AJSON: TJSONData); virtual;
    procedure LoadFromJSON(AJSON: TJSONData); virtual;
    property Title: string read FTitle write FTitle;
    property _Type: string read F_Type write F_Type;
    property Chapters: TTitlesItemItemChapters read FChapters write FChapters;
    property Season: string read FSeason write FSeason;
    property Episode: string read FEpisode write FEpisode;
  end;


  { -----------------------------------------------------------------------
    TTitlesItemTracksItem
    -----------------------------------------------------------------------}

  TTitlesItemTracksItem = class(TObject)
  private
    FIndex: integer;
    FName: string;
    F_Type: string;
    FResolution: string;
    FAspectRatio: string;
  public
    constructor CreateFromJSON(AJSON: TJSONData); virtual;
    procedure LoadFromJSON(AJSON: TJSONData); virtual;
    property Index: integer read FIndex write FIndex;
    property Name: string read FName write FName;
    property _Type: string read F_Type write F_Type;
    property Resolution: string read FResolution write FResolution;
    property AspectRatio: string read FAspectRatio write FAspectRatio;
  end;

  TTitlesItemTracks = array of TTitlesItemTracksItem;

procedure ClearArray(var anArray: TTitlesItemTracks); overload;
function CreateTTitlesItemTracks(AJSON: TJSONData): TTitlesItemTracks;


type


  { -----------------------------------------------------------------------
    TTitlesItem
    -----------------------------------------------------------------------}

  TTitlesItem = class(TObject)
  private
    FIndex: integer;
    FComment: string;
    FSourceFile: string;
    FSegmentMap: string;
    FDuration: string;
    FSize: int64;
    FDisplaySize: string;
    FItem: TTitlesItemItem;
    FTracks: TTitlesItemTracks;
  public
    destructor Destroy; override;
    constructor CreateFromJSON(AJSON: TJSONData); virtual;
    procedure LoadFromJSON(AJSON: TJSONData); virtual;
    property Index: integer read FIndex write FIndex;
    property Comment: string read FComment write FComment;
    property SourceFile: string read FSourceFile write FSourceFile;
    property SegmentMap: string read FSegmentMap write FSegmentMap;
    property Duration: string read FDuration write FDuration;
    property Size: int64 read FSize write FSize;
    property DisplaySize: string read FDisplaySize write FDisplaySize;
    property Item: TTitlesItemItem read FItem write FItem;
    property Tracks: TTitlesItemTracks read FTracks write FTracks;
  end;

  TTitles = array of TTitlesItem;

procedure ClearArray(var anArray: TTitles); overload;
function CreateTTitles(AJSON: TJSONData): TTitles;


type


  { -----------------------------------------------------------------------
    TDiscInfo
    -----------------------------------------------------------------------}

  TDiscInfo = class(TObject)
  private
    FIndex: integer;
    FName: string;
    FFormat: string;
    FContentHash: string;
    FTitles: TTitles;
  public
    destructor Destroy; override;
    constructor CreateFromJSON(AJSON: TJSONData); virtual;
    procedure LoadFromJSON(AJSON: TJSONData); virtual;
    function GetTitleItem(Index: integer): TTitlesItem;
    property Index: integer read FIndex write FIndex;
    property Name: string read FName write FName;
    property Format: string read FFormat write FFormat;
    property ContentHash: string read FContentHash write FContentHash;
    property Titles: TTitles read FTitles write FTitles;
  end;

implementation




function CreateTTitlesItemItemChapters(AJSON: TJSONData): TTitlesItemItemChapters;
var
  I: integer;
begin
  SetLength(Result, AJSON.Count);
  for I := 0 to AJSON.Count - 1 do
    //Result[i]:=AJSON.Items[i].AsBoolean;
    Result[i] := False;
end;



{ -----------------------------------------------------------------------
  TTitlesItemItem
  -----------------------------------------------------------------------}


constructor TTitlesItemItem.CreateFromJSON(AJSON: TJSONData);
begin
  Create();
  LoadFromJSON(AJSON);
end;

procedure TTitlesItemItem.LoadFromJSON(AJSON: TJSONData);
var
  E: TJSONEnum;
begin
  for E in AJSON do
  begin
    case E.Key of
      'Title':
        Title := E.Value.AsString;
      'Type':
        _Type := E.Value.AsString;
      'Chapters':
        Chapters := CreateTTitlesItemItemChapters(E.Value);
      'Season':
        Season := E.Value.AsString;
      'Episode':
        Episode := E.Value.AsString;
    end;
  end;
end;


{ -----------------------------------------------------------------------
  TTitlesItemTracksItem
  -----------------------------------------------------------------------}


constructor TTitlesItemTracksItem.CreateFromJSON(AJSON: TJSONData);
begin
  Create();
  LoadFromJSON(AJSON);
end;

procedure TTitlesItemTracksItem.LoadFromJSON(AJSON: TJSONData);
var
  E: TJSONEnum;
begin
  for E in AJSON do
  begin
    case E.Key of
      'Index':
        Index := E.Value.AsInteger;
      'Name':
        Name := E.Value.AsString;
      'Type':
        _Type := E.Value.AsString;
      'Resolution':
        Resolution := E.Value.AsString;
      'AspectRatio':
      //AspectRatio:=E.Value.AsString;
    end;
  end;
end;


procedure ClearArray(var anArray: TTitlesItemTracks);
var
  I: integer;
begin
  for I := 0 to Length(anArray) - 1 do
    FreeAndNil(anArray[I]);
  SetLength(anArray, 0);
end;


function CreateTTitlesItemTracks(AJSON: TJSONData): TTitlesItemTracks;
var
  I: integer;
begin
  SetLength(Result, AJSON.Count);
  for I := 0 to AJSON.Count - 1 do
    Result[i] := TTitlesItemTracksItem.CreateFromJSON(AJSON.Items[i]);
end;



{ -----------------------------------------------------------------------
  TTitlesItem
  -----------------------------------------------------------------------}

destructor TTitlesItem.Destroy;
begin
  FreeAndNil(FItem);
  ClearArray(FTracks);
  inherited;
end;


constructor TTitlesItem.CreateFromJSON(AJSON: TJSONData);
begin
  Create();
  LoadFromJSON(AJSON);
end;

procedure TTitlesItem.LoadFromJSON(AJSON: TJSONData);
var
  E: TJSONEnum;
begin
  for E in AJSON do
  begin
    case E.Key of
      'Index':
        Index := E.Value.AsInteger;
      'Comment':
        Comment := E.Value.AsString;
      'SourceFile':
        SourceFile := E.Value.AsString;
      'SegmentMap':
        SegmentMap := E.Value.AsString;
      'Duration':
        Duration := E.Value.AsString;
      'Size':
        Size := E.Value.AsInt64;
      'DisplaySize':
        DisplaySize := E.Value.AsString;
      'Item':
        Item := TTitlesItemItem.CreateFromJSON(E.Value);
      'Tracks':
        Tracks := CreateTTitlesItemTracks(E.Value);
    end;
  end;
end;


procedure ClearArray(var anArray: TTitles);
var
  I: integer;
begin
  for I := 0 to Length(anArray) - 1 do
    FreeAndNil(anArray[I]);
  SetLength(anArray, 0);
end;


function CreateTTitles(AJSON: TJSONData): TTitles;
var
  I: integer;
begin
  SetLength(Result, AJSON.Count);
  for I := 0 to AJSON.Count - 1 do
    Result[i] := TTitlesItem.CreateFromJSON(AJSON.Items[i]);
end;



{ -----------------------------------------------------------------------
  TDiscInfo
  -----------------------------------------------------------------------}

destructor TDiscInfo.Destroy;
begin
  ClearArray(FTitles);
  inherited;
end;


constructor TDiscInfo.CreateFromJSON(AJSON: TJSONData);
begin
  Create();
  LoadFromJSON(AJSON);
end;

procedure TDiscInfo.LoadFromJSON(AJSON: TJSONData);
var
  E: TJSONEnum;
begin
  for E in AJSON do
  begin
    case E.Key of
      'Index':
        Index := E.Value.AsInteger;
      'Name':
        Name := E.Value.AsString;
      'Format':
        Format := E.Value.AsString;
      'ContentHash':
        ContentHash := E.Value.AsString;
      'Titles':
        Titles := CreateTTitles(E.Value);
    end;
  end;
end;

function TDiscInfo.GetTitleItem(Index: integer): TTitlesItem;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to Length(Titles) - 1 do
    if Titles[i].Index = Index then Exit(Titles[i]);
end;

end.
