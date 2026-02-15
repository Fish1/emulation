const std = @import("std");

const components = @import("components.zig");

const USER_SPACE_OFFSET = 0x200;

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

        var reader_buffer: [0]u8 = undefined;
        var reader = file.reader(&reader_buffer);

        const file_stats = try file.stat();
        const file_size = file_stats.size;

        self.memory.data = std.mem.zeroes([4096]u8);
        try reader.interface.readSliceAll(self.memory.data[USER_SPACE_OFFSET .. USER_SPACE_OFFSET + file_size]);
    }

    pub fn tick(self: *@This()) !void {
        const instruction = self.program_counter.get_current_instruction(self.memory);
        try self.program_counter.goto_next_instruction();

        try self.cpu.execute(instruction, self.program_counter);
    }
};
