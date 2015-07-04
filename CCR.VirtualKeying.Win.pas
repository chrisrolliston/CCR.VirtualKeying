{**************************************************************************************}
{                                                                                      }
{ CCR.VirtualKeying - sending virtual keystrokes on OS X and Windows                   }
{                                                                                      }
{ The contents of this file are subject to the Mozilla Public License Version 2.0      }
{ (the "License"); you may not use this file except in compliance with the License.    }
{ You may obtain a copy of the License at https://www.mozilla.org/MPL/2.0              }
{                                                                                      }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT   }
{ WARRANTY OF ANY KIND, either express or implied. See the License for the specific    }
{ language governing rights and limitations under the License.                         }
{                                                                                      }
{ The Initial Developer of the Original Code is Chris Rolliston. Portions created by   }
{ Chris Rolliston are Copyright (C) 2015 Chris Rolliston. All Rights Reserved.         }
{                                                                                      }
{**************************************************************************************}

unit CCR.VirtualKeying.Win;

interface

{$IFDEF MSWINDOWS}
uses
  WinApi.Windows,
  System.SysUtils, System.Classes, System.UITypes,
  CCR.VirtualKeying;

type
  IWinVirtualKeySequence = interface(IVirtualKeySequence)
  ['{C7E50F75-649C-432F-B2B4-9EED57F550D3}']
    function Add(Key, Scan: Word; Flags: DWORD; ExtraInfo: ULONG_PTR = 0): IWinVirtualKeySequence; overload;
  end;

  TWinVirtualKeySequence = class(TVirtualKeySequenceBase, IVirtualKeySequence, IWinVirtualKeySequence)
  strict private
    FInputCount: Integer;
    FInputs: array of TInput;
  protected
    function Add(Key, Scan: Word; Flags: DWORD; ExtraInfo: ULONG_PTR = 0): IWinVirtualKeySequence; overload;
    function Add(Key: Word; Shift: TShiftState;
      const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; override;
    function Add(Ch: Char; const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; override;
    function Execute: IVirtualKeySequence;
  public
    constructor Create;
  end;
{$ENDIF}

implementation

{$IFDEF MSWINDOWS}

const
  EventTypeFlags: array[TVirtualKeyEventType] of DWORD = (0, KEYEVENTF_KEYUP);

{ TWinVirtualKeySequence }

constructor TWinVirtualKeySequence.Create;
begin
  inherited Create;
end;

function TWinVirtualKeySequence.Add(Key, Scan: Word; Flags: DWORD; ExtraInfo: ULONG_PTR): IWinVirtualKeySequence;
begin
  if FInputCount = 0 then
    SetLength(FInputs, 2)
  else if Length(FInputs) = FInputCount then
    SetLength(FInputs, FInputCount * 2);
  FInputs[FInputCount].Itype := INPUT_KEYBOARD;
  FInputs[FInputCount].ki.wVk := Key;
  FInputs[FInputCount].ki.wScan := Scan;
  FInputs[FInputCount].ki.dwFlags := Flags;
  FInputs[FInputCount].ki.dwExtraInfo := ExtraInfo;
  Inc(FInputCount);
  Result := Self;
end;

function TWinVirtualKeySequence.Execute: IVirtualKeySequence;
begin
  if FInputCount <> 0 then SendInput(FInputCount, FInputs[0], SizeOf(FInputs[0]));
  Result := Self;
end;

function TWinVirtualKeySequence.Add(Key: Word; Shift: TShiftState;
  const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence;
var
  EventType: TVirtualKeyEventType;

  procedure DoAdd(Key: Word);
  var
    ExtFlags: DWORD;
  begin
    case Key of
      VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_PRIOR, VK_NEXT,
      VK_INSERT, VK_DELETE: ExtFlags := KEYEVENTF_EXTENDEDKEY;
    else ExtFlags := 0;
    end;
    Add(Key, MapVirtualKey(Key, MAPVK_VK_TO_VSC), EventTypeFlags[EventType] or ExtFlags);
  end;
begin
  for EventType in EventTypes do
  begin
    if ssAlt in Shift then DoAdd(VK_MENU);
    if ssCtrl in Shift then DoAdd(VK_CONTROL);
    if ssShift in Shift then DoAdd(VK_SHIFT);
    DoAdd(Key);
  end;
  Result := Self;
end;

function TWinVirtualKeySequence.Add(Ch: Char;
  const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence;
var
  EventType: TVirtualKeyEventType;
begin
  for EventType in EventTypes do
    Add(0, Ord(Ch), KEYEVENTF_UNICODE or EventTypeFlags[EventType]);
  Result := Self;
end;

initialization
  TVirtualKeySequence.SetDefaultImplementation<TWinVirtualKeySequence>;
{$ENDIF}
end.
