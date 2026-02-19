const std = @import("std");

const components = @import("components.zig");

const USER_SPACE_OFFSET = 0x200;

pub const Bus = struct {
    memory: *components.memory.Memory,
    cpu: *components.cpu.CPU,

    pub fn init(options: struct {
        memory: *components.memory.Memory,
        cpu: *components.cpu.CPU,
    }) @This() {
        return .{
            .memory = options.memory,
            .cpu = options.cpu,
        };
    }

    pub fn load_program(self: *@This(), filename: []const u8) !void {
        self.memory.* = .init();
        self.cpu.* = .init();
        self.memory.data = std.mem.zeroes([4096]u8);
        _ = try std.fs.cwd().readFile(filename, self.memory.data[USER_SPACE_OFFSET..4096]);
    }

    pub fn tick(self: *@This()) !void {
        const instruction = self.memory.get_instruction();
        try self.memory.increment_counter();
        try self.cpu.execute(instruction, self.memory);
    }
};
