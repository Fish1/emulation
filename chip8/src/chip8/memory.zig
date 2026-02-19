const std = @import("std");

pub const MAX_MEMORY = 4096;

pub const MemoryErrors = error{
    outside_memory,
};

pub const Memory = struct {
    counter: u16 = 0x200,
    data: [MAX_MEMORY]u8 = std.mem.zeroes([4096]u8),

    pub fn init() @This() {
        return .{};
    }

    pub fn increment_counter(self: *@This()) MemoryErrors!void {
        if (self.counter + 2 >= MAX_MEMORY) {
            return MemoryErrors.outside_memory;
        }
        self.counter = self.counter + 2;
    }

    pub fn get_byte(self: @This()) u8 {
        return self.data[self.counter];
    }

    pub fn get_instruction(self: @This()) u16 {
        const low: u16 = self.data[self.counter];
        const high: u16 = self.data[self.counter + 1];
        return (low << 8) | high;
    }
};
