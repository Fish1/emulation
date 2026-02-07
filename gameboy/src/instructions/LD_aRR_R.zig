const std = @import("std");

const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn LD_aDE_A(registers: *Registers, memory: *Memory) void {
    const address = registers.getDE();
    memory.write(address, registers.A);
    if (address == 0xff01) {
        std.debug.print("{c}", .{registers.A});
    }
}
