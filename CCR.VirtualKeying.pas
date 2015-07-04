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

unit CCR.VirtualKeying;

interface

uses
  System.SysUtils, System.Classes, System.TypInfo, System.Rtti;

type
  TVirtualKeyEventType = (keDown, keUp);

  IVirtualKeySequence = interface
  ['{6625BA86-FFAF-4820-B432-FAE1315F0A16}']
    function Add(Key: Word; Shift: TShiftState; const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; overload;
    function Add(Ch: Char; const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; overload;
    function AddKeyPresses(const Chars: array of Char): IVirtualKeySequence; overload;
    function AddKeyPresses(const Chars: string): IVirtualKeySequence; overload;
    function AddShortCut(const ShortCut: TShortCut): IVirtualKeySequence; overload;
    function Execute: IVirtualKeySequence;
  end;

  TVirtualKeySequenceBase = class(TInterfacedObject)
  protected
    function Add(Key: Word; Shift: TShiftState; const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; overload; virtual; abstract;
    function Add(Ch: Char; const EventTypes: array of TVirtualKeyEventType): IVirtualKeySequence; overload; virtual; abstract;
    function AddKeyPresses(const Chars: array of Char): IVirtualKeySequence; overload;
    function AddKeyPresses(const Chars: string): IVirtualKeySequence; overload;
    function AddShortCut(const ShortCut: TShortCut): IVirtualKeySequence; overload;
  end;

  TVirtualKeySequence = record
  strict private class var
    FDefaultImplementation: TClass;
    FConstructor: TRttiMethod;
    FRttiContext: TRttiContext;
  public
    class function Create: IVirtualKeySequence; static;
    class procedure Execute(const Chars: string; DelayMSecs: Cardinal = 0); overload; static;
    class procedure Execute(const ShortCut: TShortCut; DelayMSecs: Cardinal = 0); overload; static;
    class procedure SetDefaultImplementation<T: class, constructor, IVirtualKeySequence>; static;
  end;

procedure ShortCutToKey(ShortCut: TShortCut; var Key: Word; var Shift: TShiftState);

implementation

uses
  System.SysConst, System.RTLConsts,
{$IFDEF MACOS}
  CCR.VirtualKeying.Mac,
{$ENDIF}
{$IFDEF MSWINDOWS}
  CCR.VirtualKeying.Win,
{$ENDIF}
  CCR.VirtualKeying.Consts;

procedure ShortCutToKey(ShortCut: TShortCut; var Key: Word; var Shift: TShiftState);
begin
  Key := Lo(ShortCut);
  Shift := [];
  if ShortCut and scCommand <> 0 then
    Include(Shift, ssCommand);
  if ShortCut and scShift <> 0 then
    Include(Shift, ssShift);
  if ShortCut and scCtrl <> 0 then
    Include(Shift, ssCtrl);
  if ShortCut and scAlt <> 0 then
    Include(Shift, ssAlt);
end;

{ TVirtualKeySequenceBase }

function TVirtualKeySequenceBase.AddKeyPresses(const Chars: array of Char): IVirtualKeySequence;
var
  Ch: Char;
begin
  for Ch in Chars do
    Add(Ch, [keDown, keUp]);
end;

function TVirtualKeySequenceBase.AddKeyPresses(const Chars: string): IVirtualKeySequence;
var
  Ch: Char;
begin
  for Ch in Chars do
    Add(Ch, [keDown, keUp]);
end;

function TVirtualKeySequenceBase.AddShortCut(const ShortCut: TShortCut): IVirtualKeySequence;
var
  Key: Word;
  Shift: TShiftState;
begin
  ShortCutToKey(ShortCut, Key, Shift);
  Result := Add(Key, Shift, [keDown, keUp]);
end;

{ TVirtualKeySequence }

class function TVirtualKeySequence.Create: IVirtualKeySequence;
begin
  if FConstructor = nil then
    raise ENotSupportedException.CreateRes(@SVirtualKeyingUnsupported);
  Result := FConstructor.Invoke(FDefaultImplementation, []).AsType<IVirtualKeySequence>;
end;

class procedure TVirtualKeySequence.Execute(const Chars: string; DelayMSecs: Cardinal);
var
  Proc: TProc;
begin
  Proc := procedure
          var
            Sequence: IVirtualKeySequence;
          begin
            if DelayMSecs > 0 then Sleep(DelayMSecs);
            Sequence := TVirtualKeySequence.Create;
            Sequence.AddKeyPresses(Chars);
            Sequence.Execute;
          end;
  if DelayMSecs <= 0 then
    Proc()
  else
    TThread.CreateAnonymousThread(Proc).Start;
end;

class procedure TVirtualKeySequence.Execute(const ShortCut: TShortCut; DelayMSecs: Cardinal);
var
  Proc: TProc;
begin
  Proc := procedure
          var
            Sequence: IVirtualKeySequence;
          begin
            if DelayMSecs > 0 then Sleep(DelayMSecs);
            Sequence := TVirtualKeySequence.Create;
            Sequence.AddShortCut(ShortCut);
            Sequence.Execute;
          end;
  if DelayMSecs <= 0 then
    Proc()
  else
    TThread.CreateAnonymousThread(Proc).Start;
end;

class procedure TVirtualKeySequence.SetDefaultImplementation<T>;
var
  LConstructor, Method: TRttiMethod;
begin
  LConstructor := nil;
  for Method in FRttiContext.GetType(TypeInfo(T)).GetMethods do
    if Method.IsConstructor and (Method.Visibility >= mvPublic) and (Method.GetParameters = nil) then
    begin
      LConstructor := Method;
      Break;
    end;
  if LConstructor = nil then raise EInsufficientRtti.CreateRes(@SInsufficientRtti);
  FConstructor := LConstructor;
  FDefaultImplementation := T;
end;

end.
