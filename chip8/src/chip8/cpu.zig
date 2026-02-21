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

    wait_for_key: bool = false,
    wait_for_key_register: u4 = 0,

    pub fn init() @This() {
        return .{};
    }

    pub fn tick(
        self: *@This(),
        data: u16,
        memory: *components.memory.Memory,
        timers: *components.timers.Timers,
        keyboard: *components.keyboard.Keyboard,
    ) CPUError!void {
        if (self.wait_for_key) {
            // std.debug.print("waiting for key\n", .{});
            for (keyboard.keys, 0..16) |key, index| {
                if (key == .just_released) {
                    self.registers.r[self.wait_for_key_register] = @intCast(index);
                    self.wait_for_key_register = 0;
                    self.wait_for_key = false;
                }
            }
            //return;
        }

        try self.execute_instruction(
            try self.parse_instruction(data),
            memory,
            timers,
            keyboard,
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
                0x0 => .{
                    .set_vx_to_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x1 => .{
                    .set_vx_to_vx_or_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x2 => .{
                    .set_vx_to_vx_and_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x3 => .{
                    .set_vx_to_vx_xor_vy = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x4 => .{
                    .add_vy_to_vx = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x5 => .{
                    .subtract_vy_from_vx = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x6 => .{
                    .set_vx_to_vy_shift_vx_right = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0x7 => .{
                    .set_vx_to_vy_minus_vx = .{
                        .vx = @intCast(b),
                        .vy = @intCast(c),
                    },
                },
                0xE => .{
                    .set_vx_to_vy_shift_vx_left = .{
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
                    .vx = @intCast(b),
                    .vy = @intCast(c),
                    .height = @intCast(d),
                },
            },
            0xE => switch (cd) {
                0x9E => .{
                    .skip_if_pressed = .{
                        .vx = @intCast(b),
                    },
                },
                0xA1 => .{
                    .skip_if_not_pressed = .{
                        .vx = @intCast(b),
                    },
                },
                else => CPUError.unknown_instruction,
            },
            0xF => switch (cd) {
                0x07 => .{
                    .set_vx_to_delay_timer = .{
                        .vx = @intCast(b),
                    },
                },
                0x0A => .{
                    .wait_for_key = .{
                        .vx = @intCast(b),
                    },
                },
                0x15 => .{
                    .set_delay_timer_to_vx = .{
                        .vx = @intCast(b),
                    },
                },
                0x1E => .{
                    .add_vx_to_i = .{
                        .vx = @intCast(b),
                    },
                },
                0x33 => .{
                    .write_vx_to_memory = .{
                        .vx = @intCast(b),
                    },
                },
                0x55 => .{
                    .write_bytes_to_memory = .{
                        .vx = @intCast(b),
                    },
                },
                0x65 => .{
                    .read_bytes_to_registers = .{
                        .vx = @intCast(b),
                    },
                },
                else => CPUError.unknown_instruction,
            },
            else => CPUError.unknown_instruction,
        };
    }

    fn execute_instruction(
        self: *@This(),
        instruction: Instruction,
        memory: *components.memory.Memory,
        timers: *components.timers.Timers,
        keyboard: *components.keyboard.Keyboard,
    ) CPUError!void {
        std.log.debug("execute {any}", .{instruction});
        // std.log.debug("registers {any}", .{self.registers});
        return switch (instruction) {
            .clear_screen => {
                window.clear_screen() catch return CPUError.failed_to_draw;
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
                self.registers.r[0xF] = 0;
            },
            .set_vx_to_vx_and_vy => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vx] & self.registers.r[i.vy];
                self.registers.r[0xF] = 0;
            },
            .set_vx_to_vx_xor_vy => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vx] ^ self.registers.r[i.vy];
                self.registers.r[0xF] = 0;
            },

            .add_vy_to_vx => |i| {
                const result = @addWithOverflow(self.registers.r[i.vx], self.registers.r[i.vy]);
                self.registers.r[i.vx] = result[0];
                self.registers.r[0xF] = result[1];
            },
            .subtract_vy_from_vx => |i| {
                const result = @subWithOverflow(self.registers.r[i.vx], self.registers.r[i.vy]);
                self.registers.r[i.vx] = result[0];
                self.registers.r[0xF] = result[1] ^ 0x1;
            },

            .set_vx_to_vy_minus_vx => |i| {
                const result = @subWithOverflow(self.registers.r[i.vy], self.registers.r[i.vx]);
                self.registers.r[i.vx] = result[0];
                self.registers.r[0xF] = result[1] ^ 0x1;
            },

            .set_vx_to_vy_shift_vx_right => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vy];
                const flag = self.registers.r[i.vx] & 0b00000001;
                self.registers.r[i.vx] = self.registers.r[i.vx] >> 1;
                self.registers.r[0xF] = flag;
            },

            .set_vx_to_vy_shift_vx_left => |i| {
                self.registers.r[i.vx] = self.registers.r[i.vy];
                const flag = (self.registers.r[i.vx] & 0b10000000) >> 7;
                self.registers.r[i.vx] = self.registers.r[i.vx] << 1;
                self.registers.r[0xF] = flag;
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
            .skip_if_pressed => |i| {
                const key = self.registers.r[i.vx];
                if (keyboard.keys[key] == .just_pressed or keyboard.keys[key] == .pressed) {
                    memory.counter = memory.counter + 2;
                }
            },
            .skip_if_not_pressed => |i| {
                const key = self.registers.r[i.vx];
                if (keyboard.keys[key] == .just_released or keyboard.keys[key] == .released) {
                    memory.counter = memory.counter + 2;
                }
            },
            .wait_for_key => |i| {
                self.wait_for_key_register = i.vx;
                self.wait_for_key = true;
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

            .add_vx_to_i => |i| {
                self.registers.i = self.registers.i + self.registers.r[i.vx];
            },

            .write_vx_to_memory => |i| {
                const value: u16 = @intCast(self.registers.r[i.vx]);
                const a = @mod(value, 10);
                const b = @divFloor(@mod(value, 100), 10);
                const c = @divFloor(@mod(value, 1000), 100);
                memory.data[self.registers.i] = @intCast(c);
                memory.data[self.registers.i + 1] = @intCast(b);
                memory.data[self.registers.i + 2] = @intCast(a);
            },

            .write_bytes_to_memory => |i| {
                for (0..i.vx + 1) |register| {
                    memory.data[self.registers.i + register] = self.registers.r[register];
                }

                self.registers.i = self.registers.i + i.vx + 1;
            },

            .read_bytes_to_registers => |i| {
                for (0..i.vx + 1) |register| {
                    self.registers.r[register] = memory.query_byte(self.registers.i + @as(u16, @intCast(register)));
                }

                self.registers.i = self.registers.i + i.vx + 1;
            },

            .set_delay_timer_to_vx => |i| {
                timers.delay = self.registers.r[i.vx];
            },
            .set_vx_to_delay_timer => |i| {
                self.registers.r[i.vx] = timers.delay;
            },

            .draw_sprite => |i| {
                const start_x = self.registers.r[i.vx];
                const start_y = self.registers.r[i.vy];
                const height = i.height;

                var unset: bool = false;
                for (0..height) |offset_y| {
                    const address = self.registers.i + offset_y;
                    inline for (0..8) |offset_x| {
                        const bit: u1 = @intFromBool((0b10000000 >> offset_x) & memory.data[address] != 0);
                        const render_x = start_x + @as(u8, @intCast(offset_x));
                        const render_y = start_y + @as(u8, @intCast(offset_y));
                        if (window.xor_pixel(render_x, render_y, bit) catch {
                            return CPUError.failed_to_draw;
                        }) {
                            unset = true;
                        }
                    }
                }

                self.registers.r[0xF] = @intFromBool(unset);
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
const _8XYE = struct {
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
    vx: u4,
    vy: u4,
    height: u4,
};
const _EX9E = struct {
    vx: u4,
};
const _EXA1 = struct {
    vx: u4,
};
const _FX07 = struct {
    vx: u4,
};
const _FX0A = struct {
    vx: u4,
};
const _FX15 = struct {
    vx: u4,
};
const _FX1E = struct {
    vx: u4,
};
const _FX33 = struct {
    vx: u4,
};
const _FX55 = struct {
    vx: u4,
};
const _FX65 = struct {
    vx: u4,
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

    add_vy_to_vx: _8XY4,
    subtract_vy_from_vx: _8XY5,

    set_vx_to_vy_minus_vx: _8XY7,

    set_vx_to_vy_shift_vx_right: _8XY6,
    set_vx_to_vy_shift_vx_left: _8XYE,

    skip_if_vx_is_immediate: _3XNN,
    skip_if_vx_is_not_immediate: _4XNN,
    skip_if_vx_is_vy: _5XY0,
    skip_if_vx_is_not_vy: _9XY0,
    skip_if_pressed: _EX9E,
    skip_if_not_pressed: _EXA1,
    wait_for_key: _FX0A,

    load_i_immediate: _ANNN,
    load_vx_immediate: _6XNN,

    add_vx_immediate: _7XNN,

    add_vx_to_i: _FX1E,

    write_vx_to_memory: _FX33,
    write_bytes_to_memory: _FX55,
    read_bytes_to_registers: _FX65,

    set_delay_timer_to_vx: _FX15,
    set_vx_to_delay_timer: _FX07,

    draw_sprite: _DXYN,
};
