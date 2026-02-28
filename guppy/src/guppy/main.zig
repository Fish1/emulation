const std = @import("std");
const components = @import("components/components.zig");

pub fn main() !void {
    std.log.info("Project Guppy!", .{});

    var memory = components.memory.Memory.init();
    var cpu = components.cpu.CPU.init();

    var bus = components.bus.Bus.init(.{
        .cpu = &cpu,
        .memory = &memory,
    });

    // try bus.load_rom("./bin/01-special.bin");
    try bus.load_rom("./bin/tetris.bin");
    try bus.load_boot("./bin/boot.bin");
    memory.print_rom_info();

    const ticks_per_second = 100000;
    const tick_time = @divFloor(std.time.ns_per_min, ticks_per_second);

    var timer: std.time.Timer = try .start();
    var delta: u64 = 0.0;
    var tick_timer: u64 = 0.0;
    while (true) {
        tick_timer = tick_timer + delta;
        if (tick_timer >= tick_time) {
            tick_timer = 0;
            try bus.tick();
        }

        delta = timer.read();
        timer.reset();
    }
}
