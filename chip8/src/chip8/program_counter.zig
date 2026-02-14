const std = @import("std");
const components = @import("components.zig");

pub const ProgramCounterErrors = error{
    out_of_bounds,
};

pub const ProgramCounter = struct {
    index: u16 = 0,

    pub fn init() @This() {
        return .{};
    }

    pub fn increment(self: *@This()) ProgramCounterErrors!void {
        if (self.index + 2 >= components.memory.MAX_MEMORY) {
            return ProgramCounterErrors.out_of_bounds;
        }
        self.index = self.index + 2;
    }

    pub fn get_current_byte(self: @This(), memory: *components.memory.Memory) u8 {
        return memory.data[self.index];
    }

    pub fn get_current_instruction(self: @This(), memory: *components.memory.Memory) u16 {
        return std.mem.bytesAsSlice(u16, memory.data[self.index .. self.index + 1]);
    }
};
