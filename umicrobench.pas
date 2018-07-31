unit uMicrobench;

{$mode objfpc}{$H+}
{$AsmMode Intel}
{$ModeSwitch advancedrecords}

interface

uses
  windows, math, ushared,
  ActiveX, comobj, Variants;

type
  TPrecisionTimer = record
    pf_ct,                     // QPC: counts per second
    pf_cy: Int64;              // CalibrateClock: cycles per count
    true_clock: boolean;       // CalibrateClock: used clock cycles as reported by CPU, approximate otherwise
    procedure Init;
    function CalibrateClock: Int64;
    procedure Recalibrate;
  end;

const
  CAL_TARGET = 0.01;
  TEST_REPEAT = 5;                 // Repeat test at least this many times
  TEST_REPEAT_TIME = 2000;         // Repeat test until this many ms have passed

procedure Statistics(const data: array of Int64; out mean, stddev, tmin, tmax: Double);
procedure PrintCPUInfo;
function IsOuputInteractive: boolean;

procedure MbPrintPlatformInfo;
procedure MbSetup;
procedure MbPerformTest(m: TProcedure; Name: string; InnerLoop: LongWord = 0);

var
  MbDefInnerLoop: integer = 1;

  MbTimer: TPrecisionTimer;

implementation

function GetClockTics_RDTSC: QWord; Assembler; nostackframe;
Asm
  rdtsc
{$IFDEF CPUX64}
  shl RDX, 32
  or RAX, RDX
{$ENDIF}
  lfence
end;

// how many PC events per cycle?
function TPrecisionTimer.CalibrateClock: Int64;
const
  CAL_CYCLES_IN_BLOCK  = 40;
  CAL_NUM_CYCLES = 2*1000*1000*1000;
  {$IF CAL_NUM_CYCLES/CAL_CYCLES_IN_BLOCK>high(uint32)}{$error CAL_NUM_CYCLES too large for calibrate assembler!}{$IFEND}
var
  pc1,pc2,
  tsc1, tsc2: Int64;
begin
  Write('    ','perfcounter-cal':20,' : ');
  QueryPerformanceCounter(pc1{%H-});
  { a NOP is between 0.2 and 0.33 cycles on modern architectures
     AMD K10: 0.33
     AMD Bulldozer, Piledriver, Steamroller: 0.25
     AMD Ryzen: 0.2
     Intel Nehalem: 0.33
     Intel Sandy Bridge, Ivy Bridge, Haswell, Broadwell, Skylake: 0.25

     => 4 nops is going to be one clock on most. Burn CAL_CYCLES_IN_BLOCK at once to keep interference from loop low.
  }
  if true_clock then
    tsc1:= GetClockTics_RDTSC
  else
    tsc1:= 0;
  asm
    mov eax, CAL_NUM_CYCLES/CAL_CYCLES_IN_BLOCK
  @@1:
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;

    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;

    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;

    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;
    nop ; nop; nop; nop;

    dec eax
    jnz @@1
  end;
  QueryPerformanceCounter(pc2{%H-});
  if true_clock then
    tsc2:= GetClockTics_RDTSC
  else
    tsc2:= CAL_NUM_CYCLES;
  Result:= (tsc2-tsc1) div (pc2-pc1);
  Write(Result:13,' cycles per PC = ',1/Result:15:6,' PC per cycle =   core clock ',Result*pf_ct/1e9:6:3,' GHz');
  if not true_clock then
    Write(' (estimated)');
  WriteLn;
end;

procedure TPrecisionTimer.Init;
begin
  Self:= Default(TPrecisionTimer);
  true_clock:= True;
  QueryPerformanceFrequency(pf_ct{%H-});
  pf_cy:= CalibrateClock();
end;

procedure TPrecisionTimer.Recalibrate;
var
  pfo: int64;
  i: Integer;
begin
  pfo:= pf_cy;
  for i:= 1 to 10 do begin
    pf_cy:= CalibrateClock;
    if abs(pfo-pf_cy) < CAL_TARGET * pf_cy then
      break;
    pfo:= pf_cy;
  end;
end;

procedure Statistics(const data: array of Int64; out mean, stddev, tmin, tmax: Double);
var
  de: array of Extended;
  i: Integer;
  d: Int64;
  m, s: float;
begin
  m:= 0;
  s:= 0;
  tmin:= high(Int64);
  tmax:= Low(Int64);
  SetLength(de{%H-}, Length(data));
  for i:= 0 to high(de) do begin
    d:= data[i];
    de[i]:= d;
    if d > tmax then tmax:= d;
    if d < tmin then tmin:= d;
  end;
  meanandstddev(de, m, s);
  mean:= m;
  stddev:= s;
end;

function VariantToStr(const aVariant: Variant): String;
begin
  result := '';
  if (TVarData(aVariant).vtype <> varempty) and
     (TVarData(aVariant).vtype <> varnull) and
     (TVarData(aVariant).vtype <> varerror) then begin
    result := aVariant;
  end;
end;

procedure PrintCPUInfo;
const
  WBEM_FLAGFORWARDONLY = $00000020;
var
  SWbemLocator, WMIService: OLEVariant;
  WbemObjectSet, WbemObject, oProp: OLEVariant;
  pCeltFetched: LongWord;
  oEnum: IEnumvariant;
  i: Integer;
begin
  CoInitialize(nil);
  SWbemLocator:= CreateOleObject('WbemScripting.SWbemLocator');
  WMIService:= SWbemLocator.ConnectServer('localhost','root\CIMV2', '', '');
  WbemObjectSet:= WMIService.ExecQuery('SELECT * FROM WIN32_Processor', 'WQL', WBEM_FLAGFORWARDONLY);
  oEnum:= IUnknown(WbemObjectSet._NewEnum) as IEnumVariant;
  i:= 0;
  while oEnum.Next(1, WbemObject, pCeltFetched) = 0 do begin
    Write('CPU ',i:3,' :');
    oProp:= WbemObject.Properties_;

    Write(' ', VariantToStr(oProp.Item('Manufacturer').Value));
    Write(' ', VariantToStr(oProp.Item('Name').Value));
    Write(' ', VariantToStr(oProp.Item('Caption').Value));
    WriteLn('');
    inc(i);
  end;
end;

function IsOuputInteractive: boolean;
var
  mode: DWORD;
begin
  Result:= GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) = FILE_TYPE_CHAR;
  Result:= Result and GetConsoleMode(GetStdHandle(STD_OUTPUT_HANDLE), mode{%H-});
end;

procedure MbPrintPlatformInfo;
begin
  Writeln('Platform: ','FPC',{$I %FPCVersion%},' ',{$I %FPCTargetCPU%}, '-',{$I %FPCTargetOS%});
  WriteLn('Build   : ',{$I %Date%},' ', {$I %Time%});
  PrintCPUInfo;
end;

procedure MbSetup;
begin
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  SetThreadAffinityMask(GetCurrentThread, 1);
  MbTimer.Init;
  MbTimer.Recalibrate;
end;

procedure MbPerformTest(m: TProcedure; Name: string; InnerLoop: LongWord);
var
  pc1,pc2, wt1, wt2, wt2t: Int64;
  Times: array of Int64;
  i: Integer;
  mean, stddev, tmin, tmax: Double;
begin
  if InnerLoop = 0 then
    InnerLoop:= MbDefInnerLoop;
  Write('[*] ',Name:20,' :');
  SetLength(Times, TEST_REPEAT);
  QueryPerformanceCounter(wt1{%H-});
  wt2t:= wt1 + trunc(TEST_REPEAT_TIME/1000*MbTimer.pf_ct);
  for i:= 0 to high(Times) do begin
    QueryPerformanceCounter(pc1{%H-});
    m();
    QueryPerformanceCounter(pc2{%H-});
    Times[i]:= pc2-pc1;
  end;
  QueryPerformanceCounter(wt2{%H-});
  if wt2 < wt2t then begin
    // estimate how many iterations we need, based on first set
    Statistics(Times, mean, stddev, tmin, tmax);
    SetLength(Times, trunc((wt2t-wt1) / tmin));
    for i:= TEST_REPEAT to high(Times) do begin
      QueryPerformanceCounter(pc1{%H-});
      m();
      QueryPerformanceCounter(pc2{%H-});
      Times[i]:= pc2-pc1;
    end;
  end;
  Statistics(Times, mean, stddev, tmin, tmax);
  WriteLn(' ', mean/MbTimer.pf_ct/InnerLoop*1e6:15:6,' us',
          ' ', mean*MbTimer.pf_cy/InnerLoop:15:1,' ',
          ' ', '+/- ',stddev*MbTimer.pf_cy/InnerLoop:5:3,' cycles',
          ' ', '[',
          ' ', 100*stddev/mean:6:1,' %CV',
          ' ', 100*(tmax-tmin)/mean:6:1,' %R',
          ' ', Length(Times):6,' N',
          ' ', ']');
end;



end.

