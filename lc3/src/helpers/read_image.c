#pragma once

#include "stdint.h"
#include "stdio.h"

#include "../hardware/memory.c"

uint16_t swap16(uint16_t x) { return (x << 8) | (x >> 8); }

void read_image_file(FILE *file) {
  uint16_t origin;
  fread(&origin, sizeof(origin), 1, file);
  origin = swap16(origin);

  uint16_t max_read = MEMORY_MAX - origin;
  uint16_t *p = memory + origin;

  size_t read = fread(p, sizeof(uint16_t), max_read, file);

  while (read-- > 0) {
    *p = swap16(*p);
    ++p;
  }
}

int read_image(const char *image_path) {
  FILE *file = fopen(image_path, "rb");
  if (!file) {
    return 0;
  }
  read_image_file(file);
  fclose(file);
  return 1;
}
