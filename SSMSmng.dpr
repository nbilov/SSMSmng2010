program SSMSmng;

uses
  Forms,
  EWMain in 'EWMain.pas' {FormWindows},
  uMyTh in 'uMyTh.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormWindows, FormWindows);
  Application.Run;
end.
