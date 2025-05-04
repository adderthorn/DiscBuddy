unit UnitMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  Menus, Grids, StdActns, ExtCtrls, fpjson, jsonparser, DiscInfoUnit;

type

  { TFormMain }

  TFormMain = class(TForm)
    FileOpenPath: TAction;
    ActionViewAllTitles: TAction;
    ActionList: TActionList;
    FileExit: TFileExit;
    FileOpen: TFileOpen;
    MainMenu: TMainMenu;
    MenuItemOpenVideoPath: TMenuItem;
    MenuItemFileOpen: TMenuItem;
    MenuItemViewAllItems: TMenuItem;
    MenuItemView: TMenuItem;
    MenuItemFileExit: TMenuItem;
    MenuItemFile: TMenuItem;
    PanelBottom: TPanel;
    SelectDirectoryDialogVideoPath: TSelectDirectoryDialog;
    StringGrid1: TStringGrid;
    procedure ActionViewAllTitlesExecute(Sender: TObject);
    procedure FileOpenAccept(Sender: TObject);
    procedure FileOpenPathExecute(Sender: TObject);
    procedure ParseJson(AllTitles: boolean);
  private
    FDiscFile: string;
    procedure ResetGrid;
    function BuildRowArray(ATitle: TTitlesItem): TStringList;
  public
    property DiscFile: string read FDiscFile write FDiscFile;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.ParseJson(AllTitles: boolean);
var
  JsonFileStream: TFileStream;
  AData: TJSONData;
  ADiscInfo: TDiscInfo;
  ATitle: TTitlesItem;
  r: integer;
  RowArray: TStringList;
begin
  JsonFileStream:=TFileStream.Create(DiscFile, fmOpenRead or fmShareDenyWrite);
  AData:=GetJSON(JsonFileStream);
  ADiscInfo:=TDiscInfo.CreateFromJSON(AData);
  StringGrid1.BeginUpdate;
  ResetGrid;
  r:=1;
  for ATitle in ADiscInfo.Titles do
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
  FreeAndNil(ADiscInfo);
  FreeAndNil(AData);
  FreeAndNil(JsonFileStream);
end;

procedure TFormMain.ActionViewAllTitlesExecute(Sender: TObject);
begin
  ParseJson(ActionViewAllTitles.Checked);
end;

procedure TFormMain.FileOpenAccept(Sender: TObject);
begin
  DiscFile:=FileOpen.Dialog.FileName;
  ParseJson(ActionViewAllTitles.Checked);
end;

procedure TFormMain.FileOpenPathExecute(Sender: TObject);
begin
  if SelectDirectoryDialogVideoPath.Execute then
  begin
    ShowMessage(SelectDirectoryDialogVideoPath.FileName);
  end;
end;

procedure TFormMain.ResetGrid;
begin
  StringGrid1.BeginUpdate;
  StringGrid1.ClearRows;
  StringGrid1.InsertRowWithValues(0, [
    'Source File',
    'Description',
    'Type',
    'Season',
    'Episode',
    'Segment Map',
    'Duration',
    'Size'
  ]);
  StringGrid1.FixedRows:=1;
  StringGrid1.EndUpdate(false);
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

