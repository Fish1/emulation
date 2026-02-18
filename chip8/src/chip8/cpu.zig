const std = @import("std");
const window = @import("window");

const components = @import("components.zig");

const CPUError = error{
    unknown_instruction,
    unimplemented_instruction,
    failed_to_draw,
};

pub const CPU = struct {
    pub fn init() @This() {
        return .{};
    }

    pub fn execute(
        self: @This(),
        data: u16,
        program_counter: *components.program_counter.ProgramCounter,
        registers: *components.registers.Registers,
        memory: *components.memory.Memory,
    ) CPUError!void {
        try self.execute_instruction(
            try self.parse_instruction(data),
            program_counter,
            registers,
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
                else => CPUError.unknown_instruction,
            },
            0x1 => .{
                .jump = .{
                    .address = @intCast(bcd),
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
            0xA => .{
                .load_i_immediate = .{
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
        _: @This(),
        instruction: Instruction,
        program_counter: *components.program_counter.ProgramCounter,
        registers: *components.registers.Registers,
        memory: *components.memory.Memory,
    ) CPUError!void {
        std.log.debug("execute {any}", .{instruction});
        return switch (instruction) {
            .clear_screen => {
                window.clear_screen() catch return;
            },
            .jump => |i| {
                program_counter.index = i.address;
            },
            .load_vx_immediate => |i| {
                registers.r[i.vx] = i.immediate;
            },
            .add_vx_immediate => |i| {
                registers.r[i.vx] = registers.r[i.vx] + i.immediate;
            },
            .load_i_immediate => |i| {
                registers.i = i.immediate;
            },
            .draw_sprite => |i| {
                const start_x = registers.r[i.x_register];
                const start_y = registers.r[i.y_register];
                const height = i.height;

                for (0..height) |offset_y| {
                    const address = registers.i + offset_y;
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
const _1NNN = struct {
    address: u12,
};
const _6XNN = struct {
    vx: u4,
    immediate: u8,
};
const _7XNN = struct {
    vx: u4,
    immediate: u8,
};
const _ANNN = struct {
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
    load_vx_immediate: _6XNN,
    add_vx_immediate: _7XNN,
    load_i_immediate: _ANNN,
    draw_sprite: _DXYN,
};
