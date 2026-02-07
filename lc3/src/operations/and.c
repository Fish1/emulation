#pragma once

#include "stdint.h"

#include "../hardware/register_store.c"

#include "../helpers/sign_extend.c"
#include "../helpers/update_flags.c"

void and (uint16_t instr) {
  uint16_t dr = (instr >> 9) & 0x7;
  uint16_t sr1 = (instr >> 6) & 0x7;
  uint16_t mode = (instr >> 5) & 0x1;

  if (mode == 1) {
    uint16_t imm5 = sign_extend(instr & 0x1f, 5);
    reg[dr] = reg[sr1] & imm5;
  } else {
    uint16_t sr2 = instr & 0x7;
    reg[dr] = reg[sr1] & reg[sr2];
  }

  update_flags(dr);
}
