#pragma once

#include "stdint.h"

#include "../hardware/register_store.c"
#include "../helpers/mem_write.c"
#include "../helpers/sign_extend.c"

void str(uint16_t instr) {
  uint16_t sr = (instr >> 9) & 0x7;
  uint16_t baser = (instr >> 6) & 0x7;
  uint16_t offset6 = sign_extend(instr & 0x3f, 6);

  mem_write(reg[baser] + offset6, reg[sr]);
}
