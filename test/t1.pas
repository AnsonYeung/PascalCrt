Program t1;
Uses SysUtils, Console;
Var
i: DWord;
start: TDateTime;
s: String;
t: AnsiString;
happy: Array Of Char;
c: DWord;

Begin

	SetConsoleFont('Lucida Console', 10, 20);
	SetConsoleSize(120, 30);
	SetConsoleTitle('Console.ppu Test Progarm');
	start := Time();
	s := '';
	For i := 1 To 255 Do
		s := s + 'a';
	Write(s);
	WriteLn();
	Str(Time() - start:16:14, t);
	WriteLn(t);

	start := Time();
	Write(s);
	WriteLn();
	Str(Time() - start:16:14, t);
	WriteLn(t);

	start := Time();
	For i := 1 To 255 Do
		Write('a');
	WriteLn();
	Str(Time() - start:16:14, t);
	WriteLn(t);

	SetLength(happy, 123);
	ReadLn(happy, c);
	Str(c, t);
	WriteLn(t);
	For i := 0 To c Do
	Begin
		If (happy[i] <> Chr(10)) And (happy[i] <> Chr(13)) Then
			t := t + happy[i];
		WriteLn(t);
	End;
	WriteLn(t);
	ReadLn(happy, c);
End.