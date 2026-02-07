const CPU = @import("../CPU.zig").CPU();
const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn JR_cZ_an8(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    if (registers.readZero() == true) {
        const address = cpu.readNextI8(memory);
        cpu.pointer = @intCast(address);
    } else {
        cpu.skip(1);
    }
}

pub fn JR_nZ_an8(cpu: *CPU, registers: *Registers, memory: *Memory) void {
    if (registers.readZero() == false) {
        const address = cpu.readNextI8(memory);
        cpu.pointer = @intCast(address);
    } else {
        cpu.skip(1);
    }
}
