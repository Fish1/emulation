#include "signal.h"
#include "stdio.h"
#include "stdlib.h"

#include "./hardware/controller.c"
#include "./hardware/opcodes.c"

#include "./helpers/read_image.c"

#include "./operations/add.c"
#include "./operations/and.c"
#include "./operations/br.c"
#include "./operations/jmp.c"
#include "./operations/jsr.c"
#include "./operations/ld.c"
#include "./operations/ldi.c"
#include "./operations/ldr.c"
#include "./operations/lea.c"
#include "./operations/not.c"
#include "./operations/res.c"
#include "./operations/rti.c"
#include "./operations/st.c"
#include "./operations/sti.c"
#include "./operations/str.c"
#include "./operations/trap.c"

#include "./platform/linux/disable_input_buffering.c"
#include "./platform/linux/restore_input_buffering.c"

void handle_interrupt(int signal) {
  restore_input_buffering();
  printf("\n");
  exit(-2);
}

int main(int argc, const char *argv[]) {

  signal(SIGINT, handle_interrupt);
  disable_input_buffering();

  // check if there are at least 2 arguments
  if (argc < 2) {
    printf("lc3 [image-file1] ...\n");
    exit(2);
  }

  // load the image
  for (int j = 1; j < argc; ++j) {
    if (!read_image(argv[j])) {
      printf("failed to load image: %s\n", argv[j]);
      exit(1);
    }
  }

  // setup

  // set the z flag
  reg[R_COND] = FL_ZRO;

  // set the PC to starting position
  // x3000 is the default
  enum { PC_START = 0x3000 };
  reg[R_PC] = PC_START;

  while (running) {
    // fetch instruction
    uint16_t instr = mem_read(reg[R_PC]++);
    uint16_t op = instr >> 12;

    switch (op) {
    case OP_BR:
      br(instr);
      break;
    case OP_ADD:
      add(instr);
      break;
    case OP_LD:
      ld(instr);
      break;
    case OP_ST:
      st(instr);
      break;
    case OP_JSR:
      jsr(instr);
      break;
    case OP_AND:
      and(instr);
      break;
    case OP_LDR:
      ldr(instr);
      break;
    case OP_STR:
      str(instr);
      break;
    case OP_RTI:
      rti(instr);
      break;
    case OP_NOT:
      not(instr);
      break;
    case OP_LDI:
      ldi(instr);
      break;
    case OP_STI:
      sti(instr);
      break;
    case OP_JMP:
      jmp(instr);
      break;
    case OP_RES:
      res(instr);
      break;
    case OP_LEA:
      lea(instr);
      break;
    case OP_TRAP:
      trap(instr);
      break;
    default: // bad op code
      abort();
      break;
    }
  }

  // shutdown
  restore_input_buffering();
}
