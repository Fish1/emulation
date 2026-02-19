const std = @import("std");
const window = @import("window");

const components = @import("components.zig");

const CPUError = error{
    unknown_instruction,
    unimplemented_instruction,
    failed_to_draw,
};

const Stack = struct {
    data: [32]u16 = std.mem.zeroes([32]u16),
    size: u16 = 0,

    pub fn init() @This() {
        return .{};
    }

    pub fn push(self: *@This(), address: u16) void {
        self.data[self.size] = address;
        self.size = self.size + 1;
    }

    pub fn pop(self: *@This()) u16 {
        const result = self.data[self.size - 1];
        self.size = self.size - 1;
        return result;
    }
};

const Registers = struct {
    i: u16 = 0,
    r: [16]u8 = std.mem.zeroes([16]u8),

    pub fn init() @This() {
        return .{};
    }
};

pub const CPU = struct {
    stack: Stack = .init(),
    registers: Registers = .init(),

    pub fn init() @This() {
        return .{};
    }

    pub fn execute(
        self: *@This(),
        data: u16,
        memory: *components.memory.Memory,
    ) CPUError!void {
        try self.execute_instruction(
            try self.parse_instruction(data),
            memory,
        );
    }

    fn parse_instruction(_: @This(), data: u16) CPUError!Instruction {
        std.log.debug("parse 0x{X:0>4}", .{data});
        const a = (data & 0xf000) >> 12;
        const b = (data & 0x0f00) >> 8;
        const c = (data & 0x00f0) >> 4;
        const d = (data & 0x000f) >> 0;
        const bcd = data & 0x0fff;
        const cd = data & 0x00ff;

        return switch (a) {
            0x0 => switch (data) {
                0x00e0 => .{
                    .clear_screen = .{},
                },
                0x00ee => .{
                    .return_function = .{},
                },
                else => CPUError.unknown_instruction,
            },
            0x1 => .{
                .jump = .{
                    .address = @intCast(bcd),
                },
            },
            0x2 => .{
                .call_function = .{
                    .address = @intCast(bcd),
                },
            },
            0x3 => .{
                .skip_if_vx_is_immediate = .{
                    .vx = @intCast(b),
                    .immediate = @intCast(cd),
                },
            },
            0x4 => .{
                .skip_if_vx_is_not_immediate = .{
                    .vx = @intCast(b),
                    .immediate = @intCast(cd),
                },
            },
            0x5 => .{
                .skip_if_vx_is_vy = .{
                    .vx = @intCast(b),
                    .vy = @intCast(c),
                },
            },
            0x6 => .{
                .load_vx_immediate = .{
                    .vx = @intCast(b),
                    .immediate = @intCast(cd),
                },
            },
            0x7 => .{
                .add_vx_immediate = .{
                    .vx = @intCast(b),
                    .immediate = @intCast(cd),
                },
            },
            0x8 => switch (d) {
                0 => .{
                    .set_vx_to_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                1 => .{
                    .set_vx_to_vx_or_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                2 => .{
                    .set_vx_to_vx_and_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                3 => .{
                    .set_vx_to_vx_and_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                else => CPUError.unknown_instruction,
            },
            0x9 => .{
                .skip_if_vx_is_not_vy = .{
                    .vx = @intCast(b),
                    .vy = @intCast(c),
                },
            },
            0xA => .{
                .load_i_immediate = .{
                    .immediate = @intCast(bcd),
                },
            },
            0xB => .{
                .jump_with_offset = .{
                    .immediate = @intCast(bcd),
                },
            },
            0xD => .{
                .draw_sprite = .{
                    .x_register = @intCast(b),
                    .y_register = @intCast(c),
                    .height = @intCast(d),
                },
            },
            else => CPUError.unknown_instruction,
        };
    }

    fn execute_instruction(
        self: *@This(),
        instruction: Instruction,
        memory: *components.memory.Memory,
    ) CPUError!void {
        std.log.debug("execute {any}", .{instruction});
        return switch (instruction) {
            .clear_screen => {
                window.clear_screen() catch return;
            },

            .jump => |i| {
                memory.counter = i.address;
            },
            .jump_with_offset => |i| {
                memory.counter = self.registers.r[0] + i.immediate;
            },

            .call_function => |i| {
                self.stack.push(memory.counter);
                memory.counter = i.address;
            },
            .return_function => {
                const address = self.stack.pop();
                memory.counter = address;
            },

            .set_vx_to_vy => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vy];
            },
            .set_vx_to_vx_or_vy => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vx] | self.registers.r[i.vy];
            },
            .set_vx_to_vx_and_vy => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vx] & self.registers.r[i.vy];
            },
            .set_vx_to_vx_xor_vy => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vx] ^ self.registers.r[i.vy];
            },

            .skip_if_vx_is_immediate => |i| {
                if (self.registers.r[i.vx] == i.immediate) {
                    memory.counter = memory.counter + 2;
                }
            },
            .skip_if_vx_is_not_immediate => |i| {
                if (self.registers.r[i.vx] != i.immediate) {
                    memory.counter = memory.counter + 2;
                }
            },
            .skip_if_vx_is_vy => |i| {
                if (self.registers.r[i.vx] == self.registers.r[i.vy]) {
                    memory.counter = memory.counter + 2;
                }
            },
            .skip_if_vx_is_not_vy => |i| {
                if (self.registers.r[i.vx] != self.registers.r[i.vy]) {
                    memory.counter = memory.counter + 2;
                }
            },

            .load_i_immediate => |i| {
                self.registers.i = i.immediate;
            },
            .load_vx_immediate => |i| {
                self.registers.r[i.vx] = i.immediate;
            },

            .add_vx_immediate => |i| {
                self.registers.r[i.vx] = @addWithOverflow(self.registers.r[i.vx], i.immediate)[0];
            },

            .draw_sprite => |i| {
                const start_x = self.registers.r[i.x_register];
                const start_y = self.registers.r[i.y_register];
                const height = i.height;

                for (0..height) |offset_y| {
                    const address = self.registers.i + offset_y;
                    inline for (0..8) |offset_x| {
                        const bit = (0b10000000 >> offset_x) & memory.data[address];
                        const render_x = start_x + @as(u8, @intCast(offset_x));
                        const render_y = start_y + @as(u8, @intCast(offset_y));
                        window.xor_pixel(render_x, render_y, bit != 0) catch {
                            return CPUError.failed_to_draw;
                        };
                    }
                }
            },
            // else => CPUError.unimplemented_instruction,
        };
    }
};

const _00E0 = struct {};
const _00EE = struct {};
const _1NNN = struct {
    address: u12,
};
const _2NNN = struct {
    address: u12,
};
const _3XNN = struct {
    vx: u4,
    immediate: u8,
};
const _4XNN = struct {
    vx: u4,
    immediate: u8,
};
const _5XY0 = struct {
    vx: u4,
    vy: u4,
};
const _6XNN = struct {
    vx: u4,
    immediate: u8,
};
const _7XNN = struct {
    vx: u4,
    immediate: u8,
};
const _8XY0 = struct {
    vx: u4,
    vy: u4,
};
const _8XY1 = struct {
    vx: u4,
    vy: u4,
};
const _8XY2 = struct {
    vx: u4,
    vy: u4,
};
const _8XY3 = struct {
    vx: u4,
    vy: u4,
};
const _8XY4 = struct {
    vx: u4,
    vy: u4,
};
const _8XY5 = struct {
    vx: u4,
    vy: u4,
};
const _8XY6 = struct {
    vx: u4,
    vy: u4,
};
const _8XY7 = struct {
    vx: u4,
    vy: u4,
};
const _9XY0 = struct {
    vx: u4,
    vy: u4,
};
const _ANNN = struct {
    immediate: u12,
};
const _BNNN = struct {
    immediate: u12,
};
const _DXYN = struct {
    x_register: u4,
    y_register: u4,
    height: u4,
};

const Instruction = union(enum) {
    clear_screen: _00E0,

    jump: _1NNN,
    jump_with_offset: _BNNN,

    call_function: _2NNN,
    return_function: _00EE,

    set_vx_to_vy: _8XY0,
    set_vx_to_vx_or_vy: _8XY1,
    set_vx_to_vx_and_vy: _8XY2,
    set_vx_to_vx_xor_vy: _8XY3,

    skip_if_vx_is_immediate: _3XNN,
    skip_if_vx_is_not_immediate: _4XNN,
    skip_if_vx_is_vy: _5XY0,
    skip_if_vx_is_not_vy: _9XY0,

    load_i_immediate: _ANNN,
    load_vx_immediate: _6XNN,

    add_vx_immediate: _7XNN,

    draw_sprite: _DXYN,
};
