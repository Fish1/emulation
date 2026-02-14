const std = @import("std");
const components = @import("components.zig");

pub const Mother = struct {
    memory: *components.memory.Memory,
    program_counter: *components.program_counter.ProgramCounter,
    cpu: *const components.cpu.CPU,

    pub fn init(options: struct {
        memory: *components.memory.Memory,
        program_counter: *components.program_counter.ProgramCounter,
        cpu: *const components.cpu.CPU,
    }) @This() {
        return .{
            .memory = options.memory,
            .program_counter = options.program_counter,
            .cpu = options.cpu,
        };
    }

    pub fn load_program(self: *@This(), filename: []const u8) !void {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();
        _ = try file.readAll(&self.memory.data);
    }

    pub fn tick(self: *@This()) !void {
        const byte = self.program_counter.get_current_byte(self.memory);
        try self.cpu.execute(byte);
        try self.program_counter.increment();
    }
};
