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
test: Array[0..0] Of Word;

Begin

	SetActiveBuffer(CreateBuffer());
	SetConsoleFont('Consolas', 0, 20);
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
	test[0] := White * 16;
	WriteAttr(test, 0, 0);
	Flush(f);
	ReadLn();
	Close(f);
End.