program Calcp;

uses
  Forms,
  CalcpUnit in 'CalcpUnit.pas' {CalcpForm},
  MySynt in 'MySynt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCalcpForm, CalcpForm);
  Application.Run;
end.
