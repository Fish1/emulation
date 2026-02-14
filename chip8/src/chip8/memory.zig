const std = @import("std");

pub const MAX_MEMORY = 4096;

pub const Memory = struct {
    data: [MAX_MEMORY]u8 = std.mem.zeroes([4096]u8),

    pub fn init() @This() {
        return .{};
    }
};
