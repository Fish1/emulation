const std = @import("std");

pub const Timers = struct {
    delay: u8 = 0,
    sound: u8 = 0,

    countdown_speed: f64 = 1.0 / 60.0,
    countdown_time: f64 = 0.0,

    pub fn init() @This() {
        return .{};
    }

    pub fn tick(self: *@This(), delta: f64) void {
        self.countdown_time = self.countdown_time + delta;

        if (self.countdown_time >= self.countdown_speed) {
            if (self.delay > 0) {
                self.delay = self.delay - 1;
                std.debug.print("delay = {any} -> {any}\n", .{ self.delay + 1, self.delay });
            }
            if (self.sound > 0) {
                self.sound = self.sound - 1;
            }
            self.countdown_time = 0.0;
        }
    }
};
