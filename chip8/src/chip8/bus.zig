const std = @import("std");

const components = @import("components.zig");

const USER_SPACE_OFFSET = 0x200;

pub const Bus = struct {
    memory: *components.memory.Memory,
    cpu: *components.cpu.CPU,
    timers: *components.timers.Timers,
    keyboard: *components.keyboard.Keyboard,
    display: *components.display.Display,

    instructions_per_frame: u8 = 11,

    display_hertz: f64 = 1.0 / 60.0,
    display_timer: f64 = 0.0,

    // cpu_hertz: f64 = 1.0 / 1250.0,
    cpu_hertz: f64 = 0.0,
    cpu_timer: f64 = 0.0,

    timers_hertz: f64 = 1.0 / 60.0,
    timers_timer: f64 = 0.0,

    cpu_tick_wait_parse: u32 = 0,
    cpu_tick_wait_execute: u32 = 0,
    cpu_tick_wait_execute_extra: u32 = 0,
    cpu_tick_wait_instruction: components.cpu.Instruction = undefined,
    cpu_tick_wait_state: enum { parse, parse_wait, execute_wait, execute, execute_extra, execute_extra_draw } = .parse,

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

    pub fn tick_burst(self: *@This(), delta: f64) !void {
        self.display_timer = self.display_timer + delta;
        if (self.display_timer >= self.display_hertz) {
            self.display_timer = 0.0;

            self.timers.tick();

            for (0..self.instructions_per_frame) |_| {
                const instruction = try self.memory.tick();
                try self.cpu.tick(instruction, self.memory, self.timers, self.keyboard);
                if (self.cpu.display_wait == true) {
                    self.cpu.display_wait = false;
                    break;
                }
            }

            try self.display.tick();
        }
    }

    pub fn tick_hertz(self: *@This(), delta: f64) !void {
        self.timers_timer = self.timers_timer + delta;
        if (self.timers_timer >= self.timers_hertz) {
            self.timers_timer = 0.0;
            self.timers.tick();
        }

        self.display_timer = self.display_timer + delta;
        if (self.display_timer >= self.display_hertz) {
            self.display_timer = 0.0;
            try self.display.tick();
            self.cpu.display_wait = false;
        }

        self.cpu_timer = self.cpu_timer + delta;
        if (self.cpu_timer >= self.cpu_hertz and self.cpu.display_wait == false) {
            self.cpu_timer = 0.0;
            const instruction = try self.memory.tick();
            try self.cpu.tick(instruction, self.memory, self.timers, self.keyboard);
        }
    }

    pub fn tick_cycles(self: *@This(), delta: f64) !void {
        self.timers_timer = self.timers_timer + delta;
        if (self.timers_timer >= self.timers_hertz) {
            self.timers_timer = 0.0;
            self.timers.tick();
        }

        self.display_timer = self.display_timer + delta;
        if (self.display_timer >= self.display_hertz) {
            self.display_timer = 0.0;
            try self.display.tick();
            self.cpu.display_wait = false;
        }

        self.cpu_timer = self.cpu_timer + delta;
        if (self.cpu_timer >= self.cpu_hertz and self.cpu.display_wait == false) {
            self.cpu_timer = 0.0;

            // const instruction = self.memory.get_instruction();

            if (self.cpu_tick_wait_state == .parse) {
                const _parsed_instruction = try self.cpu.parse_instruction(self.memory.get_instruction());
                switch (_parsed_instruction) {
                    inline else => |parsed_instruction| {
                        self.cpu_tick_wait_parse = parsed_instruction.parse_cycles;
                        self.cpu_tick_wait_execute = parsed_instruction.execute_cycles;
                        self.cpu_tick_wait_instruction = _parsed_instruction;
                    },
                }
                self.cpu_tick_wait_state = .parse_wait;
            } else if (self.cpu_tick_wait_state == .parse_wait) {
                self.cpu_tick_wait_parse = self.cpu_tick_wait_parse - 1;
                if (self.cpu_tick_wait_parse == 0) {
                    self.cpu_tick_wait_state = .execute_wait;
                }
            } else if (self.cpu_tick_wait_state == .execute_wait) {
                self.cpu_tick_wait_execute = self.cpu_tick_wait_execute - 1;
                if (self.cpu_tick_wait_execute == 0) {
                    self.cpu_tick_wait_state = .execute;
                }
            } else if (self.cpu_tick_wait_state == .execute) {
                _ = try self.memory.tick();
                self.cpu.handle_key_interupt(self.memory, self.keyboard);
                self.cpu_tick_wait_execute_extra = try self.cpu.execute_instruction(self.cpu_tick_wait_instruction, self.memory, self.timers, self.keyboard);
                if (self.cpu_tick_wait_execute_extra != 0 and self.cpu.display_wait == true) {
                    self.cpu_tick_wait_state = .execute_extra_draw;
                    self.cpu.display_wait = false;
                } else if (self.cpu_tick_wait_execute_extra != 0) {
                    self.cpu_tick_wait_state = .execute_extra;
                } else {
                    self.cpu_tick_wait_state = .parse;
                }
            } else if (self.cpu_tick_wait_state == .execute_extra) {
                self.cpu_tick_wait_execute_extra = self.cpu_tick_wait_execute_extra - 1;
                if (self.cpu_tick_wait_execute_extra == 0) {
                    self.cpu_tick_wait_state = .parse;
                }
            } else if (self.cpu_tick_wait_state == .execute_extra_draw) {
                self.cpu_tick_wait_execute_extra = self.cpu_tick_wait_execute_extra - 1;
                if (self.cpu_tick_wait_execute_extra == 0) {
                    self.cpu.display_wait = true;
                    self.cpu_tick_wait_state = .parse;
                }
            }
        }
    }
};
