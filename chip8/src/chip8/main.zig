const std = @import("std");

const window = @import("window");
const components = @import("./components.zig");

const Bus = @import("bus.zig").Bus;

pub const std_options: std.Options = .{
    .log_level = .debug,
};

pub fn main(init: std.process.Init) !void {
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

    try bus.load_bios(init.io, "./bin/bios.ch8");

    // try bus.load_program("./bin/1-chip8-logo.ch8");
    // try bus.load_program("./bin/2-ibm-logo.ch8");
    // try bus.load_program("./bin/3-corax+.ch8");
    // try bus.load_program("./bin/4-flags.ch8");
    // try bus.load_program("./bin/5-quirks.ch8");
    try bus.load_program(init.io, "./bin/6-keypad.ch8");

    var prev = std.Io.Timestamp.now(init.io, .real);
    var delta: f64 = 0.0;

    var quit = false;
    while (quit == false) {
        try window.tick();

        while (window.poll()) |event| {
            keyboard.handle_event(event);
            switch (event) {
                .quit => quit = true,
                else => {},
            }
        }

        // try bus.tick_burst(delta);
        try bus.tick_hertz(delta);

        const now = std.Io.Timestamp.now(init.io, .real);
        const diff = prev.durationTo(now).toNanoseconds();
        delta = @as(f64, @floatFromInt(diff)) / @as(f64, @floatFromInt(std.time.ns_per_s));
        prev = now;
    }
}
