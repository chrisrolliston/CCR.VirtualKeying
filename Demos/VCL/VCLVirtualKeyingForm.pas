unit VCLVirtualKeyingForm;

interface

uses
  WinApi.Windows, WinApi.Messages, System.SysUtils, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls,
  CCR.VirtualKeying;

type
  TForm1 = class(TForm)
    lblCharsToType: TLabel;
    edtCharsToType: TEdit;
    btnTypeInEdit: TButton;
    btnTypeIn10Secs: TButton;
    edtTarget: TEdit;
    btnDoAppExitHotkey: TButton;
    tmrType: TTimer;
    procedure btnTypeInEditClick(Sender: TObject);
    procedure btnTypeIn10SecsClick(Sender: TObject);
    procedure btnDoAppExitHotkeyClick(Sender: TObject);
    procedure tmrTypeTimer(Sender: TObject);
  strict private
    FCountdown: Integer;
    FDoneTypeIn10SecsMsg: Boolean;
    FSequenceToTypeOnTimer: IVirtualKeySequence;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

resourcestring
  STypeIn10SecsMsg = '10 seconds after you click OK, whatever is the active window will have ''' +
    '%s'' typed into it - try bringing up Notepad or TextEdit, for example.';

procedure TForm1.btnTypeInEditClick(Sender: TObject);
begin
  edtTarget.SetFocus;
  TVirtualKeySequence.Execute(edtCharsToType.Text);
end;

procedure TForm1.btnDoAppExitHotkeyClick(Sender: TObject);
begin
  TVirtualKeySequence.Execute(ShortCut(VK_F4, [ssAlt]));
end;

procedure TForm1.btnTypeIn10SecsClick(Sender: TObject);
begin
  if not FDoneTypeIn10SecsMsg then
  begin
    FDoneTypeIn10SecsMsg := True;
    MessageDlg(Format(STypeIn10SecsMsg, [edtCharsToType.Text]), TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbOK], 0);
  end;
  FSequenceToTypeOnTimer := TVirtualKeySequence.Create;
  FSequenceToTypeOnTimer.AddKeyPresses(edtCharsToType.Text);
  FCountdown := 11;
  tmrTypeTimer(nil);
  tmrType.Enabled := True;
end;

procedure TForm1.tmrTypeTimer(Sender: TObject);
begin
  Dec(FCountdown);
  if FCountdown > 0 then
    Caption := Format('%ds to go...', [FCountdown])
  else
  begin
    tmrType.Enabled := False;
    FSequenceToTypeOnTimer.Execute;
    FSequenceToTypeOnTimer := nil;
    Caption := 'Typed!'
  end
end;

end.
