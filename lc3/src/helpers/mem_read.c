#pragma once

#include "stdint.h"
#include "stdio.h"

#include "../hardware/memory.c"
#include "../hardware/memory_registers.c"

#include "../platform/linux/check_key.c"

uint16_t mem_read(uint16_t addr) {
  if (addr == MR_KBSR) {
    if (check_key()) {
      memory[MR_KBSR] = (1 << 15);
      memory[MR_KBDR] = getchar();
    } else {
      memory[MR_KBSR] = 0;
    }
  }
  return memory[addr];
}
