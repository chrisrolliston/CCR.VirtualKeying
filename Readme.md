CCR.VirtualKeying
=================

Simple, common interface for entering virtual keystrokes on Windows and OS X usable from a VCL or FMX application. Delegates to SendInput on Windows and the CGEvent functions on OS X.

Example usage
-------------

### Type '¡Hola!' into the active window

    TVirtualKeySequence.Execute('¡Hola!');

### Type 'Привет!' into the active window, then press the 'Select All' shortcut

    uses CCR.VirtualKeying;
    
    //...
    
    var
      Sequence: IVirtualKeySequence;
    begin
      Sequence := TVirtualKeySequence.Create;
      Sequence.AddKeyPresses('Привет!');
      {$IFDEF MACOS}
      Sequence.Add(vkA, [ssCommand], [keDown, keUp]);
      {$ELSE}
      Sequence.Add(vkA, [ssCtrl], [keDown, keUp]);
      {$ENDIF}
      Sequence.Execute;

TVirtualKeySequence reference
-----------------------------

    class function Create: IVirtualKeySequence; static;

Creates a default implementation of the IVirtualKeySequence interface for the current platform.

    class procedure Execute(const Chars: string;
      DelayMSecs: Cardinal = 0); overload; static;

Types the characters in the passed string into the active window. If DelayMSecs is greater than 0, typing is done in a secondary thread after the given number of milliseconds.

    class procedure Execute(const ShortCut: TShortCut;
      DelayMSecs: Cardinal = 0); static; overload;

Types the given short cut in the context of the active window. If DelayMSecs is greater than 0, typing is done in a secondary thread after the given number of milliseconds.

    class procedure SetDefaultImplementation<T: class, constructor,
      IVirtualKeySequence>; static;

For internal use only - sets what is the implementing class used by Create.

IVirtualKeySequence reference
-----------------------------

*In each case the return value is simply a reference to the original interface to allow method chaining if desired.*

    type
      TVirtualKeyEventType = (keDown, keUp);

    function Add(Key: Word; Shift: TShiftState; const EventTypes: array of
      TVirtualKeyEventType): IVirtualKeySequence; overload;

Adds one or more key events to the sequence specified using Delphi's cross-platform vkXXX and TShiftState types (these are what the VCL and FireMonkey use for a control's OnKeyDown and OnKeyUp events). On Windows, vkXXX values are are interchangeable with the Window API's VK_XXX ones; on OS X a mapping is done internally.

Note that for the Shift parameter, only ssAlt, ssCtrl and ssShift elements are taken account of on Windows, and only those and ssCommand on OS X; any others (e.g. ssLeft) are ignored. Also, if EventTypes is an empty array, no event will be added (typically one of [keDown], [keUp] or [keDown, keUp] is passed).

    function Add(Ch: Char; const EventTypes: array of
      TVirtualKeyEventType): IVirtualKeySequence; overload;

Adds one or more key events to the sequence for a given Unicode character. Internally KEYEVENTF_UNICODE is used on Windows and CGEventKeyboardSetUnicodeString on OS X to prevent the character being 'dumbed down' or corrupted into an ASCII character were it to be otherwise originally.

    function AddKeyPresses(const Chars: array of Char): IVirtualKeySequence; overload;

Adds key down/key up pairs for each character in the array to the sequence; equivalent to calling Add for each character and passing [keDown, keUp] for EventTypes.

    function AddKeyPresses(const Chars: string): IVirtualKeySequence; overload;

Adds key down/key up pairs for each character in the string to the sequence; equivalent to calling Add for each character and passing [keDown, keUp] for EventTypes.

    function AddShortCut(const ShortCut: TShortCut): IVirtualKeySequence; overload;

Decomposes ShortCut into its constituent Key and Shift components and calls Add with the result, passing [keDown, keUp] for EventTypes.

    function Execute: IVirtualKeySequence;

Performs the key events previous added to the sequence. If required, Execute can be called multiple times since it does not clear previously added events.
