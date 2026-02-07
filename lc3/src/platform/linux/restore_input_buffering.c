#pragma once

#include "termios.h"
#include "unistd.h"

#include "./original_tio.c"

void restore_input_buffering() {
  tcsetattr(STDIN_FILENO, TCSANOW, &original_tio);
}
