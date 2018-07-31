unit ushared;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  CAL_CYCLES_IN_BLOCK = 40;
  CAL_NUM_CYCLES = 2*1000*1000*1000;
  {$IF CAL_NUM_CYCLES/CAL_CYCLES_IN_BLOCK>high(uint32)}{$error CAL_NUM_CYCLES too large for calibrate assembler!}{$IFEND}
  CAL_TARGET = 0.01;

  TEST_REPEAT = 5;
  RANDOM_ARRAY_LEN = 10*1000*1000;
 // RANDOM_ARRAY_LEN = 10000;

type
  ARRAY_BASE_TYPE = 0..19;

implementation

end.

