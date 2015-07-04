program VCLVirtualKeyingDemo;

uses
  Vcl.Forms,
  CCR.VirtualKeying in '..\..\CCR.VirtualKeying.pas',
  CCR.VirtualKeying.Consts in '..\..\CCR.VirtualKeying.Consts.pas',
  CCR.VirtualKeying.Win in '..\..\CCR.VirtualKeying.Win.pas',
  VCLVirtualKeyingForm in 'VCLVirtualKeyingForm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
