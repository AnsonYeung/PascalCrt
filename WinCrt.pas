{ This unit is a drop in replacement to build-in unit crt }
{$IFNDEF Windows}
	{$Error WinCrt is for Windows only, for other platforms, please use the native crt unit}
{$ENDIF}
Unit WinCrt;
Interface
Uses Math;
Const
Black: Integer = 0;
Blue: Integer = 1;
Green: Integer = 2;
Red: Integer = 4;
Gray: Integer = 8;
Aqua: Integer = 3;
Purple: Integer = 5;
Yellow: Integer = 6;
LightGray: Integer = 7;
LightBlue: Integer = 9;
LightGreen: Integer = 10;
LightRed: Integer = 12;
LightAqua: Integer = 11;
LightPurple: Integer = 13;
LightYellow: Integer = 14;
White: Integer = 15;
v : Char = #186;
h : Char = #205;
cul : Char = #201;
cur : Char = #187;
cll : Char = #200;
clr : Char = #188;

Type
Coord = Record
	X : SmallInt;
	Y : SmallInt;
End;

KEY_EVENT_RECORD = Packed Record
	bKeyDown : LongBool;
	wRepeatCount : Word;
	wVirtualKeyCode : Word;
	wVirtualScanCode : Word;
	Case LongInt Of
		0 : ( UnicodeChar : WChar;
		dwControlKeyState : DWord; );
		1 : ( AsciiChar : Char );
End;

MOUSE_EVENT_RECORD = Record
	dwMousePosition : Coord;
	dwButtonState : DWord;
	dwControlKeyState : DWord;
	dwEventFlags : DWord;
End;

WINDOW_BUFFER_SIZE_RECORD = Record
	dwSize : Coord;
End;

MENU_EVENT_RECORD = Record
	dwCommandId : Cardinal;
End;

FOCUS_EVENT_RECORD = Record
	bSetFocus : LongBool;
End;

INPUT_RECORD = Record
	EventType: Word;
	Reserved: Word;
	Event : Record Case LongInt Of
		0 : ( KeyEvent : KEY_EVENT_RECORD );
		1 : ( MouseEvent : MOUSE_EVENT_RECORD );
		2 : ( WindowBufferSizeEvent : WINDOW_BUFFER_SIZE_RECORD );
		3 : ( MenuEvent : MENU_EVENT_RECORD );
		4 : ( FocusEvent : FOCUS_EVENT_RECORD );
	End;
End;

Procedure InitConsole();
Procedure SetConsoleSize(Const Width: Integer; Const Height: Integer);
Procedure SetConsoleBuffer(Const Width: Integer; Const Height: Integer);
Procedure PollConsoleInput(Var irInBuf: Array Of INPUT_RECORD; Const bufSize: DWord; Var cNumRead: DWord);
Procedure ClrScr();
Procedure SetConsoleColor(Const color: Word);
Procedure TextBackground(Const color: Integer);
Procedure TextColor(Const color: Integer);
Procedure GoToXY(Const X: Integer; Const Y: Integer);
Procedure WriteDup(Const X: Integer; Const Y: Integer; Const c: PChar; Const n: Integer);
Procedure WriteDupAttr(Const X: Integer; Const Y: Integer; Const n: Integer);
Procedure CursorOff();
Procedure CursorOn();
Procedure FlushInput();
Procedure RestoreConsole();

Implementation
Const
LF_FACESIZE = 32;
STD_INPUT_HANDLE = DWord(-10);
STD_OUTPUT_HANDLE = DWord(-11);
STD_ERROR_HANDLE = DWord(-12);
ENABLE_LINE_INPUT = 2;
ENABLE_ECHO_INPUT = 4;
ENABLE_PROCESSED_INPUT = 1;
ENABLE_WINDOW_INPUT = 8;
ENABLE_MOUSE_INPUT = 16;
ENABLE_PROCESSED_OUTPUT = 1;
ENABLE_WRAP_AT_EOL_OUTPUT = 2;
ENABLE_INSERT_MODE = $0020;
ENABLE_QUICK_EDIT_MODE = $0040;
ENABLE_EXTENDED_FLAGS = $0080;
ENABLE_AUTO_POSITION = $0100;
ENABLE_VIRTUAL_TERMINAL_INPUT = $0200;
ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;
DISABLE_NEWLINE_AUTO_RETURN = $0008;
ENABLE_LVB_GRID_WORLDWIDE = $0010;

Type
Handle = System.THandle;
LpDWord = ^DWord;
PINPUTRECORD = ^INPUT_RECORD;
CONSOLE_FONT_INFOEX = Record
	cbSize : Cardinal;
	nFont : DWord;
	dwFontSize : Coord;
	FontFamily : Cardinal;
	FontWeight : Cardinal;
	FaceName : Array[0..(LF_FACESIZE)-1] Of WChar;
End;
PCONSOLE_FONT_INFOEX = ^CONSOLE_FONT_INFOEX;

SMALL_RECT = Record
	Left : SmallInt;
	Top : SmallInt;
	Right : SmallInt;
	Bottom : SmallInt;
End;

CONSOLE_SCREEN_BUFFER_INFO = Packed Record
	dwSize : Coord;
	dwCursorPosition : Coord;
	wAttributes : Word;
	srWindow : SMALL_RECT;
	dwMaximumWindowSize : Coord;
End;
PCONSOLE_SCREEN_BUFFER_INFO = ^CONSOLE_SCREEN_BUFFER_INFO;

CONSOLE_CURSOR_INFO = Record
	dwSize : DWord;
	bVisible : LongBool;
End;
PCONSOLE_CURSOR_INFO = ^CONSOLE_CURSOR_INFO;

Var
hStdin: Handle;
hStdout: Handle;
fdwSaveOldMode: DWord;

Function GetConsoleMode(hConsoleHandle: Handle; lpMode: LpDWord): LongBool; External 'kernel32' Name 'GetConsoleMode';
Function SetConsoleMode(hConsoleHandle: Handle; dwMode: DWord): LongBool; External 'kernel32' Name 'SetConsoleMode';
Function GetCurrentConsoleFontEx(hConsoleOutput: Handle; bMaximumWindow: LongBool; lpConsoleCurrentFontEx: PCONSOLE_FONT_INFOEX): LongBool; StdCall; External 'kernel32' Name 'GetCurrentConsoleFontEx';
Function SetCurrentConsoleFontEx(hConsoleOutput: Handle; bMaximumWindow: LongBool; lpConsoleCurrentFontEx: PCONSOLE_FONT_INFOEX): LongBool; StdCall; External 'kernel32' Name 'SetCurrentConsoleFontEx';
Function GetConsoleScreenBufferInfo(hConsoleOutput: Handle; lpConsoleScreenBufferInfo: PCONSOLE_SCREEN_BUFFER_INFO): LongBool; External 'kernel32' Name 'GetConsoleScreenBufferInfo';
Function SetConsoleWindowInfo(hConsoleOutput: Handle; bAbsolute: LongBool; Var lpConsoleWindow: SMALL_RECT): LongBool; External 'kernel32' Name 'SetConsoleWindowInfo';
Function SetConsoleScreenBufferSize(hConsoleOutput: Handle; dwSize: Coord): LongBool; External 'kernel32' Name 'SetConsoleScreenBufferSize';
Function ReadConsoleInput(hConsoleInput: Handle; lpBuffer: PINPUTRECORD; nLength: DWord; lpNumberOfEventsRead: LpDWord): LongBool; External 'kernel32' Name 'ReadConsoleInputA';
Function FillConsoleOutputCharacter(hConsoleOutput: Handle; cCharacter: Char; nLength: DWord; dwWriteCoord: Coord; lpNumberOfCharsWritten: LpDWord): LongBool; External 'kernel32' Name 'FillConsoleOutputCharacterA';
Function FillConsoleOutputAttribute(hConsoleOutput: Handle; wAttribute: Word; nLength: DWord; dwWriteCoord: Coord; lpNumberOfAttrsWritten: LpDWord): LongBool; External 'kernel32' Name 'FillConsoleOutputAttribute';
Function SetConsoleTextAttribute(hConsoleOutput: Handle; wAttributes: Word): LongBool; External 'kernel32' Name 'SetConsoleTextAttribute';
{Function SetConsoleCursorPosition(hConsoleOutput: Handle; dwCursorPosition: Coord): LongBool; External 'kernel32' Name 'SetConsoleCursorPosition';}
Function WriteConsoleOutputCharacter(hConsoleOutput: Handle; lpCharacter: PChar; nLength: DWord; dwWriteCoord: Coord; lpNumberOfCharsWritten: LpDWord): LongBool; External 'kernel32' Name 'WriteConsoleOutputCharacterA';
Function WriteConsoleOutputAttribute(hConsoleOutput: Handle; lpAttribute: Pointer; nLength: DWord; dwWriteCoord: Coord; lpNumberOfAttrsWritten: LpDWord): LongBool; External 'kernel32' Name 'WriteConsoleOutputAttribute';
Function SetConsoleCursorInfo(hConsoleOutput: Handle; lpConsoleCursorInfo: PCONSOLE_CURSOR_INFO): LongBool; External 'kernel32' Name 'SetConsoleCursorInfo';
Function FlushConsoleInputBuffer(hConsoleInput: Handle): LongBool; External 'kernel32' Name 'FlushConsoleInputBuffer';
Function SetConsoleOutputCP(wCodePageID: Cardinal): LongBool; External 'kernel32' Name 'SetConsoleOutputCP';
Function GetStdHandle(nStdHandle: DWord): Handle; External 'kernel32' Name 'GetStdHandle';
Function GetLastError(): DWord; External 'kernel32' Name 'GetLastError';
Function AttachConsole(dwProcessId: DWord): LongBool; External 'kernel32' Name 'AttachConsole';

Function StrDup(Const str: String; Const cnt: Integer): String;
Var
result: String;
i: Integer;
Begin
	result := '';
	For i := 1 To cnt Do
		result := result + str;
	StrDup := result;
End;

Procedure InitConsole();
Var
fdwMode: DWord;
FontInfo: CONSOLE_FONT_INFOEX;
Begin
	GetConsoleMode(hStdin, @fdwSaveOldMode);
	fdwMode := ENABLE_WINDOW_INPUT Or ENABLE_MOUSE_INPUT Or ENABLE_EXTENDED_FLAGS Or ENABLE_ECHO_INPUT Or ENABLE_LINE_INPUT Or ENABLE_INSERT_MODE;
	SetConsoleMode(hStdin, fdwMode);
	CursorOff();
	FontInfo.cbSize := sizeof(CONSOLE_FONT_INFOEX);
	GetCurrentConsoleFontEx(hStdout, False, @FontInfo);
	FontInfo.FaceName := 'Lucida Console';
	FontInfo.dwFontSize.X := 8;
	FontInfo.dwFontSize.Y := 16;
	SetCurrentConsoleFontEx(hStdout, False, @FontInfo);
	TextBackground(Black);
	TextColor(White);
	ClrScr();
End;

Procedure SetConsoleSize(Const Width: Integer; Const Height: Integer);
Var
ConsoleSize: SMALL_RECT;
CurrentInfo: CONSOLE_SCREEN_BUFFER_INFO;
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	{ Set a buffer size bigger than the console size, this nearly guarantees the success Of setting console size }
	SetConsoleBuffer(Max(CurrentInfo.dwSize.X, Width), Max(CurrentInfo.dwSize.Y, Height));
	{ Then safely set the console size, will fail if the screen is too small }
	ConsoleSize.Top := 0;
	ConsoleSize.Left := 0;
	ConsoleSize.Right := Width - 1;
	ConsoleSize.Bottom := Height - 1;
	SetConsoleWindowInfo(hStdout, True, ConsoleSize);
	{ Set the buffer size to be equal to the console size }
	SetConsoleBuffer(Width, Height);
End;

Procedure SetConsoleBuffer(Const Width: Integer; Const Height: Integer);
Var
BufferSize: Coord;
Begin
	{ Set the buffer size directly, this fails if the buffer size is too small }
	BufferSize.X := Width;
	BufferSize.Y := Height;
	SetConsoleScreenBufferSize(hStdout, BufferSize);
End;

Procedure PollConsoleInput(Var irInBuf: Array Of INPUT_RECORD; Const bufSize: DWord; Var cNumRead: DWord);
Begin
	ReadConsoleInput(hStdin, irInBuf, bufSize, @cNumRead);
End;

Procedure ClrScr();
Var
screen: Coord;
cCharsWritten: DWord;
CurrentInfo: CONSOLE_SCREEN_BUFFER_INFO;
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	screen.X := 0;
	screen.Y := 0;
	FillConsoleOutputCharacter(hStdout, ' ', CurrentInfo.dwSize.X * CurrentInfo.dwSize.Y, screen, @cCharsWritten);
	FillConsoleOutputAttribute(hStdout, CurrentInfo.wAttributes, CurrentInfo.dwSize.X * CurrentInfo.dwSize.Y, screen, @cCharsWritten);
	GoToXY(0, 0);
End;

Procedure SetConsoleColor(Const color: Word);
Begin
	SetConsoleTextAttribute(hStdout, color);
End;

Procedure TextBackground(Const color: Integer);
Var
CurrentInfo: CONSOLE_SCREEN_BUFFER_INFO;
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	SetConsoleColor(CurrentInfo.wAttributes And 15 + color * 16);
End;

Procedure TextColor(Const color: Integer);
Var
CurrentInfo: CONSOLE_SCREEN_BUFFER_INFO;
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	SetConsoleColor(CurrentInfo.wAttributes And 240 + color);
End;

Procedure GoToXY(Const X: Integer; Const Y: Integer);
Var
Loc: Coord;
Begin
	Loc.X := X;
	Loc.Y := Y;
	{SetConsoleCursorPosition(hStdout, Loc);}
End;

Procedure WriteDup(Const X: Integer; Const Y: Integer; Const c: PChar; Const n: Integer);
Var
Loc: Coord;
written: DWord;
Begin
	Loc.X := X;
	Loc.Y := Y;
	WriteConsoleOutputCharacter(hStdout, c, n, Loc, @written);
	WriteDupAttr(X, Y, n);
End;

Procedure WriteDupAttr(Const X: Integer; Const Y: Integer; Const n: Integer);
Var
Loc: Coord;
written: DWord;
CurrentInfo: CONSOLE_SCREEN_BUFFER_INFO;
Attributes: Array Of Word;
i: Integer;
Begin
	Loc.X := X;
	Loc.Y := Y;
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	SetLength(Attributes, n);
	For i := 0 To n - 1 Do
		Attributes[i] := CurrentInfo.wAttributes;
	WriteConsoleOutputAttribute(hStdout, @Attributes[0], n, Loc, @written);
End;

Procedure CursorOff();
Var
cursorInfo: CONSOLE_CURSOR_INFO;
Begin
	cursorInfo.bVisible := False;
	cursorInfo.dwSize := 100;
	SetConsoleCursorInfo(hStdout, @cursorInfo);
End;

Procedure CursorOn();
Var
cursorInfo: CONSOLE_CURSOR_INFO;
Begin
	cursorInfo.bVisible := True;
	cursorInfo.dwSize := 100;
	SetConsoleCursorInfo(hStdout, @cursorInfo);
End;

Procedure FlushInput();
Begin
	FlushConsoleInputBuffer(hStdin);
End;

Procedure RestoreConsole();
Begin
	SetConsoleMode(hStdin, fdwSaveOldMode);
End;

Initialization
	Write('tes');
	SetConsoleOutputCP(437);
	hStdin := GetStdHandle(STD_INPUT_HANDLE);
	Write(GetLastError());
	hStdout := GetStdHandle(STD_OUTPUT_HANDLE);
	Write(GetLastError());
	Write(hStdin = Handle(-1));
	Write(hStdout = Handle(-1));
	InitConsole();
	WriteLn('----t');
Finalization
	RestoreConsole();
End.