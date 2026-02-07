const std = @import("std");

const CPU = @import("../CPU.zig").CPU();
const Memory = @import("../Memory.zig").Memory();

pub fn JP_an16(cpu: *CPU, memory: *Memory) void {
    const lsb = @as(u16, cpu.readNextU8(memory));
    const msb = @as(u16, cpu.readNextU8(memory));
    cpu.pointer = (msb << 8) | lsb;
    std.log.info("jp_n16 {x:0>2} {x:0>2} , new pointer = {x:0>4}", .{ lsb, msb, cpu.pointer });
}
