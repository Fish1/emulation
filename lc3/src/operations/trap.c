#pragma once

#include "stdint.h"
#include "stdio.h"

#include "../hardware/controller.c"
#include "../hardware/memory.c"
#include "../hardware/register_store.c"
#include "../hardware/trapcodes.c"

#include "../helpers/update_flags.c"

void trap_getc();
void trap_out();
void trap_puts();
void trap_in();
void trap_putsp();
void trap_halt();

void trap(uint16_t instr) {
  reg[R_R7] = reg[R_PC];
  switch (instr & 0xff) {
  case TRAP_GETC:
    trap_getc();
    break;

  case TRAP_OUT:
    trap_out();
    break;

  case TRAP_PUTS:
    trap_puts();
    break;

  case TRAP_IN:
    trap_in();
    break;

  case TRAP_PUTSP:
    trap_putsp();
    break;

  case TRAP_HALT:
    trap_halt();
    break;
  }
}

void trap_getc() {
  reg[R_R0] = getc(stdin);
  update_flags(R_R0);
}

void trap_out() {
  putc(reg[R_R0], stdout);
  fflush(stdout);
}

void trap_in() {
  putc('>', stdout);
  reg[R_R0] = getc(stdin);
  putc(reg[R_R0], stdout);
  fflush(stdout);
  update_flags(R_R0);
}

void trap_puts() {
  uint16_t *c = memory + reg[R_R0];
  while (*c) {
    putc((char)*c, stdout);
    ++c;
  }
  fflush(stdout);
}

void trap_putsp() {
  uint16_t *c = memory + reg[R_R0];
  while (*c) {
    uint8_t top = (*c) & 0xff;
    uint8_t bottom = ((*c) >> 8) & 0xff;
    putc(top, stdout);
    if (bottom)
      putc(bottom, stdout);
    ++c;
  }
  fflush(stdout);
}

void trap_halt() {
  puts("HALT");
  fflush(stdout);
  running = 0;
}
