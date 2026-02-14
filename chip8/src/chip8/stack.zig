const std = @import("std");

pub const MAX_STACK = 32;

pub const StackError = error{
    out_of_memory,
};

pub const Stack = struct {
    data: [MAX_STACK]u8 = std.mem.zeroes([MAX_STACK]u8),
    length: u8 = 0,

    pub fn init() @This() {
        return .{};
    }

    pub fn append(self: *@This(), address: u8) void {
        self.data[self.length] = address;
        self.length = self.length + 1;
    }

    pub fn pop(self: *@This()) u8 {
        self.length = self.length - 1;
        return self.data[self.length];
    }

    pub fn peek(self: @This()) u8 {
        return self.data[self.length - 1];
    }
};
