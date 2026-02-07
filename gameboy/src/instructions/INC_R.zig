const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn INC_B(registers: *Registers) void {
    registers.B += 1;
    registers.setZero(registers.B == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.D & 0x0F == 0);
}

pub fn INC_D(registers: *Registers) void {
    registers.D += 1;
    registers.setZero(registers.D == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.D & 0x0F == 0);
}

pub fn INC_H(registers: *Registers) void {
    registers.H += 1;
    registers.setZero(registers.H == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.H & 0x0F == 0);
}

pub fn INC_C(registers: *Registers) void {
    registers.C += 1;
    registers.setZero(registers.C == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.C & 0x0F == 0);
}

pub fn INC_E(registers: *Registers) void {
    registers.E += 1;
    registers.setZero(registers.E == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.E & 0x0F == 0);
}

pub fn INC_L(registers: *Registers) void {
    registers.L += 1;
    registers.setZero(registers.L == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.L & 0x0F == 0);
}

pub fn INC_A(registers: *Registers) void {
    registers.A += 1;
    registers.setZero(registers.A == 0);
    registers.setSubtraction(false);
    registers.setHalfCarry(registers.A & 0x0F == 0);
}
