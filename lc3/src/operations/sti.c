#pragma once

#include "../hardware/register_store.c"
#include "../helpers/mem_read.c"
#include "../helpers/mem_write.c"
#include "../helpers/sign_extend.c"

void sti(uint16_t instr) {
  uint16_t sr = (instr >> 9) & 0x7;
  uint16_t pcoffset9 = sign_extend(instr & 0x1ff, 9);

  mem_write(mem_read(reg[R_PC] + pcoffset9), reg[sr]);
}
