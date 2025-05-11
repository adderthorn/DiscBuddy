unit UnitMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  Menus, Grids, StdActns, ExtCtrls, ComCtrls, EditBtn, fpjson, jsonparser,
  DiscInfoUnit, unitutilities;

type

  { TFormMain }

  TFormMain = class(TForm)
    DirectoryEditVideos: TDirectoryEdit;
    FileNameEditJson: TFileNameEdit;
    FileOpenPath: TAction;
    ActionViewAllTitles: TAction;
    ActionList: TActionList;
    FileExit: TFileExit;
    FileOpen: TFileOpen;
    ImageListMain: TImageList;
    EditInputMask: TLabeledEdit;
    LabeledEdit1: TLabeledEdit;
    LabelVideoPath: TLabel;
    LabelJsonFile: TLabel;
    MainMenu: TMainMenu;
    MenuItemOpenVideoPath: TMenuItem;
    MenuItemFileOpen: TMenuItem;
    MenuItemViewAllItems: TMenuItem;
    MenuItemView: TMenuItem;
    MenuItemFileExit: TMenuItem;
    MenuItemFile: TMenuItem;
    PageControlTop: TPageControl;
    PanelBottom: TPanel;
    SelectDirectoryDialogVideoPath: TSelectDirectoryDialog;
    StringGrid1: TStringGrid;
    TabControlGrids: TTabControl;
    TabSheetOpts: TTabSheet;
    TabSheetMain: TTabSheet;
    procedure ActionViewAllTitlesExecute(Sender: TObject);
    procedure FileNameEditJsonAcceptFileName(Sender: TObject; var Value: String
      );
    procedure FileOpenAccept(Sender: TObject);
    procedure FileOpenPathExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ParseJson(AllTitles: boolean);
    procedure ParseVideoPath(InputMask: string);
    procedure TabControlGridsChange(Sender: TObject);
  private
    FDiscInfo: TDiscInfo;
    FDiscFile: string;
    FVideoFolder: string;
    procedure ResetGrid(Headers: array of string);
    procedure AddDirToGrid(Index: integer; Rec: TSearchRec);
    function BuildRowArray(ATitle: TTitlesItem): TStringList;
  public
    property DiscInfo: TDiscInfo read FDiscInfo write FDiscInfo;
    property DiscFile: string read FDiscFile write FDiscFile;
    property VideoFolder: string read FVideoFolder write FVideoFolder;
  end;

const
  kJsonHeaders : array [0..7] of string = (
    'Source File',
    'Description',
    'Type',
    'Season',
    'Episode',
    'Segment Map',
    'Duration',
    'Size');
  kVideoHeaders : array [0..4] of string = (
    'Original File Name',
    'New File Name',
    'Attribute',
    'Size',
    'Modification Date');

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.ParseJson(AllTitles: boolean);
var
  JsonFileStream: TFileStream;
  AData: TJSONData;
  ATitle: TTitlesItem;
  r: integer;
  RowArray: TStringList;
begin
  if DiscFile <> '' then
  begin
    if DiscInfo = nil then
    begin
      JsonFileStream:=TFileStream.Create(DiscFile, fmOpenRead or fmShareDenyWrite);
      AData:=GetJSON(JsonFileStream);
      DiscInfo:=TDiscInfo.CreateFromJSON(AData);
    end;
    StringGrid1.BeginUpdate;
    ResetGrid(kJsonHeaders);
    r:=1;
    for ATitle in DiscInfo.Titles do
    begin
      if (ATitle.Item <> nil) or (AllTitles = true) then
      begin
        RowArray:=BuildRowArray(ATitle);
        StringGrid1.InsertRowWithValues(r, RowArray.ToStringArray);
        Inc(r);
        FreeAndNil(RowArray);
      end;
    end;
    StringGrid1.AutoSizeColumns;
    StringGrid1.EndUpdate;
    //FreeAndNil(AData);
    FreeAndNil(JsonFileStream);
  end;
end;

procedure TFormMain.ParseVideoPath(InputMask: string);
var
  Info: TSearchRec;
  DirName: string;
  Index: integer;
begin
  if VideoFolder <> '' then
  begin
    StringGrid1.BeginUpdate;
    ResetGrid(kVideoHeaders);
    Index:=1;
    DirName:=IncludeTrailingPathDelimiter(VideoFolder);
    if FindFirst(DirName + InputMask, faArchive, Info) = 0 then
      try
        Repeat
        begin
            AddDirToGrid(Index, Info);
            Inc(Index);
          end;
        until FindNext(Info) <> 0;
      finally
        FindClose(Info);
      end;
    StringGrid1.AutoSizeColumns;
    StringGrid1.EndUpdate;
  end;
end;

procedure TFormMain.TabControlGridsChange(Sender: TObject);
begin
  case TabControlGrids.TabIndex of
    0: ParseJson(ActionViewAllTitles.Checked);
    1: ParseVideoPath('*.*');
  end;
end;

procedure TFormMain.ActionViewAllTitlesExecute(Sender: TObject);
begin
  ParseJson(ActionViewAllTitles.Checked);
end;

procedure TFormMain.FileNameEditJsonAcceptFileName(Sender: TObject;
  var Value: String);
begin
  DiscFile:=Value;
end;

procedure TFormMain.FileOpenAccept(Sender: TObject);
begin
  DiscFile:=FileOpen.Dialog.FileName;
  FileNameEditJson.FileName:=DiscFile;
  ParseJson(ActionViewAllTitles.Checked);
end;

procedure TFormMain.FileOpenPathExecute(Sender: TObject);
begin
  if SelectDirectoryDialogVideoPath.Execute then
  begin
    VideoFolder:=SelectDirectoryDialogVideoPath.FileName;
    DirectoryEditVideos.Directory:=VideoFolder;
    TabControlGrids.TabIndex:=1;
    TabControlGridsChange(Sender);
  end;
end;

procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FreeAndNil(FDiscInfo);
end;

procedure TFormMain.ResetGrid(Headers: array of string);
begin
  StringGrid1.BeginUpdate;
  StringGrid1.ClearRows;
  StringGrid1.ColCount:=Length(Headers);
  StringGrid1.InsertRowWithValues(0, Headers);
  StringGrid1.FixedRows:=1;
  StringGrid1.EndUpdate(false);
end;

procedure TFormMain.AddDirToGrid(Index: integer; Rec: TSearchRec);
var
  OriginalFileName, NewFileName, ReplacedText: string;
  i: integer;
  ATitle: TTitlesItem;
begin
  OriginalFileName:=Rec.Name;

  NewFileName:='';
  if DiscInfo <> nil then
  begin
    for i:=0 to Length(DiscInfo.Titles) - 1 do
    begin
      ATitle:=DiscInfo.Titles[i];
      ReplacedText:=LabeledEdit1.Text;
      ReplacedText:=ReplacedText.Replace('{SOURCE}', ATitle.SourceFile.Substring(0, Length(ATitle.SourceFile) - ATitle.SourceFile.IndexOf('.')));
      if (OriginalFileName = ReplacedText) and (ATitle.Item <> nil) then
      begin
        NewFileName:=ATitle.Item.Title;
      end;
    end;
  end;

  StringGrid1.InsertRowWithValues(Index, [
    OriginalFileName,
    NewFileName,
    Rec.Attr.ToString,
    FormatSize(Rec.Size),
    DateTimeToStr(Rec.TimeStamp)
  ]);
end;

function TFormMain.BuildRowArray(ATitle: TTitlesItem): TStringList;
var
  AList: TStringList;
begin
  AList:=TStringList.Create;
  AList.Add(ATitle.SourceFile);
  if ATitle.Item <> nil then
  begin
    AList.Add(ATitle.Item.Title);
    AList.Add(ATitle.Item._Type);
    AList.Add(ATitle.Item.Season);
    AList.Add(ATitle.Item.Episode);
  end else begin
    AList.AddStrings(['', '', '', '']);
  end;
  AList.Add(ATitle.SegmentMap);
  AList.Add(ATitle.Duration);
  AList.Add(ATitle.DisplaySize);
  Result:=AList;
end;

end.

