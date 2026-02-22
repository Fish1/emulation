const std = @import("std");

pub const Timers = struct {
    delay: u8 = 0,
    sound: u8 = 0,

    pub fn init() @This() {
        return .{};
    }

    pub fn tick(self: *@This()) void {
        if (self.delay > 0) {
            self.delay = self.delay - 1;
        }

        if (self.sound > 0) {
            self.sound = self.sound - 1;
        }
    }
};
