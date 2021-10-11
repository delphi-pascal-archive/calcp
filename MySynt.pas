unit MySynt;

interface

uses Classes;

type

TData = record
  name: String[20];   // ShortString
  data: Currency;
end;


var
  nConst: Integer=34;         // макслимальное кол.числовых констант
  ErrorList: TStringList;     // массив собщений об ошибках
  PZ: array of Integer;       // массив польской записи
  DataList: array of TData;   // массив значений и имен и констант

  procedure SyntItem(s: string; first: Boolean=False; pos: Integer=1);
  procedure ClearPZ();
  function CreatePZ(s: string): Boolean;   // формирование польск. зап.
  function Calculate(var r: Currency): Boolean;
  function SetData(name: string; data: Currency): Boolean;
  function GetData(name: string; var data: Currency): Boolean;


implementation

//uses SysUtils, Math, Dialogs;
uses SysUtils, Math;

type
  TType = (None,Number,Divider,Ident,Func,Part,All);    // тип ликсемы

  // тип записи с характеристиками прочитанной ликсемы
  TSynt = record
    Mode: TType;
    Number: Currency;
    Ident: String[20];
    Error: Boolean;
    Pos1,Pos2: Integer;
  end;

const
  SetNum: set of Char = ['0'..'9',',','.'];
  SetDiv: set of Char = [';','(',')','=','+','-','/','*','^',' ',#13];
  SetChar: set of Char = ['a'..'z','A'..'Z','а'..'п','р'..'я','А'..'Я','_'];

  mConst = 1;
  nFunc = 1;
  Functions: array[1..nFunc] of string = ('exp');

var
  sItem: TSynt;               // характеристика прочитанной лексемы
  p: Integer;                 // текущая пзиция трансляции
  TrStack: array of Char;     // стек используемый при трансляции
  ConstList: array of Currency;   // массив чисел VarList




{  чтение очередной лексемы
    first = True - первое обращение
    pos - позиция пр первом обращении  }
procedure SyntItem(s: string; first: Boolean=False; pos: Integer=1);
var
  i: Integer;
begin
  if Length(s)=0 then begin
    sItem.Mode:=All;
    Exit;
  end;

  if (first) then p:=pos;

  // пропуск коментариев и пробелов
  repeat
    // пропуск коментариев
    if (s[p]='{') then begin
      repeat
        Inc(p);
      until (p>=Length(s)) or (s[p]='}');
      Inc(p);

    end;
    // пропуск пробелов и переводя строки
    if (p<=Length(s)) then
      while (p<=Length(s)) and ((s[p]=' ') or (s[p]=#13) or (s[p]=#10) or (s[p]=#0)) do Inc(p);

  until (p>=Length(s)) or (s[p]<>'{');

  sItem.Error:=False;
  sItem.Pos1:=p;

  // если p> длины стрлки, то уход и mode = All
  if (p>Length(s)) then begin
    sItem.Mode:=All;
    Exit;
  end;

  // занесение текущего символа в Ident
  sItem.Ident:=s[p];
  if s[p] in SetChar then
    sItem.Mode:=Ident
  else if (s[p] in SetNum) then
    sItem.Mode:=Number
  else if s[p] in SetDiv then begin
    if (s[p]<>';') then sItem.Mode:=Divider
    else sItem.Mode:=Part;
    // переход к следующей позиции
    Inc(p);
    Exit;
  end else begin
    // реизвестный символ
    sItem.Mode:=None;
    Inc(p);
    Exit;
  end;;

  // продолжение ввода
  repeat
    // переход к следующей позиции
    Inc(p);
//    if (sItem.Mode=Number) and ((s[p]='-') or (s[p]='+')) and (UpCase(s[p-1])='E') then sItem.Ident:=sItem.Ident+s[p]
//    else if (p>Length(s)) or (s[p] in SetDiv) then begin

    if (p>Length(s)) or (s[p] in SetDiv) then begin

      // окончание идентификатора или числа
      if (sItem.Mode=Number) then
        try
          sItem.Number:=StrToCurrDef(sItem.Ident,0)
        except
          // перехват исключения при ошибочном числе
          on EConvertError do sItem.Error:=True;
        end;

      // проверка существует ли функция
      for i:=1 to nFunc do
        if (AnsiLowerCase(sItem.Ident)=Functions[i]) then begin
          sItem.Mode:=Func;
          sItem.Number:=i;
          Break;
        end;

      // выход
      sItem.Pos2:=p-1;
      Exit;
    end else sItem.Ident:=sItem.Ident+s[p];

//    ShowMessage('Ident =  '+sItem.Ident+'  '+s[p]+'  '+IntToStr(p));

  until (False);

//  ShowMessage('end2  '+sItem.Ident);
end;


// очистка польской записи
procedure ClearPZ();
begin
  ErrorList.Clear;
  SetLength(ConstList,0);
  SetLength(DataList, mConst);
  SetLength(PZ,0);
end;


// формирование польской записи
function CreatePZ(s: string): Boolean;   // формирование польск. зап.
var
  lend: Boolean;
  i: Integer;
  Assign: Boolean;      // допустимость операции
  Adress: Integer;      // адрес пересылки результата
  OldMode: TType;       // Характер предыдущей лексемы
  oldS: Char;           // Первый символ предыдущей лексемы

  // запись в стек кода арифмитической операции
  procedure Code();
  begin
    SetLength(PZ,High(PZ)+2);
    case TrStack[High(TrStack)] of
      '+': PZ[High(PZ)] := -1;
      '-': PZ[High(PZ)] := -2;
      '*': PZ[High(PZ)] := -3;
      '/': PZ[High(PZ)] := -4;
      '^': PZ[High(PZ)] := -5;
      'M': PZ[High(PZ)] := -6;
    end;
  end;

  procedure Proc1();    // занести лексему и прочитать следующию
  begin
    SetLength(TrStack, High(TrStack)+2);
    TrStack[High(TrStack)] := sItem.Ident[1];
  end;

  procedure Proc2();
  begin
    Code();
    TrStack[High(TrStack)] := sItem.Ident[1];
  end;

  procedure Proc3();
  begin
    Code();
    SetLength(TrStack, High(TrStack));
    lend:=False;
  end;

  procedure Proc4();
  begin
    SetLength(TrStack, High(TrStack));
  end;

  procedure Proc5();    // аналог Proc1 для функций
  begin
    SetLength(TrStack, High(TrStack)+2);
    TrStack[High(TrStack)] := Chr(127+Round(sItem.Number));
  end;

  procedure Proc6();    // аналог Proc3 для функций
  begin
    SetLength(PZ, High(PZ)+2);
    PZ[High(PZ)] := -Ord(TrStack[High(TrStack)])+27;
    SetLength(TrStack, High(TrStack));
  end;

begin
  ClearPZ();
  
  SetLength(TrStack,1);
  TrStack[0]:='0';
  OldMode:=None;
  OldS:=' ';
  Assign:=True;
  Adress:=0;

  SyntItem(s, True);      // чтение первой лексемы
  if (sItem.Mode = All) then begin
    ErrorList.Add('Не введено ни какого текста');
    result:=False;
    Exit;
  end;

  repeat
    if (OldMode = Func) and (sItem.Ident[1]<>'(') then
      ErrorList.Add('Пропущена скобка после функции в позиции ' + IntToStr(sItem.Pos1));

    case sItem.Mode of
    Number: begin
              if ((OldMode=Divider) and (OldMode=None) and (OldMode=Part)) then
                ErrorList.Add('В позиции '+IntToStr(sItem.Pos1)+' должен быть разделмтель');

              if sItem.Error then ErrorList.Add('Ошибка в позициях '+IntToStr(sItem.Pos1)+' - '+IntToStr(sItem.Pos2))
              else begin
                SetLength(ConstList, High(ConstList)+2);
                ConstList[High(ConstList)]:=sItem.Number;
                SetLength(PZ,High(PZ)+2);
                PZ[High(PZ)]:=High(ConstList);
              end;
              Assign:=False;
            end;

    Ident:  begin
              if ((OldMode<>Divider) and (OldMode<>None) and (OldMode<>Part)) then
                ErrorList.Add('В позиции '+IntToStr(sItem.Pos1)+' должен быть разделмтель');

              for i:=0 to High(DataList) do begin
                if (AnsiUpperCase(sItem.Ident)=DataList[i].name) then begin
                  SetLength(PZ,High(PZ)+2);
                  PZ[High(PZ)]:=nConst+i;
                  Break;
                end;
                if i=High(DataList) then begin
                  SetLength(DataList, High(DataList)+2);
                  DataList[High(DataList)].name:=AnsiUpperCase(sItem.Ident);
                  DataList[High(DataList)].data:=0;
                  SetLength(PZ,High(PZ)+2);
                  PZ[High(PZ)]:=nConst+High(DataList);
                end;
              end;
            end;

    All,Part: begin
                repeat
                  lend:=True;
                  case TrStack[High(TrStack)] of
                  '0':  begin
                          if Adress<>0 then begin
                            //занесение в польскую запись операции =
                            // и адреса ссылки результата
                            SetLength(PZ,High(PZ)+3);
                            PZ[High(PZ)-1]:= -7;
                            PZ[High(PZ)]:=Adress;
                            Adress:=0;
                          end;
                          Break;
                        end;
                  '(': ErrorList.Add('Лишняя скобка');
                  else Proc3();
                  end;
                until lend;

                if ErrorList.Count=0 then result:=True
                else result:=False;

                if sItem.Mode=All then Exit
                else begin
                  Assign:=True;
                  sItem.Mode:=None;
                end;
              end;

    Divider:  begin
//              if ((OldMode=Divider) and (OldMode='(') and (OldMode=')')) then begin
//                ErrorList.Add('В позиции '+IntToStr(sItem.Pos1)+' подрят символы');
//                Break;
//              end;

                repeat
                  lend:=True;
                  case sItem.Ident[1] of
                  '=':  if Assign and (OldMode=Ident) then begin
                          Adress:=PZ[High(PZ)];
                          SetLength(PZ,High(PZ));
                          sItem.Mode:=None;
                        end else ErrorList.Add('Позиция '+IntToStr(sItem.Pos1)+' символ "=" недопустим');

                  '(':  if (OldMode=Ident) or (OldMode=Number) then ErrorList.Add('Ошибка скобки')
                        else Proc1();

                '+','-','M':  begin
                              if (OldMode=None) or (OldS='(') then
                                if sItem.Ident[1]='+' then Break
                                else sItem.Ident[1]:='M';

                              case TrStack[High(TrStack)] of
                              '0','(': Proc1();
                              '+','-','M': Proc2();
                              '*','/','^': Proc3();
                              end;
                            end;

                  '*','/':  if OldS='(' then ErrorList.Add('Ошибка')
                            else
                            case TrStack[High(TrStack)] of
                            '0','(','+','-','M': Proc1();
                            '*','/': Proc2();
                            '^': Proc3();
                            end;

                  '^':  if OldS='(' then  ErrorList.Add('Ошибка')
                        else
                        case TrStack[High(TrStack)] of
                        '0','(','+','-','*','/','M': Proc1();
                        '^': Proc2();
                        end;

                  ')':  case TrStack[High(TrStack)] of
                        '0': ErrorList.Add('Лишняя закрытая собка');
                        '(': begin
                              Proc4();
                              if Ord(TrStack[High(TrStack)])>127 then Proc6();
                             end;
                        '+','-','*','/','^','M': Proc3();
                        end;

                  end;

                until lend;
                Assign:=False;

              end;

    Func: begin
            repeat
              lend:=True;
              Proc5();
            until lend;
            Assign:=False;
          end;

    None: ErrorList.Add('Непонятный символ в позиции '+IntToStr(sItem.Pos1));

    end;

    OldMode:=sItem.Mode;
    OldS:=sItem.Ident[1];
    SyntItem(s);

  until (False);

  if ErrorList.Count=0 then result:=True
  else result:=False;

end;



function Calculate(var r: Currency): Boolean;
var
  Stack: array of Currency;
  i: Integer;
begin
  for i:=0 to High(PZ) do begin
    if i>0 then
      if (PZ[i-1]= -7) and (i<High(PZ)) then Continue;
    if PZ[i]< -100 then begin
      // функция
      try
        case -PZ[i]-100 of
        1: Stack[High(Stack)] := Exp(Stack[High(Stack)]);
//        3: Stack[High(Stack)] := Cos(Stack[High(Stack)]);
//        4: Stack[High(Stack)] := Test(Stack[High(Stack)]);
        end;
      except
        result:=False;
        Exit;
      end;

// отключил      
//      if (FloatToStr(Stack[High(Stack)])='NAN') or
//        (FloatToStr(Stack[High(Stack)])='-NAN') or
//        (FloatToStr(Stack[High(Stack)])='INF') or
//        (FloatToStr(Stack[High(Stack)])='-INF') then begin
//          result:=False;
//          Exit;
//        end;

    end else if PZ[i]<0 then begin
//        ShowMessage('Stack =  '+CurrToStr(Stack[High(Stack)-1])+' '+CurrToStr(Stack[High(Stack)]));
      // операция
      try
        case -PZ[i] of
        1: Stack[High(Stack)-1]:=Stack[High(Stack)-1]+Stack[High(Stack)];
        2: Stack[High(Stack)-1]:=Stack[High(Stack)-1]-Stack[High(Stack)];
        3: Stack[High(Stack)-1]:=Stack[High(Stack)-1]*Stack[High(Stack)];
        4: Stack[High(Stack)-1]:=Stack[High(Stack)-1]/Stack[High(Stack)];
        5: Stack[High(Stack)-1]:=Power(Stack[High(Stack)-1],Stack[High(Stack)]);
        6: Stack[High(Stack)]:=-Stack[High(Stack)];
        7: DataList[PZ[i+1]-nConst].data:=Stack[High(Stack)];
        end;
      except
        result:=False;
        Exit;
      end;

      if PZ[i] <> -6 then SetLength(Stack,High(Stack));  // не унарная операция (уменьшение стека)

    end else begin
      SetLength(Stack,High(Stack)+2);
      if PZ[i]<nConst then Stack[High(Stack)]:=ConstList[PZ[i]]
      else Stack[High(Stack)]:=DataList[PZ[i]-nConst].data;

    end;

  end;

  result:=True;
  if ErrorList.Count=0 then r:=Stack[High(Stack)] else r:=-1;
end;



function SetData(name: string; data: Currency): Boolean;
var
  i: Integer;
begin
  for i:=mConst to High(DataList) do
    if AnsiUpperCase(name)=DataList[i].name then begin
      DataList[i].data:=data;
      result:=True;
      Exit;
    end;

  SetLength(DataList, High(DataList)+2);
  DataList[High(DataList)].name:=AnsiUpperCase(name);
  DataList[High(DataList)].data:=data;

  result:=False;
end;


//procedure CreatData(name: string; data: Currency);
//begin
//  SetLength(DataList, High(DataList)+2);
//  DataList[High(DataList)].name:=AnsiUpperCase(name);
//  DataList[High(DataList)].data:=data;
//end;


function GetData(name: string; var data: Currency): Boolean;
var
  i: Integer;
begin
  for i:=0 to High(DataList) do
    if AnsiUpperCase(name)=DataList[i].name then begin
      data:=DataList[i].data;
      result:=True;
      Exit;
    end;
  result:=False;
end;



initialization
  SetLength(DataList, mConst);
  DataList[0].name:='PI';
  DataList[0].data:=3.1415;
//  DataList[1].name:='E';
//  DataList[1].data:=2.7182;

  ErrorList:=TStringList.Create();


finalization
  ErrorList.Free;

end.
