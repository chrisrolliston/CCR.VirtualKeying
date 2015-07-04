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

unit CCR.VirtualKeying.Mac;

interface

{$IFDEF MACOS}
uses
  MacApi.CocoaTypes, MacApi.CoreFoundation, MacApi.CoreGraphics, MacApi.KeyCodes,
  System.SysUtils, System.Classes, System.Generics.Collections, System.UITypes,
  CCR.VirtualKeying;

type
  IMacVirtualKeySequence = interface
  ['{C4658C26-D73E-434E-89CC-77816BC1375B}']
    function Add(KeyCode: CGKeyCode; EventType: TVirtualKeyEventType): CGEventRef; overload;
    function GetEventSourceRef: CGEventSourceRef;
    property EventSourceRef: CGEventSourceRef read GetEventSourceRef;
  end;

  TMacVirtualKeySequence = class(TVirtualKeySequenceBase, IVirtualKeySequence, IMacVirtualKeySequence)
  strict private
    FEventRefs: TList<CGEventRef>;
    FEventSourceRef: CGEventSourceRef;
  protected
    function Add(KeyCode: CGKeyCode; EventType: TVirtualKeyEventType): CGEventRef; overload;
    function Add(Key: Word; Shift: TShiftState;
      const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; override;
    function Add(Ch: Char;
      const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; override;
    function Execute: IVirtualKeySequence;
    function GetEventSourceRef: CGEventSourceRef;
  public
    constructor Create; overload;
    constructor Create(stateID: CGEventSourceStateID); overload;
    destructor Destroy; override;
  end;

function VkToCGKeyCode(VkCode: Word): CGKeyCode;
function ShiftStateToCGEventFlags(Shift: TShiftState): CGEventFlags; inline;
{$ENDIF}

implementation

{$IFDEF MACOS}
uses
  System.RTLConsts, CCR.VirtualKeying.Consts;

function VkToCGKeyCode(VkCode: Word): CGKeyCode;
begin
  case VkCode of
    0: Result := 0;
    vkF1: Result := KEY_F1;
    vkF2: Result := KEY_F2;
    vkF3: Result := KEY_F3;
    vkF4: Result := KEY_F4;
    vkF5: Result := KEY_F5;
    vkF6: Result := KEY_F6;
    vkF7: Result := KEY_F7;
    vkF8: Result := KEY_F8;
    vkF9: Result := KEY_F9;
    vkF10: Result := KEY_F10;
    vkF11: Result := KEY_F11;
    vkF12: Result := KEY_F12;
    vkF13: Result := KEY_F13;
    vkF14: Result := KEY_F14;
    vkF15: Result := KEY_F15;
    vkF16: Result := KEY_F16;
    vkF17: Result := KEY_F17;
    vkF18: Result := KEY_F18;
    vkF19: Result := KEY_F19;
    vkF20: Result := KEY_F20;
    vkTab: Result := KEY_TAB;
    vkInsert: Result := KEY_INS;
    vkDelete: Result := KEY_DEL;
    vkHome: Result := KEY_HOME;
    vkEnd: Result := KEY_END;
    vkPrior: Result := KEY_PAGUP;
    vkNext: Result := KEY_PAGDN;
    vkUp: Result := KEY_UP;
    vkDown: Result := KEY_DOWN;
    vkLeft: Result := KEY_LEFT;
    vkRight: Result := KEY_RIGHT;
    vkNumLock: Result := KEY_NUMLOCK;
    vkBack: Result := KEY_BACKSPACE;
    vkReturn: Result := KEY_ENTER;
    vkEscape: Result := KEY_ESC;
    vkSpace: Result := KEY_SPACE;
    vkNumpad0: Result := KEY_NUMPAD0;
    vkNumpad1: Result := KEY_NUMPAD1;
    vkNumpad2: Result := KEY_NUMPAD2;
    vkNumpad3: Result := KEY_NUMPAD3;
    vkNumpad4: Result := KEY_NUMPAD4;
    vkNumpad5: Result := KEY_NUMPAD5;
    vkNumpad6: Result := KEY_NUMPAD6;
    vkNumpad7: Result := KEY_NUMPAD7;
    vkNumpad8: Result := KEY_NUMPAD8;
    vkNumpad9: Result := KEY_NUMPAD9;
    vkDivide: Result := KEY_PADDIV;
    vkMultiply: Result := KEY_PADMULT;
    vkSubtract: Result := KEY_PADSUB;
    vkAdd: Result := KEY_PADADD;
    vkDecimal: Result := KEY_PADDEC;
    vkSemicolon: Result := KEY_SEMICOLON;
    vkEqual: Result := KEY_EQUAL;
    vkComma: Result := KEY_COMMA;
    vkMinus: Result := KEY_MINUS;
    vkPeriod: Result := KEY_PERIOD;
    vkSlash: Result := KEY_SLASH;
    vkTilde: Result := KEY_TILDE;
    vkLeftBracket: Result := KEY_LEFTBRACKET;
    vkBackslash: Result := KEY_BACKSLASH;
    vkRightBracket: Result := KEY_RIGHTBRACKET;
    vkQuote: Result := KEY_QUOTE;
    vkPara: Result := KEY_PARA;
    vk1: Result := KEY_1;
    vk2: Result := KEY_2;
    vk3: Result := KEY_3;
    vk4: Result := KEY_4;
    vk5: Result := KEY_5;
    vk6: Result := KEY_6;
    vk7: Result := KEY_7;
    vk8: Result := KEY_8;
    vk9: Result := KEY_9;
    vk0: Result := KEY_0;
    vkQ: Result := KEY_Q;
    vkW: Result := KEY_W;
    vkE: Result := KEY_E;
    vkR: Result := KEY_R;
    vkT: Result := KEY_T;
    vkY: Result := KEY_Y;
    vkU: Result := KEY_U;
    vkI: Result := KEY_I;
    vkO: Result := KEY_O;
    vkP: Result := KEY_P;
    vkA: Result := KEY_A;
    vkS: Result := KEY_S;
    vkD: Result := KEY_D;
    vkF: Result := KEY_F;
    vkG: Result := KEY_G;
    vkH: Result := KEY_H;
    vkJ: Result := KEY_J;
    vkK: Result := KEY_K;
    vkL: Result := KEY_L;
    vkZ: Result := KEY_Z;
    vkX: Result := KEY_X;
    vkC: Result := KEY_C;
    vkV: Result := KEY_V;
    vkB: Result := KEY_B;
    vkN: Result := KEY_N;
    vkM: Result := KEY_M;
    vkOem102: Result := KEY_CURRENCY;
  else
    raise EArgumentOutOfRangeException.CreateResFmt(@SUnrecognizedVirtualKeyCode, [VkCode]);
  end;
end;

function ShiftStateToCGEventFlags(Shift: TShiftState): CGEventFlags;
begin
  Result := 0;
  if ssAlt in Shift then Result := Result or kCGEventFlagMaskAlternate;
  if ssCommand in Shift then Result := Result or kCGEventFlagMaskCommand;
  if ssCtrl in Shift then Result := Result or kCGEventFlagMaskControl;
  if ssShift in Shift then Result := Result or kCGEventFlagMaskShift;
end;

{ TMacVirtualKeySequence }

constructor TMacVirtualKeySequence.Create;
begin
  Create(kCGEventSourceStateHIDSystemState);
end;

constructor TMacVirtualKeySequence.Create(stateID: CGEventSourceStateID);
begin
  inherited Create;
  FEventRefs := TList<CGEventRef>.Create;
  FEventSourceRef := CGEventSourceCreate(stateID);
  if FEventSourceRef = nil then RaiseLastOSError;
end;

destructor TMacVirtualKeySequence.Destroy;
var
  Ref: CGEventRef;
begin
  for Ref in FEventRefs do
    CFRelease(Ref);
  FEventRefs.Free;
  if FEventSourceRef <> nil then CFRelease(FEventSourceRef);
  inherited;
end;

function TMacVirtualKeySequence.Add(KeyCode: CGKeyCode; EventType: TVirtualKeyEventType): CGEventRef;
const
  KeyDownFlags: array[TVirtualKeyEventType] of Integer = (1, 0);
begin
  Result := CGEventCreateKeyboardEvent(FEventSourceRef, KeyCode, KeyDownFlags[EventType]);
  if Result = nil then RaiseLastOSError;
  FEventRefs.Add(Result);
end;

function TMacVirtualKeySequence.Add(Key: Word; Shift: TShiftState;
  const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence;
var
  EventType: TVirtualKeyEventType;
  MacKey: CGKeyCode;
  MacFlags: CGEventFlags;
begin
  MacKey := VkToCGKeyCode(Key);
  MacFlags := ShiftStateToCGEventFlags(Shift);
  for EventType in EventTypes do
    CGEventSetFlags(Add(MacKey, EventType), MacFlags);
  Result := Self;
end;

function TMacVirtualKeySequence.Add(Ch: Char;
  const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence;
var
  EventType: TVirtualKeyEventType;
  Key: CGKeyCode;
  Flags: CGEventFlags;
  Ref: CGEventRef;
begin
  Flags := 0;
  case Ch of
    'A'..'Z':
    begin
      Key := VkToCGKeyCode(Ord(Ch));
      Flags := kCGEventFlagMaskShift;
    end;
    'a'..'z': Key := VkToCGKeyCode(Ord(UpCase(Ch)));
    #9, #13, ' ', '0'..'9': Key := VkToCGKeyCode(Ord(Ch));
    '-': Key := KEY_MINUS;
    '_':
    begin
      Key := KEY_MINUS;
      Flags := kCGEventFlagMaskShift;
    end;
    '=': Key := KEY_EQUALS;
    '+': Key := KEY_ADD;
    '[': Key := KEY_LEFTBRACKET;
    ']': Key := KEY_RIGHTBRACKET;
    '''': Key := KEY_QUOTE;
    ';': Key := KEY_SEMICOLON;
    ',': Key := KEY_COMMA;
    '\': Key := KEY_BACKSLASH;
    '/': Key := KEY_SLASH;
    '.': Key := KEY_PERIOD;
    '~': Key := KEY_TILDE;
    '*': Key := KEY_MULTIPLY;
  else
    Key := 0;
  end;
  for EventType in EventTypes do
  begin
    Ref := Add(Key, EventType);
    if Flags <> 0 then CGEventSetFlags(Ref, Flags);
    CGEventKeyboardSetUnicodeString(Ref, 1, @Ch);
  end;
  Result := Self;
end;

function TMacVirtualKeySequence.Execute: IVirtualKeySequence;
var
  Ref: CGEventRef;
begin
  for Ref in FEventRefs do
    CGEventPost(kCGHIDEventTap, Ref);
  Result := Self;
end;

function TMacVirtualKeySequence.GetEventSourceRef: CGEventSourceRef;
begin
  Result := FEventSourceRef;
end;

initialization
  TVirtualKeySequence.SetDefaultImplementation<TMacVirtualKeySequence>;
{$ENDIF}
end.
