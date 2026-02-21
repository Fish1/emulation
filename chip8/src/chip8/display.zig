const window = @import("window");

pub const Display = struct {
    render_timer: f64 = 0.0,

    pub fn init() @This() {
        return .{};
    }

    pub fn tick(this: *@This(), delta: f64) window.RenderError!void {
        this.render_timer = this.render_timer + delta;

        if (this.render_timer >= (1.0 / 60.0)) {
            try window.show();
        }

        try window.tick();
    }
};
