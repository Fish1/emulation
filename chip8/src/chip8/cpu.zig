const std = @import("std");
const window = @import("window");

const components = @import("components.zig");

const CPUError = error{
    unknown_instruction,
    unimplemented_instruction,
};

pub const CPU = struct {
    pub fn init() @This() {
        return .{};
    }

    pub fn execute(_: @This(), data: u16, program_counter: *components.program_counter.ProgramCounter) CPUError!void {
        try execute_instruction(
            try parse_instruction(data),
            program_counter,
        );
    }

    fn parse_instruction(data: u16) CPUError!Instruction {
        std.debug.print("parse: 0x{X:0>4}\n", .{data});

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
            0xA => .{
                .load_i_immediate = .{
                    .immediate = @intCast(bcd),
                },
            },
            0xD => .{
                .draw_sprite = .{
                    .x = @intCast(b),
                    .y = @intCast(c),
                    .size = @intCast(d),
                },
            },
            else => CPUError.unknown_instruction,
        };
    }

    fn execute_instruction(instruction: Instruction, program_counter: *components.program_counter.ProgramCounter) CPUError!void {
        std.debug.print("execute: {any}\n", .{instruction});
        switch (instruction) {
            .clear_screen => {
                window.clear_screen() catch return;
            },
            .jump => |jump| {
                program_counter.index = jump.address;
            },
            .load_vx_immediate => |_| {},
            .load_i_immediate => |_| {},
            .draw_sprite => |_| {},
            // else => return CPUError.unimplemented_instruction,
        }
    }
};

const _00E0 = struct {};
const _6XNN = struct {
    vx: u4,
    immediate: u8,
};
const _ANNN = struct {
    immediate: u12,
};
const _DXYN = struct {
    x: u4,
    y: u4,
    size: u4,
};
const _1NNN = struct {
    address: u12,
};

const Instruction = union(enum) {
    clear_screen: _00E0,
    load_vx_immediate: _6XNN,
    load_i_immediate: _ANNN,
    draw_sprite: _DXYN,
    jump: _1NNN,
};
