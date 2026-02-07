#pragma once

#include "stdint.h"

#include "../hardware/register_store.c"

#include "../helpers/sign_extend.c"

void br(uint16_t instr) {
  uint16_t nzp = (instr >> 9) & 0x7;
  if (nzp & reg[R_COND]) {
    uint16_t pcoffset9 = sign_extend(instr & 0x1ff, 9);
    reg[R_PC] = reg[R_PC] + pcoffset9;
  }
}
