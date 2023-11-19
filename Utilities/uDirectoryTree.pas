unit uDirectoryTree;
// Displays the directory-tree of a root folder. New nodes are only created as necessary
// when either a node is selected or expanded.
// For performance reasons, folders with more than 1000 direct subfolders will not be expanded.

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  {VCL}
  VCL.ComCtrls,
  VCL.Controls,
  {System}
  System.Classes,
  System.Types,
  System.IOUtils,
  System.SysUtils;


type

  TNodeData = record
    FullPath: string;
    HasEnoughSubnodes: Boolean;
  end;

  PNodeData = ^TNodeData;

  TDirectoryTree = class(TTreeView)
  private
    procedure CreateSubNodesToLevel2(aItem: TTreeNode);

  protected
    procedure Change(Node: TTreeNode); override;
    procedure Delete(Node: TTreeNode); override;
    function CanExpand(Node: TTreeNode): Boolean; override;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy(); override;
    procedure NewRootFolder(const RootFolder: string);
    function GetFullFolderName(aNode: TTreeNode): string;
    procedure GetAllFiles(const aStringList: TStringlist;
                          const aFileMask: string);
  end;

implementation

uses
  WinAPI.Windows,
  {$IF COMPILERVERSION < 30.0}
  {MediaFoundationApi}
  Winapi.MediaFoundationApi.MfUtils,  // Introduces StrCmpLogicalW
  {$ENDIF}
  WinAPI.ShlWApi;

{ TDirectoryTree }

function TDirectoryTree.CanExpand(Node: TTreeNode): Boolean;
begin
  inherited;
  if Assigned(Node.Data) then
    begin
      Result := True;
      CreateSubNodesToLevel2(Node);
    end
  else
    Result := False;
end;


procedure TDirectoryTree.Change(Node: TTreeNode);
begin
  inherited;
  CreateSubNodesToLevel2(Node);
end;


constructor TDirectoryTree.Create(aOwner: TComponent);
begin
  inherited;
  ReadOnly := True;
end;


procedure TDirectoryTree.Delete(Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    begin
      Finalize(PNodeData(Node.Data)^);
      Dispose(PNodeData(Node.Data));
      Node.Data := nil;
    end;
  inherited;
end;


destructor TDirectoryTree.Destroy();
begin
  inherited;
end;


procedure TDirectoryTree.CreateSubNodesToLevel2(aItem: TTreeNode);
var
  DirArraySize1, DirArraySize2, i, j: Integer;
  DirArray1, DirArray2: TStringDynArray;
  TreeItem, TreeItem2: TTreeNode;
  NewName: string;
  FileAtr: Integer;
  DirectoryCount: Integer;
  NodeData: PNodeData;

begin
  if not Assigned(aItem.Data) then
    raise Exception.Create('Node has no directory name');

  if PNodeData(aItem.Data).HasEnoughSubnodes then
    Exit;

  Items.BeginUpdate;

  try
    PNodeData(aItem.Data).HasEnoughSubnodes := False;
    FileAtr := faHidden + faSysFile + faSymLink;
    DirectoryCount := 0;
    DirArray1 := TDirectory.GetDirectories(GetFullFolderName(aItem),
                                           function(const path: string;
                                                    const SearchRec: TSearchRec): Boolean
                                             begin
                                               Result := (DirectoryCount < 1001) and
                                               (SearchRec.Attr and
                                               (not FileAtr) = SearchRec.Attr);
                                               if Result then
                                                 Inc(DirectoryCount);
                                             end);

    DirArraySize1 := Length(DirArray1);

    // ignore directories with more than 1000 entries
    if (DirArraySize1 < 1) or (DirArraySize1 > 1000) then
      begin
        PNodeData(aItem.Data).HasEnoughSubnodes := True;
        Exit;
      end;

    for i := 0 to DirArraySize1 - 1 do
      begin
        NewName := DirArray1[i];
        if (aItem.Count <= i) then // NewName isn't a node yet
          begin
            New(NodeData);
            NodeData.FullPath := NewName;
            NodeData.HasEnoughSubnodes := False;
            TreeItem := Items.AddChild(aItem, ExtractFilename(NewName));
            TreeItem.Data := NodeData;
            TreeItem.ImageIndex := 0;
          end
        else
          TreeItem := aItem.Item[i];

        if (TreeItem.Count > 0) then // already filled
          Continue;

        DirectoryCount := 0;
        DirArray2 := TDirectory.GetDirectories(NewName,
                                               function(const path: string;
                                                        const SearchRec: TSearchRec): Boolean
                                                 begin
                                                   Result := (DirectoryCount < 1001) and
                                                             (SearchRec.Attr and
                                                             (not FileAtr) = SearchRec.Attr);
                                                   if Result then
                                                     inc(DirectoryCount);
                                                 end);

        DirArraySize2 := Length(DirArray2);

        if (DirArraySize2 < 1) or (DirArraySize2 > 1000) then
          begin
            // Don't expand a folder with more than 1000 subfolders any futher
            PNodeData(TreeItem.Data).HasEnoughSubnodes := True;
            Continue;
          end;

        for j := 0 to DirArraySize2 - 1 do
          begin
            if (TreeItem.Count <= j) then
              begin
                TreeItem2 := Items.AddChild(TreeItem, ExtractFilename(DirArray2[j]));
                New(NodeData);
                NodeData.FullPath := DirArray2[j];
                NodeData.HasEnoughSubnodes := False;
                TreeItem2.Data := NodeData;
                TreeItem2.ImageIndex := 0;
              end;
          end;
      end;

    PNodeData(aItem.Data).HasEnoughSubnodes := True;

  finally
    Items.EndUpdate;
  end;
end;


procedure TDirectoryTree.NewRootFolder(const RootFolder: string);
var
  Root: TTreeNode;
  ShortName: string;
  NodeData: PNodeData;

begin
  if not System.SysUtils.DirectoryExists(RootFolder) then
    raise Exception.Create(RootFolder + ' does not exist');

  Items.Clear;
  Items.BeginUpdate;

  try
    ShortName := ExtractFilename(RootFolder);

    if ShortName = '' then
      ShortName := RootFolder;

    Root := Items.AddChild(nil,
                           ShortName);
    New(NodeData);
    NodeData.FullPath := RootFolder;
    NodeData.HasEnoughSubnodes := False;
    Root.Data := NodeData;
    Root.ImageIndex := 0;
    CreateSubNodesToLevel2(Root);
  finally
    Items.EndUpdate;
  end;

  Root.Expand(False);
  Root.Selected := True;
end;


function TDirectoryTree.GetFullFolderName(aNode: TTreeNode): string;
begin
  if not Assigned(aNode.Data) then
    raise Exception.Create('Node has no directory name');
  Result := PNodeData(aNode.Data).FullPath;
end;


function LogicalCompare(List: TStringlist; Index1, Index2: Integer): Integer;
begin
  Result := StrCmpLogicalW(PWideChar(List[Index1]),
                           PWideChar(List[Index2]));
end;


procedure TDirectoryTree.GetAllFiles(const aStringList: TStringlist;
                                     const aFileMask: string);

var
  FilePath,
  mask,
  SearchStr: string;
  MaskLen,
  MaskPos,
  SepPos: Integer;

{$IF COMPILERVERSION < 30.0}
  i: Integer;
  Strings: TArray<string>;
  ClassicStrings: TStringDynArray;
{$ENDIF}

begin
  FilePath := IncludeTrailingBackSlash(GetFullFolderName(Selected));
  Assert(Assigned(aStringList));
  aStringList.Clear;
  mask := aFileMask;
  MaskLen := Length(mask);
  MaskPos := 0;

  while (MaskPos >= 0) do
    begin
      SepPos := Pos(';',
                    mask,
                    MaskPos + 1) - 1;

      if (SepPos >= 0) then
        SearchStr := Copy(mask,
                          MaskPos + 1,
                          SepPos - MaskPos)
    else
      SearchStr := Copy(mask,
                        MaskPos + 1,
                        MaskLen);


{$IF COMPILERVERSION > 34.0}  {Delphi 10.4 Sydney}
    aStringList.AddStrings(TDirectory.GetFiles(FilePath,
                                               SearchStr,
                                               TSearchOption.soTopDirectoryOnly));
{$ELSE}
    ClassicStrings := TDirectory.GetFiles(FilePath,
                                          SearchStr,
                                          TSearchOption.soTopDirectoryOnly);

    if (Length(ClassicStrings) > 0) then
      begin
        SetLength(Strings,
                  Length(ClassicStrings));
        // Copy all fields to the new array
        for i := 0 to Length(ClassicStrings) -1 do
          Strings[i] := ClassicStrings[i];

        aStringList.AddStrings(Strings);
      end;

  SetLength(ClassicStrings,
            0);
  ClassicStrings := nil;
{$ENDIF}

    if (SepPos >= 0) then
      begin
        inc(SepPos);
        if (SepPos >= MaskLen) then
          SepPos := -1;
      end;
    MaskPos := SepPos;
  end;

  // Natural sorting order, e.g. '7' '8' '9' '10'
  aStringList.CustomSort(LogicalCompare);
end;

end.
