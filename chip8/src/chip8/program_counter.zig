const std = @import("std");
const components = @import("components.zig");

pub const ProgramCounterErrors = error{
    out_of_bounds,
};

pub const ProgramCounter = struct {
    index: u16 = 0x200,

    pub fn init() @This() {
        return .{};
    }

    pub fn goto_next_instruction(self: *@This()) ProgramCounterErrors!void {
        if (self.index + 2 >= components.memory.MAX_MEMORY) {
            return ProgramCounterErrors.out_of_bounds;
        }
        self.index = self.index + 2;
    }

    pub fn get_current_byte(self: @This(), memory: *components.memory.Memory) u8 {
        return memory.data[self.index];
    }

    pub fn get_current_instruction(self: @This(), memory: *components.memory.Memory) u16 {
        const low: u16 = memory.data[self.index];
        const high: u16 = memory.data[self.index + 1];
        const result = (low << 8) | high;
        // std.debug.print("low = 0x{X:0>2} high = 0x{X:0>2} result = 0x{X:0>4}\n", .{ low, high, result });
        return result;
        // return std.mem.bytesToValue(u16, memory.data[self.index .. self.index + 1]);
    }
};
