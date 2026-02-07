#pragma once

#include "stdint.h"

#include "../hardware/register_store.c"

#include "../helpers/sign_extend.c"

void jsr(uint16_t instr) {

  uint16_t mode = (instr >> 11) & 0x1;

  reg[R_R7] = reg[R_PC];

  if (mode == 1) { // jsr
    uint16_t pcoffset11 = (instr) & 0x7ff;
    reg[R_PC] = reg[R_PC] + sign_extend(pcoffset11, 11);
  } else { // jsrr
    uint16_t baser = (instr >> 6) & 0x7;
    reg[R_PC] = reg[baser];
  }
}
