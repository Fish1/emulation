#pragma once

#include "stdint.h"

uint16_t sign_extend(uint16_t x, int bit_count) {
  // if the left most bit is 1
  if ((x >> (bit_count - 1)) & 1) {
    // then put all 1 in everything after the bit_count
    x |= (0xFFFF << bit_count);
  }
  // x = -1 (11111) bit_count = 5
  // x >> ( 5 - 1 ) = 1
  // x |= (0xFFFF << 5)
  // x |= 1111 1111 1110 0000
  return x;
}
