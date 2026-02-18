const std = @import("std");

const components = @import("components.zig");

const USER_SPACE_OFFSET = 0x200;

pub const Mother = struct {
    memory: *components.memory.Memory,
    program_counter: *components.program_counter.ProgramCounter,
    registers: *components.registers.Registers,
    cpu: *components.cpu.CPU,

    pub fn init(options: struct {
        memory: *components.memory.Memory,
        program_counter: *components.program_counter.ProgramCounter,
        registers: *components.registers.Registers,
        cpu: *components.cpu.CPU,
    }) @This() {
        return .{
            .memory = options.memory,
            .program_counter = options.program_counter,
            .registers = options.registers,
            .cpu = options.cpu,
        };
    }

    pub fn load_program(self: *@This(), filename: []const u8) !void {
        self.memory.* = .init();
        self.program_counter.* = .init();
        self.registers.* = .init();
        self.cpu.* = .init();
        self.memory.data = std.mem.zeroes([4096]u8);
        _ = try std.fs.cwd().readFile(filename, self.memory.data[USER_SPACE_OFFSET..4096]);
    }

    pub fn tick(self: *@This()) !void {
        const instruction = self.program_counter.get_current_instruction(self.memory);
        try self.program_counter.goto_next_instruction();
        try self.cpu.execute(instruction, self.program_counter, self.registers, self.memory);
    }
};
