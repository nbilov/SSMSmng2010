unit uMyTh;

interface

uses
  Classes,Windows;

type
  TMyTh = class(TThread)
  private
    { Private declarations }
  public
   TextLen:integer;
   Text:string;
   Wnd:HWND;
   DoneTh:boolean;
   DTWait:TDatetime;
  protected
    procedure Execute; override;
  end;

implementation
uses EWMain, Messages;

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TMyTh.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end;

    or

    Synchronize(
      procedure
      begin
        Form1.Caption := 'Updated in thread via an anonymous method'
      end
      )
    );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TMyTh }

procedure TMyTh.Execute;
begin
  { Place thread code here }
  try
  while not Terminated
  do
  begin
    if DoneTh then
    begin
      Continue
    end;

    TextLen := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0);
    // Устанавливаем длину строковой переменной, которая
    // будет использоваться как буфер для заголовка окна.
    // использование SetLength гарантирует, что будет
    // выделена специальная область памяти, на которую не
    // будет других ссылок.
    SetLength(Text, TextLen);
    // Если заголовок окна - пустая строка, TextLen будет
    // иметь значение 0, и указатель Text при выполнении
    // SetLength получит значение nil. Но при обработке
    // сообщения WM_GETTEXT оконная процедура в любом случае
    // попытается записать строку по переданному адресу,
    // даже если заголовок окна пустой - в этом случае в
    // переданный буфер будет записан один символ -
    // завершающий ноль. Но если будет передан nil, то
    // попытка записать что-то в такой буфер приведёт к
    // Access violation, поэтому отправлять окну WM_GETTEXT
    // можно только в том случае, если TextLen > 0.
    if TextLen > 0 then
      SendMessage(Wnd, WM_GETTEXT, TextLen + 1, LParam(Text));
    DoneTh := True;
  end;
  except
  end;

end;

end.
