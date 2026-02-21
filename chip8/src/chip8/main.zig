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

    var bus = Bus.init(.{
        .memory = &memory,
        .cpu = &cpu,
        .timers = &timers,
        .keyboard = &keyboard,
    });

    try window.init();
    defer window.deinit();

    // try bus.load_program("./bin/1-chip8-logo.ch8");
    // try bus.load_program("./bin/2-ibm-logo.ch8");
    // try bus.load_program("./bin/3-corax+.ch8");
    // try bus.load_program("./bin/4-flags.ch8");
    try bus.load_program("./bin/5-quirks.ch8");

    var quit = false;
    var tick_timer: f64 = 0.0;
    while (quit == false) {
        tick_timer = tick_timer + window.get_delta();

        while (window.poll()) |event| {
            switch (event) {
                .quit => quit = true,
                .key_1_down => keyboard.keys[0] = true,
                .key_2_down => keyboard.keys[1] = true,
                .key_3_down => keyboard.keys[2] = true,
                .key_c_down => keyboard.keys[3] = true,
                .key_4_down => keyboard.keys[4] = true,
                .key_5_down => keyboard.keys[5] = true,
                .key_6_down => keyboard.keys[6] = true,
                .key_d_down => keyboard.keys[7] = true,
                .key_7_down => keyboard.keys[8] = true,
                .key_8_down => keyboard.keys[9] = true,
                .key_9_down => keyboard.keys[10] = true,
                .key_e_down => keyboard.keys[11] = true,
                .key_a_down => keyboard.keys[12] = true,
                .key_0_down => keyboard.keys[13] = true,
                .key_b_down => keyboard.keys[14] = true,
                .key_f_down => keyboard.keys[15] = true,
                .key_1_up => keyboard.keys[0] = false,
                .key_2_up => keyboard.keys[1] = false,
                .key_3_up => keyboard.keys[2] = false,
                .key_c_up => keyboard.keys[3] = false,
                .key_4_up => keyboard.keys[4] = false,
                .key_5_up => keyboard.keys[5] = false,
                .key_6_up => keyboard.keys[6] = false,
                .key_d_up => keyboard.keys[7] = false,
                .key_7_up => keyboard.keys[8] = false,
                .key_8_up => keyboard.keys[9] = false,
                .key_9_up => keyboard.keys[10] = false,
                .key_e_up => keyboard.keys[11] = false,
                .key_a_up => keyboard.keys[12] = false,
                .key_0_up => keyboard.keys[13] = false,
                .key_b_up => keyboard.keys[14] = false,
                .key_f_up => keyboard.keys[15] = false,
                else => {},
            }
        }

        if (tick_timer >= 0.01) {
            try bus.tick(tick_timer);
            tick_timer = 0.0;
        }

        try window.render();
    }
}
