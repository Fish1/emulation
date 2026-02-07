#pragma once

#include "stdint.h"

#include "../helpers/mem_read.c"
#include "../helpers/sign_extend.c"
#include "../helpers/update_flags.c"

void ld(uint16_t instr) {
  uint16_t dr = (instr >> 9) & 0x7;
  uint16_t pcoffset9 = sign_extend(instr & 0x1ff, 9);

  reg[dr] = mem_read(reg[R_PC] + pcoffset9);
  update_flags(dr);
}
