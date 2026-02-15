const std = @import("std");

pub const Registers = struct {
    i: u16 = 0,
    r: [16]u8 = std.mem.zeroes([16]u8),

    pub fn init() @This() {
        return .{};
    }
};
