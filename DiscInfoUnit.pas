unit DiscInfoUnit;

interface

uses SysUtils, Classes, fpJSON;


Type
  
  TTitlesItemItemChapters = Array of Boolean;

Function CreateTTitlesItemItemChapters(AJSON : TJSONData) : TTitlesItemItemChapters;


Type
  
  
  { -----------------------------------------------------------------------
    TTitlesItemItem
    -----------------------------------------------------------------------}
  
  TTitlesItemItem = class(TObject)
  Private
    FTitle : String;
    F_Type : String;
    FChapters : TTitlesItemItemChapters;
    FSeason : String;
    FEpisode : String;
  Public
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Property Title : String Read FTitle Write FTitle;
    Property _Type : String Read F_Type Write F_Type;
    Property Chapters : TTitlesItemItemChapters Read FChapters Write FChapters;
    Property Season : String Read FSeason Write FSeason;
    Property Episode : String Read FEpisode Write FEpisode;
  end;
  
  
  { -----------------------------------------------------------------------
    TTitlesItemTracksItem
    -----------------------------------------------------------------------}
  
  TTitlesItemTracksItem = class(TObject)
  Private
    FIndex : Integer;
    FName : String;
    F_Type : String;
    FResolution : String;
    FAspectRatio : String;
  Public
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Property Index : Integer Read FIndex Write FIndex;
    Property Name : String Read FName Write FName;
    Property _Type : String Read F_Type Write F_Type;
    Property Resolution : String Read FResolution Write FResolution;
    Property AspectRatio : String Read FAspectRatio Write FAspectRatio;
  end;
  
  TTitlesItemTracks = Array of TTitlesItemTracksItem;

Procedure ClearArray(var anArray : TTitlesItemTracks); overload;
Function CreateTTitlesItemTracks(AJSON : TJSONData) : TTitlesItemTracks;


Type
  
  
  { -----------------------------------------------------------------------
    TTitlesItem
    -----------------------------------------------------------------------}
  
  TTitlesItem = class(TObject)
  Private
    FIndex : Integer;
    FComment : String;
    FSourceFile : String;
    FSegmentMap : String;
    FDuration : String;
    FSize : Int64;
    FDisplaySize : String;
    FItem : TTitlesItemItem;
    FTracks : TTitlesItemTracks;
  Public
    Destructor Destroy; override;
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Property Index : Integer Read FIndex Write FIndex;
    Property Comment : String Read FComment Write FComment;
    Property SourceFile : String Read FSourceFile Write FSourceFile;
    Property SegmentMap : String Read FSegmentMap Write FSegmentMap;
    Property Duration : String Read FDuration Write FDuration;
    Property Size : Int64 Read FSize Write FSize;
    Property DisplaySize : String Read FDisplaySize Write FDisplaySize;
    Property Item : TTitlesItemItem Read FItem Write FItem;
    Property Tracks : TTitlesItemTracks Read FTracks Write FTracks;
  end;
  
  TTitles = Array of TTitlesItem;

Procedure ClearArray(var anArray : TTitles); overload;
Function CreateTTitles(AJSON : TJSONData) : TTitles;


Type
  
  
  { -----------------------------------------------------------------------
    TDiscInfo
    -----------------------------------------------------------------------}
  
  TDiscInfo = class(TObject)
  Private
    FIndex : Integer;
    FName : String;
    FFormat : String;
    FContentHash : String;
    FTitles : TTitles;
  Public
    Destructor Destroy; override;
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Property Index : Integer Read FIndex Write FIndex;
    Property Name : String Read FName Write FName;
    Property Format : String Read FFormat Write FFormat;
    Property ContentHash : String Read FContentHash Write FContentHash;
    Property Titles : TTitles Read FTitles Write FTitles;
  end;

implementation







Function CreateTTitlesItemItemChapters(AJSON : TJSONData) : TTitlesItemItemChapters;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=AJSON.Items[i].AsBoolean;
End;



{ -----------------------------------------------------------------------
  TTitlesItemItem
  -----------------------------------------------------------------------}


Constructor TTitlesItemItem.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TTitlesItemItem.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Title':
      Title:=E.Value.AsString;
    'Type':
      _Type:=E.Value.AsString;
    'Chapters':
      Chapters:=CreateTTitlesItemItemChapters(E.Value);
    'Season':
      Season:=E.Value.AsString;
    'Episode':
      Episode:=E.Value.AsString;
    end;
    end;
end;




{ -----------------------------------------------------------------------
  TTitlesItemTracksItem
  -----------------------------------------------------------------------}


Constructor TTitlesItemTracksItem.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TTitlesItemTracksItem.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Index':
      Index:=E.Value.AsInteger;
    'Name':
      Name:=E.Value.AsString;
    'Type':
      _Type:=E.Value.AsString;
    'Resolution':
      Resolution:=E.Value.AsString;
    'AspectRatio':
      //AspectRatio:=E.Value.AsString;
    end;
    end;
end;


Procedure ClearArray(Var anArray : TTitlesItemTracks);

var
  I : integer;

begin
  For I:=0 to Length(anArray)-1 do
    FreeAndNil(anArray[I]);
  SetLength(anArray,0);
End;


Function CreateTTitlesItemTracks(AJSON : TJSONData) : TTitlesItemTracks;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=TTitlesItemTracksItem.CreateFromJSON(AJSON.Items[i]);
End;



{ -----------------------------------------------------------------------
  TTitlesItem
  -----------------------------------------------------------------------}

Destructor TTitlesItem.Destroy;

begin
  FreeAndNil(FItem);
  ClearArray(FTracks);
  inherited;
end;


Constructor TTitlesItem.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TTitlesItem.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Index':
      Index:=E.Value.AsInteger;
    'Comment':
      Comment:=E.Value.AsString;
    'SourceFile':
      SourceFile:=E.Value.AsString;
    'SegmentMap':
      SegmentMap:=E.Value.AsString;
    'Duration':
      Duration:=E.Value.AsString;
    'Size':
      Size:=E.Value.AsInt64;
    'DisplaySize':
      DisplaySize:=E.Value.AsString;
    'Item':
      Item:=TTitlesItemItem.CreateFromJSON(E.Value);
    'Tracks':
      Tracks:=CreateTTitlesItemTracks(E.Value);
    end;
    end;
end;


Procedure ClearArray(Var anArray : TTitles);

var
  I : integer;

begin
  For I:=0 to Length(anArray)-1 do
    FreeAndNil(anArray[I]);
  SetLength(anArray,0);
End;


Function CreateTTitles(AJSON : TJSONData) : TTitles;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=TTitlesItem.CreateFromJSON(AJSON.Items[i]);
End;



{ -----------------------------------------------------------------------
  TDiscInfo
  -----------------------------------------------------------------------}

Destructor TDiscInfo.Destroy;

begin
  ClearArray(FTitles);
  inherited;
end;


Constructor TDiscInfo.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TDiscInfo.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Index':
      Index:=E.Value.AsInteger;
    'Name':
      Name:=E.Value.AsString;
    'Format':
      Format:=E.Value.AsString;
    'ContentHash':
      ContentHash:=E.Value.AsString;
    'Titles':
      Titles:=CreateTTitles(E.Value);
    end;
    end;
end;

end.
