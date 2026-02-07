const CPU = @import("../CPU.zig").CPU();
const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn LD_C_n8(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.C = cpu.readNextU8(memory);
}

pub fn LD_E_n8(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.E = cpu.readNextU8(memory);
}

pub fn LD_L_n8(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.L = cpu.readNextU8(memory);
}

pub fn LD_A_n8(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    registers.A = cpu.readNextU8(memory);
}
