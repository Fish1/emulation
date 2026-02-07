const CPU = @import("../CPU.zig").CPU();
const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn LD_BC_n16(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.C = cpu.readNextU8(memory);
    registers.B = cpu.readNextU8(memory);
}

pub fn LD_DE_n16(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.E = cpu.readNextU8(memory);
    registers.D = cpu.readNextU8(memory);
}

pub fn LD_HL_n16(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.L = cpu.readNextU8(memory);
    registers.H = cpu.readNextU8(memory);
}

pub fn LD_SP_n16(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    const lsb = @as(u16, cpu.readNextU8(memory));
    const msb = @as(u16, cpu.readNextU8(memory));
    registers.SP = (msb << 8) | lsb;
}
