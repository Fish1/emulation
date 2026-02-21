const std = @import("std");

pub const Keyboard = struct {
    keys: [16]bool = std.mem.zeroes([16]bool),

    pub fn init() @This() {
        return .{};
    }
};
