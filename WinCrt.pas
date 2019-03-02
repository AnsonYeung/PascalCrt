{ This unit is a drop in replacement to build-in unit crt }
{$IFNDEF Windows}
	{$Error WinCrt is for Windows only, for other platforms, please use the native crt unit}
{$ENDIF}
{$inline on}
{$calling stdcall}
{$LINKLIB kernel32}
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

LF_FACESIZE = 32;
STD_INPUT_HANDLE: DWord = DWord(-10);
STD_OUTPUT_HANDLE: DWord = DWord(-11);
STD_ERROR_HANDLE: DWord = DWord(-12);
ENABLE_LINE_INPUT: DWord = 2;
ENABLE_ECHO_INPUT: DWord = 4;
ENABLE_PROCESSED_INPUT: DWord = 1;
ENABLE_WINDOW_INPUT: DWord = 8;
ENABLE_MOUSE_INPUT: DWord = 16;
ENABLE_PROCESSED_OUTPUT: DWord = 1;
ENABLE_WRAP_AT_EOL_OUTPUT: DWord = 2;
ENABLE_INSERT_MODE: DWord = $0020;
ENABLE_QUICK_EDIT_MODE: DWord = $0040;
ENABLE_EXTENDED_FLAGS: DWord = $0080;
ENABLE_AUTO_POSITION: DWord = $0100;
ENABLE_VIRTUAL_TERMINAL_INPUT: DWord = $0200;
ENABLE_VIRTUAL_TERMINAL_PROCESSING: DWord = $0004;
DISABLE_NEWLINE_AUTO_RETURN: DWord = $0008;
ENABLE_LVB_GRID_WORLDWIDE: DWord = $0010;

Type
FACETYPE = Array[0..(LF_FACESIZE)-1] Of WChar;
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

Procedure SetConsoleTitle(Const title: AnsiString);
Procedure SetConsoleFont(Const FaceName: FACETYPE; Const x, y: Integer);
Procedure SetConsoleSize(Const Width: Integer; Const Height: Integer);
Procedure SetConsoleBuffer(Const Width: Integer; Const Height: Integer);
Procedure PollConsoleInput(Var irInBuf: Array Of INPUT_RECORD; Const bufSize: DWord; Var cNumRead: DWord);
Procedure ClrScr();
Procedure SetConsoleColor(Const color: Word);
Procedure TextBackground(Const color: Integer);
Procedure TextColor(Const color: Integer);
Procedure GoToXY(Const x, y: Integer);
Procedure Read(Var s: Array Of Char; Var numRead: DWord);
Procedure ReadLn(Var s: Array Of Char; Var numRead: DWord);
Procedure Write(Const s: AnsiString);
Procedure WriteLn();
Procedure WriteLn(Const s: AnsiString);
Procedure CursorOff();
Procedure CursorOn();
Procedure FlushInput();

Implementation

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
	FaceName : FACETYPE;
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

SECURITY_ATTRIBUTES = Record
	nLength : DWord;
	lpSecurityDescriptor : Pointer;
	bInheritHandle : LongBool;
End;
PSECURITY_ATTRIBUTES = ^SECURITY_ATTRIBUTES;

Var
hStdin: Handle;
hStdout: Handle;
fdwSaveOldMode: DWord;

Function GetConsoleMode(hConsoleHandle: Handle; lpMode: LpDWord): LongBool; External Name 'GetConsoleMode';
Function SetConsoleMode(hConsoleHandle: Handle; dwMode: DWord): LongBool; External Name 'SetConsoleMode';
Function GetCurrentConsoleFontEx(hConsoleOutput: Handle; bMaximumWindow: LongBool; lpConsoleCurrentFontEx: PCONSOLE_FONT_INFOEX): LongBool; External Name 'GetCurrentConsoleFontEx';
Function SetCurrentConsoleFontEx(hConsoleOutput: Handle; bMaximumWindow: LongBool; lpConsoleCurrentFontEx: PCONSOLE_FONT_INFOEX): LongBool; External Name 'SetCurrentConsoleFontEx';
Function GetConsoleScreenBufferInfo(hConsoleOutput: Handle; lpConsoleScreenBufferInfo: PCONSOLE_SCREEN_BUFFER_INFO): LongBool; External Name 'GetConsoleScreenBufferInfo';
Function SetConsoleWindowInfo(hConsoleOutput: Handle; bAbsolute: LongBool; Var lpConsoleWindow: SMALL_RECT): LongBool; External Name 'SetConsoleWindowInfo';
Function SetConsoleScreenBufferSize(hConsoleOutput: Handle; dwSize: Coord): LongBool; External Name 'SetConsoleScreenBufferSize';
Function ReadConsoleInput(hConsoleInput: Handle; lpBuffer: PINPUTRECORD; nLength: DWord; lpNumberOfEventsRead: LpDWord): LongBool; External Name 'ReadConsoleInputA';
Function FillConsoleOutputCharacter(hConsoleOutput: Handle; cCharacter: Char; nLength: DWord; dwWriteCoord: Coord; lpNumberOfCharsWritten: LpDWord): LongBool; External Name 'FillConsoleOutputCharacterA';
Function FillConsoleOutputAttribute(hConsoleOutput: Handle; wAttribute: Word; nLength: DWord; dwWriteCoord: Coord; lpNumberOfAttrsWritten: LpDWord): LongBool; External Name 'FillConsoleOutputAttribute';
Function SetConsoleTextAttribute(hConsoleOutput: Handle; wAttributes: Word): LongBool; External Name 'SetConsoleTextAttribute';
Function SetConsoleCursorPosition(hConsoleOutput: Handle; dwCursorPosition: Coord): LongBool; External Name 'SetConsoleCursorPosition';
Function WriteConsoleOutputCharacter(hConsoleOutput: Handle; lpCharacter: PChar; nLength: DWord; dwWriteCoord: Coord; lpNumberOfCharsWritten: LpDWord): LongBool; External Name 'WriteConsoleOutputCharacterA';
Function WriteConsoleOutputAttribute(hConsoleOutput: Handle; lpAttribute: Pointer; nLength: DWord; dwWriteCoord: Coord; lpNumberOfAttrsWritten: LpDWord): LongBool; External Name 'WriteConsoleOutputAttribute';
Function SetConsoleCursorInfo(hConsoleOutput: Handle; lpConsoleCursorInfo: PCONSOLE_CURSOR_INFO): LongBool; External Name 'SetConsoleCursorInfo';
Function FlushConsoleInputBuffer(hConsoleInput: Handle): LongBool; External Name 'FlushConsoleInputBuffer';
Function SetConsoleOutputCP(wCodePageID: Cardinal): LongBool; External Name 'SetConsoleOutputCP';
Function GetStdHandle(nStdHandle: DWord): Handle; External Name 'GetStdHandle';
Function GetLastError(): DWord; External Name 'GetLastError';
Function AttachConsole(dwProcessId: DWord): LongBool; External Name 'AttachConsole';
Function SetConsoleTitleA(lpConsoleTitle: PAnsiString): LongBool; External Name 'SetConsoleTitleA';
Function CreateConsoleScreenBuffer(dwDesiredAccess: DWord; dwShareMode: DWord; Const lpSecurityAttributes: PSECURITY_ATTRIBUTES; dwFlags: DWord; lpScreenBufferData: Pointer): Handle; External Name 'CreateConsoleScreenBuffer';
Function SetConsoleActiveScreenBuffer(hConsoleOutput: Handle): LongBool; External Name 'SetConsoleActiveScreenBuffer';
Function ReadConsole(hConsoleInput: Handle; lpBuffer: Pointer; nNumberOfCharsToRead: DWord; lpNumberOfCharsRead: LpDWord; pInputControl: Pointer): LongBool; External Name 'ReadConsoleA';
Function WriteConsole(hConsoleOutput: Handle; Const lpBuffer: Pointer; nNumberOfCharsToWrite: DWord; lpNumberOfCharsWritten: LpDWord; lpReserved: Pointer): LongBool; External Name 'WriteConsoleA';

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


Procedure SetConsoleTitle(Const title: AnsiString);
Begin
	SetConsoleTitleA(PAnsiString(title));
End;

Procedure SetConsoleFont(Const FaceName: FACETYPE; Const x, y: Integer);
Var
FontInfo: CONSOLE_FONT_INFOEX;
Begin
	FontInfo.cbSize := sizeof(CONSOLE_FONT_INFOEX);
	GetCurrentConsoleFontEx(hStdout, False, @FontInfo);
	{ Set to TrueType }
	FontInfo.FontFamily := FontInfo.FontFamily Or 4;
	FontInfo.FaceName := FaceName;
	FontInfo.dwFontSize.X := x;
	FontInfo.dwFontSize.Y := y;
	SetCurrentConsoleFontEx(hStdout, False, @FontInfo);
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

Procedure GoToXY(Const x, y: Integer);
Var
Loc: Coord;
Begin
	Loc.X := x;
	Loc.Y := y;
	SetConsoleCursorPosition(hStdout, Loc);
End;

Procedure Read(Var s: Array Of Char; Var numRead: DWord);
Begin
	ReadConsole(hStdin, @s[0], Length(s), @numRead, Nil);
	WriteLn();
End;

Procedure ReadLn(Var s: Array Of Char; Var numRead: DWord);
Begin
	Read(s, numRead);
	FlushInput();
End;

Procedure Write(Const s: AnsiString);
Var
cCharsWritten: DWord;
Begin
	WriteConsole(hStdout, PAnsiString(s), Length(s), @cCharsWritten, Nil);
End;

Procedure WriteLn();
Begin
	Write(Chr(10));
End;

Procedure WriteLn(Const s: AnsiString);
Begin
	Write(s + Chr(10));
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

Initialization
	hStdin := GetStdHandle(STD_INPUT_HANDLE);
	{hStdout := GetStdHandle(STD_OUTPUT_HANDLE);}
	hStdout := CreateConsoleScreenBuffer(1073741824, 2, Nil, 1, Nil);
	SetConsoleActiveScreenBuffer(hStdout);
	SetConsoleOutputCP(437);
	GetConsoleMode(hStdin, @fdwSaveOldMode);
	SetConsoleMode(hStdin, ENABLE_WINDOW_INPUT Or ENABLE_MOUSE_INPUT Or ENABLE_EXTENDED_FLAGS Or ENABLE_ECHO_INPUT Or ENABLE_LINE_INPUT Or ENABLE_INSERT_MODE);
Finalization
	SetConsoleMode(hStdin, fdwSaveOldMode);
End.