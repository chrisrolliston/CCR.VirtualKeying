unit FMXVirtualKeyingForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Controls.Presentation, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Edit, FMX.StdCtrls, CCR.VirtualKeying;

type
  TfrmVirtualKeyPress = class(TForm)
    btnTypeInEdit: TButton;
    edtTarget: TEdit;
    btnDoAppExitHotkey: TButton;
    lblCharsToSend: TLabel;
    edtCharsToType: TEdit;
    btnTypeIn10Secs: TButton;
    tmrType: TTimer;
    procedure btnTypeInEditClick(Sender: TObject);
    procedure btnDoAppExitHotkeyClick(Sender: TObject);
    procedure btnTypeIn10SecsClick(Sender: TObject);
    procedure tmrTypeTimer(Sender: TObject);
  strict private
    FCountdown: Integer;
    FDoneTypeIn10SecsMsg: Boolean;
    FSequenceToTypeOnTimer: IVirtualKeySequence;
  end;

var
  frmVirtualKeyPress: TfrmVirtualKeyPress;

implementation

{$R *.fmx}

resourcestring
  STypeIn10SecsMsg = '10 seconds after you click OK, whatever is the active window will have ''' +
    '%s'' typed into it - try bringing up Notepad or TextEdit, for example.';

procedure TfrmVirtualKeyPress.btnDoAppExitHotkeyClick(Sender: TObject);
var
  Sequence: IVirtualKeySequence;
begin
  Sequence := TVirtualKeySequence.Create;
  {$IFDEF MACOS}
  Sequence.Add(vkQ, [ssCommand], [keDown, keUp]);
  {$ELSE}
  Sequence.Add(vkF4, [ssAlt], [keDown, keUp]);
  {$ENDIF}
  Sequence.Execute;
end;

procedure TfrmVirtualKeyPress.btnTypeInEditClick(Sender: TObject);
begin
  edtTarget.SetFocus;
  TVirtualKeySequence.Execute(edtCharsToType.Text);
end;

procedure TfrmVirtualKeyPress.btnTypeIn10SecsClick(Sender: TObject);
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

procedure TfrmVirtualKeyPress.tmrTypeTimer(Sender: TObject);
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
