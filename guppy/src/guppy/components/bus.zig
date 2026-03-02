const std = @import("std");

const CPU = @import("cpu.zig").CPU;
const Memory = @import("memory.zig").Memory;

pub const Bus = struct {
    memory: *Memory,
    cpu: *CPU,

    pub fn init(components: struct { cpu: *CPU, memory: *Memory }) @This() {
        return .{
            .cpu = components.cpu,
            .memory = components.memory,
        };
    }

    pub fn tick(self: *@This()) void {
        self.cpu.execute(self);
    }

    pub fn load_boot(self: *@This(), filename: []const u8) !void {
        _ = try std.fs.cwd().readFile(filename, self.memory.get_rom_bank_00().*);
    }

    pub fn load_rom(self: *@This(), filename: []const u8) !void {
        _ = try std.fs.cwd().readFile(filename, self.memory.get_rom_bank_00().*);
    }
};
