program ptest;

{$mode objfpc}{$H+}
{$AsmMode intel}

uses
  windows, math, ushared,
  ActiveX, comobj, Variants,
  uOpt0, uOpt1, uOpt3, uOpt4, uMicrobench;

procedure TestsAbstract;
begin
  MbPerformTest(@uOpt3.ArrayNop, 'O3 array-nop');
  MbPerformTest(@uOpt0.ArrayQPC, 'O0 array-qpc');
  MbPerformTest(@uOpt3.ArrayQPC, 'O3 array-qpc');

  MbPerformTest(@uOpt0.RandomArray, 'O0 random-array');
  MbPerformTest(@uOpt1.RandomArray, 'O1 random-array');
  MbPerformTest(@uOpt3.RandomArray, 'O3 random-array');
  MbPerformTest(@uOpt4.RandomArray, 'O4 random-array');
end;

procedure TestsCaseOf;
begin
  MbDefInnerLoop:= RANDOM_ARRAY_LEN;
  MbPerformTest(@uOpt3.CaseAsm,     'O3 case-asm');
  MbPerformTest(@uOpt3.CaseAsm2,    'O3 case-asm2');
  MbPerformTest(@uOpt0.Case5,       'O0 case-of-5');
  MbPerformTest(@uOpt0.Case5Else,   'O0 case-of-5-else');
  MbPerformTest(@uOpt0.Case20,      'O0 case-of-20');
  MbPerformTest(@uOpt0.Case20Else,  'O0 case-of-20-else');
  MbPerformTest(@uOpt1.Case5,       'O1 case-of-5');
  MbPerformTest(@uOpt1.Case5Else,   'O1 case-of-5-else');
  MbPerformTest(@uOpt1.Case20,      'O1 case-of-20');
  MbPerformTest(@uOpt1.Case20Else,  'O1 case-of-20-else');
  MbPerformTest(@uOpt3.Case5,       'O3 case-of-5');
  MbPerformTest(@uOpt3.Case5Else,   'O3 case-of-5-else');
  MbPerformTest(@uOpt3.Case20,      'O3 case-of-20');
  MbPerformTest(@uOpt3.Case20Else,  'O3 case-of-20-else');
  MbPerformTest(@uOpt4.Case5,       'O4 case-of-5');
  MbPerformTest(@uOpt4.Case5Else,   'O4 case-of-5-else');
  MbPerformTest(@uOpt4.Case20,      'O4 case-of-20');
  MbPerformTest(@uOpt4.Case20Else,  'O4 case-of-20-else');
end;

procedure TestsCompareByte;
begin
  MbPerformTest(@uOpt0.CompareByte1,  'O0 compare-byte-1');
  MbPerformTest(@uOpt1.CompareByte1,  'O1 compare-byte-1');
  MbPerformTest(@uOpt3.CompareByte1,  'O3 compare-byte-1');
  MbPerformTest(@uOpt0.CompareByte2,  'O0 compare-byte-2');
  MbPerformTest(@uOpt1.CompareByte2,  'O1 compare-byte-2');
  MbPerformTest(@uOpt3.CompareByte2,  'O3 compare-byte-2');
end;

begin
  Randomize;
  SetConsoleCP(CP_ACP);
  MbPrintPlatformInfo;
  MbSetup;

  WriteLn('Array : ',RANDOM_ARRAY_LEN,'*',Low(ARRAY_BASE_TYPE),'..',High(ARRAY_BASE_TYPE));
  WriteLn('Repeat: ',TEST_REPEAT,' times or ', TEST_REPEAT_TIME, ' ms');

  TestsCaseOf;
  MbTimer.Recalibrate;

  WriteLn('Done.');
  if IsOuputInteractive then
    Readln;
end.

