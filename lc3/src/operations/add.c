#pragma once

#include "stdint.h"

#include "../helpers/sign_extend.c"
#include "../helpers/update_flags.c"

void add(uint16_t instr) {
  // 0x7 = 111
  uint16_t r0 = (instr >> 9) & 0x7;
  uint16_t r1 = (instr >> 6) & 0x7;
  // 0x1 = 1
  uint16_t imm_flag = (instr >> 5) & 0x1;

  if (imm_flag) {
    // 0x1f = 11111 , get the last five bits
    uint16_t imm5 = sign_extend(instr & 0x1f, 5);
    reg[r0] = reg[r1] + imm5;
  } else {
    uint16_t r2 = instr & 0x7;
    reg[r0] = reg[r1] + reg[r2];
  }

  update_flags(r0);
}
