const std = @import("std");

const window = @import("window");
const components = @import("./components.zig");

const Bus = @import("bus.zig").Bus;

pub const std_options: std.Options = .{
    .log_level = .debug,
};

pub fn main() !void {
    var memory = components.memory.Memory.init();
    var cpu = components.cpu.CPU.init();
    var timers = components.timers.Timers.init();
    var keyboard = components.keyboard.Keyboard.init();
    var display = components.display.Display.init();

    var bus = Bus.init(.{
        .memory = &memory,
        .cpu = &cpu,
        .timers = &timers,
        .keyboard = &keyboard,
        .display = &display,
    });

    try window.init();
    defer window.deinit();

    // try bus.load_program("./bin/1-chip8-logo.ch8");
    // try bus.load_program("./bin/2-ibm-logo.ch8");
    // try bus.load_program("./bin/3-corax+.ch8");
    // try bus.load_program("./bin/4-flags.ch8");

    try bus.load_bios("./bin/bios.ch8");
    try bus.load_program("./bin/5-quirks.ch8");

    var quit = false;
    while (quit == false) {
        while (window.poll()) |event| {
            keyboard.handle_event(event);
            switch (event) {
                .quit => quit = true,
                else => {},
            }
        }

        try bus.tick(window.get_delta());
    }
}
