pub const Timers = struct {
    delay: u8 = 0,
    sound: u8 = 0,

    _time: f64 = 0.0,

    pub fn init() @This() {
        return .{};
    }

    pub fn process(self: *@This(), delta: f64) void {
        self._time = self._time + delta;

        if (self._time >= (1.0 / 60.0)) {
            if (self.delay > 0) {
                self.delay = self.delay - 1;
            }
            if (self.sound > 0) {
                self.sound = self.sound - 1;
            }
            self._time = 0.0;
        }
    }
};
