#pragma once

#include "stdint.h"

#include "../helpers/update_flags.c"

void not(uint16_t instr) {
  uint16_t dr = (instr >> 9) & 0x7;
  uint16_t sr = (instr >> 6) & 0x7;

  reg[dr] = ~reg[sr];

  update_flags(dr);
}
