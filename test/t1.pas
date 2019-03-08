Program t1;
Uses SysUtils, Console;
Var
i: DWord;
start: TDateTime;
s: String;
t: AnsiString;
happy: Array Of Char;
c: DWord;
f: Text;

Begin

	SetActiveBuffer(CreateBuffer());
	SetConsoleFont('Failing Consolas', 0, 20);
	SetConsoleSize(120, 30);
	SetConsoleTitle('Console.ppu Test Progarm');
	Assign(f, 'CONOUT$');
	Rewrite(f);
	start := Time();
	s := '';
	For i := 1 To 255 Do
		s := s + 'a';
	Write(f, s);
	WriteLn(f);
	Flush(f);
	Str(Time() - start:16:14, t);
	WriteLn(f, t);

	start := Time();
	Write(f, s);
	WriteLn(f);
	Flush(f);
	Str(Time() - start:16:14, t);
	WriteLn(f, t);

	start := Time();
	For i := 1 To 255 Do
		Write(f, 'a');
	WriteLn(f);
	Flush(f);
	Str(Time() - start:16:14, t);
	WriteLn(f, t);

	SetLength(happy, 123);
	ReadLn();
	Str(12345, t);
	WriteLn(f, t);
	For i := 0 To c Do
	Begin
		If (happy[i] <> Chr(10)) And (happy[i] <> Chr(13)) Then
			t := t + happy[i];
		WriteLn(f, t);
	End;
	WriteLn(f, t);
	Flush(f);
	ReadLn();
	Close(f);
End.