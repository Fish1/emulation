const std = @import("std");

const components = @import("components.zig");

const CPUError = error{
    unknown_instruction,
    unimplemented_instruction,
};

pub const CPU = struct {
    pub fn init() @This() {
        return .{};
    }

    pub fn execute(_: @This(), data: u16) CPUError!void {
        try execute_instruction(
            try parse_instruction(data),
        );
    }

    fn parse_instruction(data: u16) CPUError!Instruction {
        std.debug.print("parse: {any}\n", .{data});

        const a = (data & 0xf000) >> 12;
        _ = (data & 0x0f00) >> 8;
        _ = (data & 0x00f0) >> 4;
        _ = (data & 0x000f) >> 4;

        return switch (a) {
            0 => .{ .clear_screen = .{} },
            1 => .{ .jump = .{ .location = @intCast(data & 0x0fff) } },
            else => CPUError.unknown_instruction,
        };
    }

    fn execute_instruction(instruction: Instruction) CPUError!void {
        std.debug.print("execute: {any}\n", .{instruction});
        switch (instruction) {
            .clear_screen => {
                std.debug.print("clearing screen\n", .{});
            },
            .jump => |jump| {
                std.debug.print("jump to {any}\n", .{jump.location});
            },
            else => return CPUError.unimplemented_instruction,
        }
    }
};

const _00E0 = struct {};
const _6XNN = struct {};
const _ANNN = struct {};
const _DXYN = struct {};
const _1NNN = struct {
    location: u12,
};

const Instruction = union(enum) {
    clear_screen: _00E0,
    load_index_register_with_immediate_value: _6XNN,
    load_register_with_immediate_value: _ANNN,
    draw_sprite_to_screen: _DXYN,
    jump: _1NNN,
};
