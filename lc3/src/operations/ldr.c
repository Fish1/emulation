#pragma once

#include "stdint.h"

#include "../hardware/register_store.c"

#include "../helpers/mem_read.c"
#include "../helpers/sign_extend.c"
#include "../helpers/update_flags.c"

void ldr(uint16_t instr) {
  uint16_t dr = (instr >> 9) & 0x7;
  uint16_t baser = (instr >> 6) & 0x7;
  uint16_t offset6 = sign_extend(instr & 0x3f, 6);

  reg[dr] = mem_read(reg[baser] + offset6);
  update_flags(dr);
}
