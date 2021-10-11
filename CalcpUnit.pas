unit CalcpUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, StrUtils, Buttons, XPMan;

type
  TCalcpForm = class(TForm)
    Panel1: TPanel;
    ListBox1: TListBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;
    XPManifest1: TXPManifest;
    SpeedButton17: TSpeedButton;
    SpeedButton18: TSpeedButton;
    SpeedButton19: TSpeedButton;
    SpeedButton20: TSpeedButton;
    EditStr1: TEdit;
    EditNum1: TEdit;
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure N8Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton13Click(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
    procedure SpeedButton15Click(Sender: TObject);
    procedure SpeedButton16Click(Sender: TObject);
    procedure SpeedButton17Click(Sender: TObject);
    procedure SpeedButton18Click(Sender: TObject);
    procedure SpeedButton19Click(Sender: TObject);
    procedure SpeedButton20Click(Sender: TObject);
    procedure EditStr1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStr1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure Calc();
    procedure AddEditStr(ch: string);

  public
    { Public declarations }
  end;

var
  CalcpForm: TCalcpForm;

implementation

uses MySynt;

{$R *.dfm}

// заменить неправельные разделители
function ReplDelim(s: string): string;
var
  i: Integer;
begin
  if Length(s)=0 then Exit;

  for i:=1 to Length(s) do
    if s[i] in ['.',','] then s[i]:=DecimalSeparator;

  // неправельный символ в начале строки
  if s[1] in ['/','*'] then s[1]:=' ';
  // неправельный символ в конце строки
  if s[Length(s)] in ['=','+','-','*','/'] then s[Length(s)]:=' ';

  result:=Trim(s);
end;

(*
{--------------------------------------------------------------------}
{ Функция заменяет в строке S все вхождения подстроки Srch на        }
{ подстроку, переданную в качестве аргумента Replace.                }
{--------------------------------------------------------------------}
function frReplaceStr(const S, Srch: string): string;
var
  I: Integer;
  Source: string;

begin

 Source := S;
 Result := '';
 repeat
   I := Pos(Srch, Source);
   if I > 0 then begin
//     Result := Result + Copy(Source, 1, I - 1) + Replace;
     Result := Result + Copy(Source, 1, I - 1);
     Source := Copy(Source, I + Length(Srch), 220);
   end
   else Result := Result + Source;
 until I <= 0;

end; { frReplaceStr }


function StrRemoveChar(const S: AnsiString; const C: Char): AnsiString;
var P, Q    : PAnsiChar;
    I, L, M : Integer;
begin
  L := Length(S);
  if L = 0 then
    begin
      Result := '';
      exit;
    end;
  M := 0;
  P := Pointer(S);
  For I := 1 to L do
    begin
      if P^ = C then
        Inc(M);
      Inc(P);
    end;
  if M = 0 then
    begin
      Result := S;
      exit;
    end;
  SetLength(Result, L - M);
  Q := Pointer(Result);
  P := Pointer(S);
  For I := 1 to L do
    begin
      if P^ <> C then
        begin
          Q^ := P^;
          Inc(Q);
        end;
      Inc(P);
    end;
end;
*)

function srDeleteCharStr(const s, srch: string): string;
var
  i,j: Integer;
begin
//  result:=AnsiReplaceStr(s,' ','');
//  result:=frReplaceStr(s,' ');
//  result:=StrRemoveChar(s,' ');
//  result:=StrRemoveChar(s,#32);
//  ShowMessage(IntToStr(21));

  j:=0;
//  SetString(result, nil, Length(s));
  SetLength(result, Length(s));
  result:=StringOfChar(' ', Length(s));
  for i:=1 to Length(s) do begin
    if (s[i]<>srch) and (Ord(s[i])<>160) then begin
      Inc(j);
      result[j]:=s[i];
    end;
  end;
  result:=Trim(result);
end;

// добовляет символ в строку редактирования
procedure TCalcpForm.AddEditStr(ch: string);
begin
  EditStr1.Text := EditStr1.Text +ch;
  // установка на последнию позицию
  EditStr1.SelStart:=Length(EditStr1.Text);
end;

procedure TCalcpForm.Calc();
var
  sm_calc: Currency;
begin
  EditNum1.Text:='0';
  EditStr1.Text:=ReplDelim(EditStr1.Text);
  // установка на последнию позицию
  EditStr1.SelStart:=Length(EditStr1.Text);

  if CreatePZ(EditStr1.Text) then
    if not Calculate(sm_calc) then EditNum1.Text:='0'
    else EditNum1.Text := Format('%n',[sm_calc]);

  if (ListBox1.Items.IndexOf(EditStr1.Text)<0) and (Length(EditStr1.Text)>0) then begin
//    Inc(cn);

    ListBox1.Items.Append(EditStr1.Text);
//    ListBox1.Items.Append( Format('%-8s%s',[IntToStr(cn)+':',EditStr1.Text]));

//    if (EditNum1.Value<>0) and (ListBox1.Items.IndexOf(EditNum1.Text)<0) then
    if (EditNum1.Text <>'0') then
//      ListBox1.Items.Append(Format('%27s',[EditNum1.Text]));
      ListBox1.Items.Append('         '+EditNum1.Text);
//      ListBox1.Items.Append(Format('%9s%s',['',EditNum1.Text]));
//      ListBox1.Items.Append( CurrToStr(EditNum1.Value));
  end;

  EditStr1.SetFocus;

end;



procedure TCalcpForm.EditStr1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
  VK_RETURN: Calc();
  VK_F9: Calc();
  VK_ESCAPE:  begin
                ListBox1.SetFocus;
                ListBox1.ItemIndex:=ListBox1.Count-1;
              end;
  end;


end;

procedure TCalcpForm.EditStr1KeyPress(Sender: TObject; var Key: Char);
begin
  if (Key=#13) or (Key=#27) then Key:=#0;

 if not (Key in ['0','1','2','3','4','5','6','7','8','9','+','-','*','/','(',')','.',',']) then Key:=#0;

 if Key=',' then Key:=DecimalSeparator;
 if Key='.' then Key:=DecimalSeparator;

end;

procedure TCalcpForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
//  NewWidth:=305;

end;

procedure TCalcpForm.FormCreate(Sender: TObject);
begin
//  Left:=Screen.Width-305;
//  Top:=0;
//  Height:=Screen.Height-200;
//  Top:=Screen.Height-250;

//  EditStr1.AllowedChars:=['0','1','2','3','4','5','6','7','8','9','+','-','*','/','(',')','.',','];
end;

procedure TCalcpForm.ListBox1DblClick(Sender: TObject);
begin
//  if (ListBox1.Items.Count>0) and ( Length(ListBox1.Items.Strings[ListBox1.ItemIndex])>0) then
//    EditStr1.Text:= srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');

  try
    if (ListBox1.Items.Count>0) and (ListBox1.ItemIndex>=0) and
      (Length(ListBox1.Items.Strings[ListBox1.ItemIndex])>0) and
      ( Trim(ListBox1.Items.Strings[ListBox1.ItemIndex])[1] in ['0'..'9','-','(']) then
      EditStr1.Text:= srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');
  except
    ListBox1.SetFocus;
    MessageBeep(0);
  end;


//  if (ListBox1.Items.Count>0) and
//  (Length(ListBox1.Items.Strings[ListBox1.ItemIndex])>0) and
//  ( Trim(ListBox1.Items.Strings[ListBox1.ItemIndex])[1] in ['0'..'9','-']) then
//    EditStr1.Text:= srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');

end;

procedure TCalcpForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
  VK_ADD: EditStr1.Text:= EditStr1.Text +'+'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');
  VK_SUBTRACT: EditStr1.Text:= EditStr1.Text +'-'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');
  VK_DIVIDE: EditStr1.Text:= EditStr1.Text +'/'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');
  VK_MULTIPLY: EditStr1.Text:= EditStr1.Text +'*'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');
  VK_SPACE: EditStr1.Text:= srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');
  VK_RETURN: Calc();
  VK_ESCAPE: EditStr1.SetFocus;
  VK_F8: ListBox1.Items.Clear;
  end;

end;

procedure TCalcpForm.N1Click(Sender: TObject);
begin
  EditStr1.Text:= EditStr1.Text +'*'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');

end;

procedure TCalcpForm.N2Click(Sender: TObject);
begin
  EditStr1.Text:= EditStr1.Text +'-'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');

end;

procedure TCalcpForm.N3Click(Sender: TObject);
begin
  EditStr1.Text:= EditStr1.Text +'+'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');

end;

procedure TCalcpForm.N4Click(Sender: TObject);
begin
  EditStr1.Text:= EditStr1.Text +'/'+ srDeleteCharStr(ListBox1.Items.Strings[ListBox1.ItemIndex],' ');

end;

procedure TCalcpForm.N6Click(Sender: TObject);
begin
//  if EditNum1.NbDec<4 then
//    EditNum1.NbDec:=EditNum1.NbDec+1;

end;

procedure TCalcpForm.N7Click(Sender: TObject);
begin
//  if EditNum1.NbDec>0 then
//    EditNum1.NbDec:=EditNum1.NbDec-1;

end;

procedure TCalcpForm.N8Click(Sender: TObject);
begin
  ListBox1.Items.Add('');
  ListBox1.Items.Add('вес (кг) / рост*рост (м)');
  ListBox1.Items.Add('Если результат = 18 - 25');
  ListBox1.Items.Add('значит Вы в хорошей форме.');
  ListBox1.Items.Add('');
  EditStr1.Text:='65/(1.68*1.68)';

end;

procedure TCalcpForm.SpeedButton10Click(Sender: TObject);
begin
  AddEditStr('5');
end;

procedure TCalcpForm.SpeedButton11Click(Sender: TObject);
begin
  AddEditStr('6');
end;

procedure TCalcpForm.SpeedButton12Click(Sender: TObject);
begin
  AddEditStr('7');
end;

procedure TCalcpForm.SpeedButton13Click(Sender: TObject);
begin
  AddEditStr('9');
end;

procedure TCalcpForm.SpeedButton14Click(Sender: TObject);
begin
  AddEditStr('0');
end;

procedure TCalcpForm.SpeedButton15Click(Sender: TObject);
begin
  AddEditStr('.');
end;

procedure TCalcpForm.SpeedButton16Click(Sender: TObject);
begin
  EditStr1.Text := Copy(EditStr1.Text,1,Length(EditStr1.Text)-1);

  // установка на последнию позицию
  EditStr1.SelStart:=Length(EditStr1.Text);

  // выдиление вводимого текста
//  keybd_event(VK_SHIFT,0,0,0);
//  keybd_event(VK_HOME,0,0,0);
//  keybd_event(VK_HOME,0,KEYEVENTF_KEYUP,0);
//  keybd_event(VK_SHIFT,0,KEYEVENTF_KEYUP,0);

end;

procedure TCalcpForm.SpeedButton17Click(Sender: TObject);
begin
  Calc();
//  EditNum1.Enabled:=tRUE;
end;

procedure TCalcpForm.SpeedButton18Click(Sender: TObject);
begin
  EditStr1.Text := '';
  EditStr1.SelStart:=Length(EditStr1.Text);
end;

procedure TCalcpForm.SpeedButton19Click(Sender: TObject);
begin
//  if EditNum1.NbDec<4 then
//    EditNum1.NbDec:=EditNum1.NbDec+1;

end;

procedure TCalcpForm.SpeedButton1Click(Sender: TObject);
begin
  AddEditStr('/');
end;

procedure TCalcpForm.SpeedButton20Click(Sender: TObject);
begin
//  if EditNum1.NbDec>0 then
//    EditNum1.NbDec:=EditNum1.NbDec-1;

end;

procedure TCalcpForm.SpeedButton2Click(Sender: TObject);
begin
  AddEditStr('*');
end;

procedure TCalcpForm.SpeedButton3Click(Sender: TObject);
begin
  AddEditStr('-');
end;

procedure TCalcpForm.SpeedButton4Click(Sender: TObject);
begin
  AddEditStr('+');
end;

procedure TCalcpForm.SpeedButton5Click(Sender: TObject);
begin
  AddEditStr('1');
end;

procedure TCalcpForm.SpeedButton6Click(Sender: TObject);
begin
  AddEditStr('2');
end;

procedure TCalcpForm.SpeedButton7Click(Sender: TObject);
begin
  AddEditStr('3');
end;

procedure TCalcpForm.SpeedButton8Click(Sender: TObject);
begin
  AddEditStr('4');
end;

procedure TCalcpForm.SpeedButton9Click(Sender: TObject);
begin
  AddEditStr('8');
end;

end.
