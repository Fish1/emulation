#pragma once

#include "stdint.h"

#include "../hardware/memory.c"

void mem_write(uint16_t addr, uint16_t val) { memory[addr] = val; }
