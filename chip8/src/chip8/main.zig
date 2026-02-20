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

    var bus = Bus.init(.{
        .memory = &memory,
        .cpu = &cpu,
    });

    try window.init();
    defer window.deinit();

    // try bus.load_program("./bin/1-chip8-logo.ch8");
    // try bus.load_program("./bin/2-ibm-logo.ch8");
    // try bus.load_program("./bin/3-corax+.ch8");
    try bus.load_program("./bin/4-flags.ch8");

    var quit = false;
    var tick_timer: f64 = 0.0;
    while (quit == false) {
        tick_timer = tick_timer + window.get_delta();

        while (window.poll()) |event| {
            switch (event) {
                .quit => quit = true,
                else => {},
            }
        }

        if (tick_timer >= 0.01) {
            try bus.tick();
            tick_timer = 0.0;
        }

        try window.render();
    }
}
