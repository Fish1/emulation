const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn DEC_B(registers: *Registers) void {
    registers.B -= 1;
    registers.setZero(registers.B == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.B & 0x0F == 0x0F);
}

pub fn DEC_D(registers: *Registers) void {
    registers.D -= 1;
    registers.setZero(registers.D == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.D & 0x0F == 0x0F);
}

pub fn DEC_H(registers: *Registers) void {
    registers.H -= 1;
    registers.setZero(registers.H == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.H & 0x0F == 0x0F);
}

pub fn DEC_C(registers: *Registers) void {
    registers.C -= 1;
    registers.setZero(registers.C == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.C & 0x0F == 0x0F);
}

pub fn DEC_E(registers: *Registers) void {
    registers.E -= 1;
    registers.setZero(registers.E == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.E & 0x0F == 0x0F);
}

pub fn DEC_L(registers: *Registers) void {
    registers.L -= 1;
    registers.setZero(registers.L == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.L & 0x0F == 0x0F);
}

pub fn DEC_A(registers: *Registers) void {
    registers.A -= 1;
    registers.setZero(registers.A == 0);
    registers.setSubtraction(true);
    registers.setHalfCarry(registers.A & 0x0F == 0x0F);
}
