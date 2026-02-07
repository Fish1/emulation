const std = @import("std");

const CPU = @import("CPU.zig").CPU();
const Registers = @import("Registers.zig").Registers();
const Memory = @import("Memory.zig").Memory();

const PATH = "/home/jacob/projects/gb/bin/tests/06-ld_r-r.gb";
// const PATH = "/home/jacob/projects/gb/bin/tests/05-op_rp.gb";

pub fn main() !void {
    var cpu = CPU.init();
    var registers = Registers.init();

    var memory = Memory.init();
    try memory.loadROM(PATH);

    while (true) {
        cpu.execute(&memory, &registers) catch |e| {
            std.log.err("error = {}", .{e});
            break;
        };
    }
}
