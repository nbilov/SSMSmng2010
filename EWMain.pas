unit EWMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus, StdCtrls
  , DateUtils,IniFiles, Shellapi ;

type
  TFormWindows = class(TForm)
    BtnBuild: TButton;
    buSSMS: TButton;
    chkAutoClose: TCheckBox;
    edApp: TEdit;
    edMax: TEdit;
    edPWndTitle: TEdit;
    edWndTitle: TEdit;
    laClassName: TLabel;
    laMsg: TLabel;
    laPClassName: TLabel;
    laPWndTitle: TLabel;
    laWndTitle: TLabel;
    pmAll: TPopupMenu;
    NFind: TMenuItem;
    TreeWindows: TTreeView;
    edClassName: TComboBox;
    edPClassName: TComboBox;
    edFindTxt: TEdit;
    laFindTxt: TLabel;
    procedure BtnBuildClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure buSSMSClick(Sender: TObject);
    procedure TreeWindowsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure NFindClick(Sender: TObject);
  private
    procedure FindInTree(s: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWindows: TFormWindows;
  iv,imax:integer;
var
  vMyWndTitle:string = '';
  vMyClassName:string = '';
  vMyPWndTitle:string = '';
  vMyPClassName:string = '';

var
  // ����� ����� ��������� ��������� ����
//  vText: string;
//  vTextLen: Integer;
//  vWnd: HWND;
  NeedWait:boolean;
  isInited:boolean;


implementation

{$R *.dfm}
uses uMyTh;

procedure WriteStringIfNeed(fi:TIniFile;Section,Ident:string;Value:string);
begin
  if fi.ReadString(Section,Ident,Value+'+')<>Value then
  fi.WriteString(Section,Ident,Value);
end;

procedure WriteIntegerIfNeed(fi:TIniFile;Section,Ident:string;Value:integer);
begin
  if fi.ReadInteger(Section,Ident,Value+1)<>Value then
  fi.WriteInteger(Section,Ident,Value);
end;

procedure WriteBoolIfNeed(fi:TIniFile;Section,Ident:string;Value:boolean);
begin
  if fi.ReadBool(Section,Ident,not Value)<>Value then
  fi.WriteBool(Section,Ident,Value);
end;



var
 MyTh:TMyTh;

 procedure ClearTh;
 begin
  if isInited then
  begin
    isInited := False;
    if Assigned(MyTh) then MyTh.Terminate;
  end;

 end;

 procedure SetData(Wnd: HWND;var Text:string;var TextLen: Integer);
 begin
  if isInited then MyTh.DTWait:=0;

  while 1=1 do
  try
  if NeedWait then
  if MyTh.DoneTh and isInited then
  begin
    MyTh.DTWait := 0;
    TextLen := MyTh.TextLen;
    Text := MyTh.Text;
    //MyTh.Terminate;
    NeedWait := False;
    Break;
    //MyTh.Free
  end
  else
  begin
    if isInited then
    if MyTh.DTWait=0 then
    break
    else
    if MilliSecondsBetween(Now,MyTh.DTWait)<100 then
    begin
      //Exit;
      //Sleep(10);
      Continue

    end
    else
    begin
      TextLen := 0;
      Text := '???';
      //MyTh.Terminate;
      NeedWait := False;
      MyTh.DTWait := 0;
      MyTh.DoneTh := True;
      MyTh.Terminate;
      isInited := false;
      Break;
    end;
  end
  else
  if not isInited or( MyTh.Wnd <> Wnd) then
  begin
   NeedWait := True;
   if not isInited then
   begin
     //isInited := true;
     MyTh := TMyTh.Create(True);
     MyTh.DoneTh := True;
   end;

   MyTh.Wnd := Wnd;

   if not isInited then
   begin
     isInited := true;
     //MyTh := TMyTh.Create(True);
     MyTh.FreeOnTerminate := True;

     MyTh.Priority:=tpNormal;
     MyTh.Start;
   end;
   MyTh.DoneTh := False;
   MyTh.DTWait := Now;
   //Sleep(10);
  end;

  finally
    //Sleep(10);
  end;
 end;

// ��� ������� ��������� ������, ������� �����
// �������������� ��� ������ EnumWindows � EnumChildWindows.
// ��� ������� ��������� �� ��������� � �����, �������
// ������ MSDN. ������ TTreeNode, ��� � ����� �����,
// �������� ����������, ������� ����� �������������� �����,
// ��� ��������� ���������������� ��������� - �� ��������
// ������ ����� ���� ��� �������. ��������� �� �������
// ��������� ������ � EnumWindows � EnumChildWindows �
// ������ Windows.dcu �������� ��� ����������������
// ���������, ������� ���������� �� ������������
// ������������ ��������� ��������� �����������.

function EnumWindowsProc(Wnd: HWND; ParentNode: TTreeNode): Bool; stdcall;
 // ������� �� ��������������� ����������� ������, ������
 // ����� ����� ������, ������� ��� ��������� ����� �����
 // ���������� �������� ����� ������� ����� � �������, ���
 // ��� ������ �� �������� ��� �������. � ������ �������
 // ������ ����� ������ ������������ ���������� ClassNameLen.
 // ������ ������������, ��� ��� ������ �������� �������,
 // ��� 511 �������� (512-� �������������� ��� ������������
 // �������� �������).
const
  ClassNameLen = 512;
var
  // ����� ����� ��������� ��������� ����
  Text: string;
  TextLen: Integer;
var
  // ��� - ����� ��� ����� ������
  ClassName: array[0..ClassNameLen - 1] of Char;
  Node: TTreeNode;
  NodeName: string;
begin
  Result := True;
  // ������� EnumChildWindows ����������� �� ������
  // ��������������� �������� ���� ������� ����, �� �
  // �������� ���� ��� �������� ���� � �.�. �� ���
  // ���������� ������ �� ������ ���� ��� ����� ������
  // ������ �������, ������� ��� ����, �� ���������� �������
  // ���������, �� ����� ����������.

  //if Wnd = 2426836 then Exit(1=11);

  if Assigned(ParentNode) and (GetParent(Wnd) <> HWND(ParentNode.Data)) then
    Exit;
  // �������� ����� ��������� ����. ������ �������
  // GetWindowText � GetWindowTextLength �� �����
  // ���������� ��������� WM_GETTEXT � WM_GETTEXTLENGTH,
  // ������ ��� �������, � ������� �� ���������, ��
  // ����� �������� � ���������� ����������,
  // �������������� ����� ����� ���������.

  //DoneTh := False;

  TextLen := 3;
  Text := 'aaa';


//  SetLength(Text, TextLen);
//  if TextLen > 0 then
//  SendMessage(vWnd, WM_GETTEXT, TextLen + 1, LParam(Text));

  SetData(Wnd,Text,TextLen);

  if 1=11 then
  begin

  TextLen := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0);
  // ������������� ����� ��������� ����������, �������
  // ����� �������������� ��� ����� ��� ��������� ����.
  // ������������� SetLength �����������, ��� �����
  // �������� ����������� ������� ������, �� ������� ��
  // ����� ������ ������.
  SetLength(Text, TextLen);
  // ���� ��������� ���� - ������ ������, TextLen �����
  // ����� �������� 0, � ��������� Text ��� ����������
  // SetLength ������� �������� nil. �� ��� ���������
  // ��������� WM_GETTEXT ������� ��������� � ����� ������
  // ���������� �������� ������ �� ����������� ������,
  // ���� ���� ��������� ���� ������ - � ���� ������ �
  // ���������� ����� ����� ������� ���� ������ -
  // ����������� ����. �� ���� ����� ������� nil, ��
  // ������� �������� ���-�� � ����� ����� ������� �
  // Access violation, ������� ���������� ���� WM_GETTEXT
  // ����� ������ � ��� ������, ���� TextLen > 0.
  if TextLen > 0 then
    SendMessage(Wnd, WM_GETTEXT, TextLen + 1, LParam(Text));
  // ��������� ���� ����� ���� ����� ������� - ��������, �
  // Memo ���������� ��������� ���� �����, ������� ���
  // ����. �������� ����������, ��� ���������� ��������
  // ��� ���������� � TTreeView ����� � ����� ��������
  // ����������: ��� ������� ������� ����� ���� ���������,
  // ���������� �� Delphi, �������� � �������� (���
  // ������� ��� ����� Delphi ������� �� ��������). �����
  // ����� �� �����������, ������� ������� ������
  // ����������.
  end;
  if TextLen > 100 then
    Text := Copy(Text, 1, 100) + ' ...';
  GetClassName(Wnd, ClassName, ClassNameLen);
  ClassName[ClassNameLen - 1] := #0;

//  if Text = '' then
//  if ClassName = 'TPUtilWindow' then
//  begin
//    //Text := '!' + 'TPUtilWindow';
//    if SecondsBetween(Now,DT)>3330 then
//    Exit(1=11)
//  end;

  if Text = '' then
    NodeName := '��� �������� (' + ClassName + ')'
  else
    NodeName := Text + ' (' + ClassName + ')';

  inc(iv);
  if imax>0 then
  if iv>imax then Exit(1=11);

  NodeName :=  NodeName  + ' | ' + IntToStr(iv);

  Node := FormWindows.TreeWindows.Items.AddChild(ParentNode, NodeName);
  // ���������� � ������ ���� ���������� ����������������
  // ��� ����, ����� ����� ����������� ��������� ��������
  // �������.
  Node.Data := Pointer(Wnd);
  // �������� EnumChildWindows, ��������� �������
  // EnumWindowsProc � �������� ���������, � ��������� ��
  // ��������� ���� - � �������� ��������� ���� �������.
  // ��� ���� EnumWindowsProc ����� ���������� ��
  // EnumChildWindows, �.�. ���������� ��������.
  Node.Selected := True;
  Application.ProcessMessages;
  EnumChildWindows(Wnd, @EnumWindowsProc, LParam(Node));
end;

// ���� ��������������� ������ ������� �������
// EnumWindowsProc, ������� ���������� �� ����������� ���,
// ��� ����� ��� ��������� ��������� ���� ������������
// ������� � ������� ���������� ���� PChar, � �� string. ��
// ����� �������������� ������������ ��� �������� ����������.
{function EnumWindowsProc(Wnd: HWND; ParentNode: TTreeNode): Bool; stdcall;
const
  ClassNameLen = 512;
var
  TextLen: Integer;
  Text: PChar;
  ClassName: array[0..ClassNameLen - 1] of Char;
  Node: TTreeNode;
  NodeName: string;
begin
  Result := True;
  if Assigned(ParentNode) and (GetParent(Wnd) <> HWND(ParentNode.Data)) then
    Exit;
  // �����, � ������� �� ����������� ��������, � �����,
  // ���������� ����� WM_GETTEXTLENGTH, �����������
  // �������, ������ ��� ����� ������� ������ ����������
  // ���� ��� ������������ ����.
  TextLen := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0) + 1;
  // �������� ��������� ���������� ������. ��� ���
  // ���������� �� ��������� ��� ������ �������������,
  // ���������� ������������ ���� try/finally, ����� �����
  // ������ ������ ��� �����������.
  Text := StrAlloc(TextLen);
  try
    // ��� ��� ��� ������ ���� ��� ������ ��������� �����
    // ������� ���� �� ���� ����, ����� ����� ����������
    // WM_GETTEXT, �� �������� ����� ������, ��� ��� ����
    // � ���������� �������� - ����� ������ �����
    // ����������.
    SendMessage(Wnd, WM_GETTEXT, TextLen, LParam(Text));
    // �������� ������� ������� ������. ��������������
    // PChar �������, ��� string. ������� ���� � ��������
    // ������ �������� � ����, ��� ��� API-������� �����
    // ������������ "�����", �� �� ������ StrDispose ��� ��
    // ��������, �.�. ������� StrAlloc (� ����� ������
    // ������� ��������� ������ ��� ����-���������������
    // ����� ������ SysUtils) ��������� ������ ����������
    // ������ ����� � ����� �������, � StrDispose
    // ������������� ������ �� ���� ������, � �� ��
    // ����������� ����.
    if TextLen > 104 then
    begin
      (Text + 104)^ := #0;
      (Text + 103)^ := '.';
      (Text + 102)^ := '.';
      (Text + 101)^ := '.';
      (Text + 100)^ := ' ';
    end;
    GetClassName(Wnd, ClassName, ClassNameLen);
    if Text^ = #0 then
      NodeName := '��� �������� (' + ClassName + ')'
    else
      NodeName := Text + ' (' + ClassName + ')';
    Node := FormWindows.TreeWindows.Items.AddChild(ParentNode, NodeName);
    Node.Data := Pointer(Wnd);
    EnumChildWindows(Wnd, @EnumWindowsProc, LParam(Node));
  finally
    // ������� ����������� ������, ���������� ��� ������
    StrDispose(Text);
  end;
end;}

var
  tr0: TTreeView;
  isBFound:boolean=false;
  liClassName:TStringList=nil;


function EnumWindowsProc2(Wnd: HWND; ParentNode: TTreeNode): Bool; stdcall;
 // ������� �� ��������������� ����������� ������, ������
 // ����� ����� ������, ������� ��� ��������� ����� �����
 // ���������� �������� ����� ������� ����� � �������, ���
 // ��� ������ �� �������� ��� �������. � ������ �������
 // ������ ����� ������ ������������ ���������� ClassNameLen.
 // ������ ������������, ��� ��� ������ �������� �������,
 // ��� 511 �������� (512-� �������������� ��� ������������
 // �������� �������).
const
  ClassNameLen = 512;

var
  // ����� ����� ��������� ��������� ����
  Text: string;
  TextLen: Integer;
  // ��� - ����� ��� ����� ������
  ClassName: array[0..ClassNameLen - 1] of Char;
  sClassName:string;
  Node: TTreeNode;
  NodeName: string;
  li: TStringList;
  I: Integer;
begin
  Result := True;
  // ������� EnumChildWindows ����������� �� ������
  // ��������������� �������� ���� ������� ����, �� �
  // �������� ���� ��� �������� ���� � �.�. �� ���
  // ���������� ������ �� ������ ���� ��� ����� ������
  // ������ �������, ������� ��� ����, �� ���������� �������
  // ���������, �� ����� ����������.

  //if Wnd = 2426836 then Exit(1=11);

  if Assigned(ParentNode) and (GetParent(Wnd) <> HWND(ParentNode.Data)) then
    Exit;
  // �������� ����� ��������� ����. ������ �������
  // GetWindowText � GetWindowTextLength �� �����
  // ���������� ��������� WM_GETTEXT � WM_GETTEXTLENGTH,
  // ������ ��� �������, � ������� �� ���������, ��
  // ����� �������� � ���������� ����������,
  // �������������� ����� ����� ���������.
  SetData(Wnd,Text,TextLen);

  if 1=11 then
  begin

  TextLen := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0);
  // ������������� ����� ��������� ����������, �������
  // ����� �������������� ��� ����� ��� ��������� ����.
  // ������������� SetLength �����������, ��� �����
  // �������� ����������� ������� ������, �� ������� ��
  // ����� ������ ������.
  SetLength(Text, TextLen);
  // ���� ��������� ���� - ������ ������, TextLen �����
  // ����� �������� 0, � ��������� Text ��� ����������
  // SetLength ������� �������� nil. �� ��� ���������
  // ��������� WM_GETTEXT ������� ��������� � ����� ������
  // ���������� �������� ������ �� ����������� ������,
  // ���� ���� ��������� ���� ������ - � ���� ������ �
  // ���������� ����� ����� ������� ���� ������ -
  // ����������� ����. �� ���� ����� ������� nil, ��
  // ������� �������� ���-�� � ����� ����� ������� �
  // Access violation, ������� ���������� ���� WM_GETTEXT
  // ����� ������ � ��� ������, ���� TextLen > 0.
  if TextLen > 0 then
    SendMessage(Wnd, WM_GETTEXT, TextLen + 1, LParam(Text));
  // ��������� ���� ����� ���� ����� ������� - ��������, �
  // Memo ���������� ��������� ���� �����, ������� ���
  // ����. �������� ����������, ��� ���������� ��������
  // ��� ���������� � TTreeView ����� � ����� ��������
  // ����������: ��� ������� ������� ����� ���� ���������,
  // ���������� �� Delphi, �������� � �������� (���
  // ������� ��� ����� Delphi ������� �� ��������). �����
  // ����� �� �����������, ������� ������� ������
  // ����������.
  end;

  if TextLen > 100 then
    Text := Copy(Text, 1, 100) + ' ...';
  GetClassName(Wnd, ClassName, ClassNameLen);
  ClassName[ClassNameLen - 1] := #0;
  sClassName := ClassName;

//  if Text = '' then
//  if ClassName = 'TPUtilWindow' then
//  begin
//    //Text := '!' + 'TPUtilWindow';
//    if SecondsBetween(Now,DT)>3330 then
//    Exit(1=11)
//  end;

  if Text = '' then
    NodeName := '��� �������� (' + ClassName + ')'
  else
    NodeName := Text + ' (' + ClassName + ')';

  inc(iv);
  if imax>0 then
  if iv>imax then Exit(1=11);


  if Text=vMyWndTitle then
  begin

    li := TStringList.Create() ;
    try
      if liClassName=nil then
      begin
        li.Add(vMyClassName);
      end
      else
      li.AddStrings(liClassName);


      for I := 0 to li.Count - 1 do
      //if Text=vMyWndTitle then
      //if sClassName=vMyClassName then
      if sClassName=li[i] then
      repeat
        if vMyPWndTitle<>'' then
        if vMyPClassName<>'' then
        if not Assigned(ParentNode)
        or (ParentNode.Text<>(vMyPWndTitle + ' (' + vMyPClassName + ')' ) ) then
        break;

        FormWindows.laMsg.Caption := TimeToStr(Now)+ ' have found our button';
        SendMessage( Wnd, WM_SETFOCUS, 0, 0);
        SendMessage( Wnd , BM_CLICK ,mk_LButton , 3 + 3 shl 16);
        isBFound := True;
        Exit(1=11)
      until true;




    finally
      li.Free;
    end;


  end;






//  NodeName := NodeName  + ' | ' + IntToStr(iv);
//
  Node := tr0.Items.AddChild(ParentNode, NodeName);
  // ���������� � ������ ���� ���������� ����������������
  // ��� ����, ����� ����� ����������� ��������� ��������
  // �������.
  Node.Data := Pointer(Wnd);
  // �������� EnumChildWindows, ��������� �������
  // EnumWindowsProc � �������� ���������, � ��������� ��
  // ��������� ���� - � �������� ��������� ���� �������.
  // ��� ���� EnumWindowsProc ����� ���������� ��
  // EnumChildWindows, �.�. ���������� ��������.
//  Node.Selected := True;
//  Application.ProcessMessages;
  EnumChildWindows(Wnd, @EnumWindowsProc2, LParam(Node));
end;


procedure TFormWindows.BtnBuildClick(Sender: TObject);
var
  s: TCaption;
begin

  Screen.Cursor := crHourGlass;
  try
    TreeWindows.Items.Clear;
    iv := 0;
    imax := StrToIntDef(edMax.Text,0);
    EnumWindows(@EnumWindowsProc, 0);

    s := edFindtxt.text;//(nil);
    s := trim(s);
    if s<>'' then  FindInTree(s);
    ;
  finally
    Screen.Cursor := crDefault;
    ClearTh;
  end;
end;

procedure TFormWindows.buSSMSClick(Sender: TObject);
var
  J,I: Integer;
  li: TStringList;
begin
  Screen.Cursor := crHourGlass;
  if ParamStr(1)='RUNNOW' then
  else
  if edApp.Text<>'' then
  ShellApi.ShellExecute(0, 'open', PChar(edApp.Text), '', '', SW_NORMAL);
  isBFound := false;
  for J := 0 to 19 - 1 do
  begin

    tr0 := TTreeView.Create(nil);

    li := TStringList.Create() ;

    try

      tr0.Parent := Self ;
      tr0.Visible := False;

      li.Add(edClassName.Text);
      for I := 0 to edClassName.Items.Count - 1 do
      if I<> edClassName.ItemIndex then
      li.Add(edClassName.Items[I]) ;

      liClassName := li;

      vMyWndTitle := edWndTitle.Text;
      vMyClassName := edClassName.Text;
      iv := 0;
      imax := StrToIntDef(edMax.Text,0);
      EnumWindows(@EnumWindowsProc2, 0);
    finally
      Screen.Cursor := crDefault;
      tr0.Free;
      li.Free;
      liClassName := nil;
      ClearTh;
    end;


    if isBFound then break;
    if edApp.Text<>'' then
    Sleep(6000)
    else
                           begin
                             break
                           end;

  end;

  if not isBFound then
  BtnBuild.Click
  else
  if chkAutoClose.Checked then Self.Close;


end;


procedure TFormWindows.FormCreate(Sender: TObject);
var
  ini: TIniFile;
  I: Integer;
  itn: string;
  itv: string;
begin
 if StrToIntDef(edMax.Text,0)=0 then
 edMax.Text := '';

 NFind.ShortCut := TextToShortCut('Ctrl+F');

 edClassName.Text := '';
 edWndTitle.Text := '';
 edPClassName.Text := '';
 edPWndTitle.Text := '';
 edPClassName.Enabled := false;
 edPWndTitle.Enabled := false;
 ini := Tinifile.Create(ParamStr(0)+'.ini');
 try
   for I := 0-1 to 11 - 1 do
   begin

     itn := edClassName.Name;
     if I>0-1 then itn := itn + IntToStr(I);
     itv := ini.ReadString(ClassName,itn,'');
     itv := trim(itv);
     if itv<>'' then
     edClassName.Items.Add(itv);


     itn := edPClassName.Name;
     if I>0-1 then itn := itn + IntToStr(I);
     itv := ini.ReadString(ClassName,itn,'');
     itv := trim(itv);
     if itv<>'' then
     edPClassName.Items.Add(itv);


   end;


   if edClassName.Items.Count>0 then edClassName.ItemIndex := 0;
   if edPClassName.Items.Count>0 then edPClassName.ItemIndex := 0;

   edMax.Text := Inttostr(ini.Readinteger(ClassName,edMax.Name,0));
   edWndTitle.Text := ini.ReadString(ClassName,edWndTitle.name,'');

   edClassName.Text := ini.ReadString(ClassName,edClassName.Name,'');
   edPWndTitle.Text := ini.ReadString(ClassName,edPWndTitle.name,'');
   edPClassName.Text := ini.ReadString(ClassName,edPClassName.Name,'');
   edApp.Text := ini.ReadString(ClassName,edApp.Name,'');
   edFindTxt.Text := ini.ReadString(ClassName,edFindTxt.Name,'');
   chkAutoClose.Checked := ini.ReadBool(ClassName,chkAutoClose.Name,1=1);

 finally
   ini.Free;
 end;

end;


procedure TFormWindows.FormClose(Sender: TObject; var Action: TCloseAction);
var
  ini: TIniFile;
begin
  ini := Tinifile.Create(ParamStr(0)+'.ini');
  try
    WriteIntegerIfNeed(ini,ClassName,edMax.Name,Strtointdef(edMax.Text,0));
    WriteStringIfNeed(ini,ClassName,edWndTitle.Name,edWndTitle.Text);
    WriteStringIfNeed(ini,ClassName,edClassName.Name,edClassName.text);
    WriteStringIfNeed(ini,ClassName,edPWndTitle.Name,edPWndTitle.Text);
    WriteStringIfNeed(ini,ClassName,edPClassName.Name,edPClassName.text);
    WriteStringIfNeed(ini,ClassName,edApp.Name,edApp.text);
    WriteBoolIfNeed(ini,ClassName,chkAutoClose.Name,chkAutoClose.Checked);
  finally
    ini.Free;
  end;

end;


procedure TFormWindows.FormShow(Sender: TObject);
begin
 if ParamStr(1)='RUNNOW' then
 buSSMS.Click;

end;

procedure TFormWindows.NFindClick(Sender: TObject);
var
 s : string;
begin
  if not InputQuery('������� ������','',s) then
  Exit;
  FindInTree(s);

end;

procedure TFormWindows.FindInTree(s: string);
var
  Tn: TTreeNode;
begin
  for Tn in TreeWindows.Items do
    if tn <> nil then
      if Pos(s, tn.Text) > 0 then
      begin
        TreeWindows.Select(tn);
        tn.EditText;
        Break;
      end;
end;

procedure TFormWindows.TreeWindowsClick(Sender: TObject);
begin
 TreeWindows.Selected.EditText;
end;

end.

