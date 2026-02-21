const std = @import("std");

const components = @import("components.zig");

const USER_SPACE_OFFSET = 0x200;

pub const Bus = struct {
    memory: *components.memory.Memory,
    cpu: *components.cpu.CPU,
    timers: *components.timers.Timers,
    keyboard: *components.keyboard.Keyboard,
    display: *components.display.Display,

    cpu_timer: f64 = 0.0,

    pub fn init(options: struct {
        memory: *components.memory.Memory,
        cpu: *components.cpu.CPU,
        timers: *components.timers.Timers,
        keyboard: *components.keyboard.Keyboard,
        display: *components.display.Display,
    }) @This() {
        return .{
            .memory = options.memory,
            .cpu = options.cpu,
            .timers = options.timers,
            .keyboard = options.keyboard,
            .display = options.display,
        };
    }

    pub fn wipe_memory(self: *@This()) void {
        self.memory.data = std.mem.zeroes([4096]u8);
    }

    pub fn load_program(self: *@This(), filename: []const u8) !void {
        _ = try std.fs.cwd().readFile(filename, self.memory.data[USER_SPACE_OFFSET..4096]);
    }

    pub fn load_bios(self: *@This(), filename: []const u8) !void {
        _ = try std.fs.cwd().readFile(filename, self.memory.data[0..USER_SPACE_OFFSET]);
    }

    pub fn tick(self: *@This(), delta: f64) !void {
        const instruction = self.memory.get_instruction();
        try self.display.tick(delta);
        self.keyboard.tick();
        self.timers.tick(delta);

        self.cpu_timer = self.cpu_timer + delta;
        if (self.cpu_timer >= 0.0) {
            try self.memory.tick();
            try self.cpu.tick(instruction, self.memory, self.timers, self.keyboard);
            self.cpu_timer = 0.0;
        }
    }
};
