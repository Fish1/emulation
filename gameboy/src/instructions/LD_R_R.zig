const Registers = @import("../Registers.zig").Registers();

pub fn LD_R_R(to: *u8, value: u8) void {
    to.* = value;
}

pub fn LD_B_A(registers: *Registers) void {
    registers.B = registers.A;
}
