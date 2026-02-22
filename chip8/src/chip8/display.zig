const window = @import("window");

pub const Display = struct {
    pub fn init() @This() {
        return .{};
    }

    pub fn tick(_: *@This()) window.RenderError!void {
        try window.flip_buffer();
        try window.show_display();
    }
};
