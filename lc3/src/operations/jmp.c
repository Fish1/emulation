#pragma once

#include "stdint.h"

#include "../hardware/register_store.c"

void jmp(uint16_t instr) {
  uint16_t baser = (instr >> 6) & 0x7;

  reg[R_PC] = reg[baser];
}
