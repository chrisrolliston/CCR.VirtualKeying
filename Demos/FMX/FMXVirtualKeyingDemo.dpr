program FMXVirtualKeyingDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  CCR.VirtualKeying in '..\..\CCR.VirtualKeying.pas',
  CCR.VirtualKeying.Mac in '..\..\CCR.VirtualKeying.Mac.pas',
  CCR.VirtualKeying.Consts in '..\..\CCR.VirtualKeying.Consts.pas',
  CCR.VirtualKeying.Win in '..\..\CCR.VirtualKeying.Win.pas',
  FMXVirtualKeyingForm in 'FMXVirtualKeyingForm.pas' {frmVirtualKeyPress};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmVirtualKeyPress, frmVirtualKeyPress);
  Application.Run;
end.
