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

test "cpu single step tests" {
    const data = try std.fs.cwd().readFileAlloc(std.testing.allocator, "./tests/sm83/v1/00.json", 1000000);
    defer std.testing.allocator.free(data);

    const Data = []struct {
        name: []u8,
        initial: struct {
            pc: u16,
            sp: u16,
            a: u8,
            b: u8,
            c: u8,
            d: u8,
            e: u8,
            f: u8,
            h: u8,
            l: u8,
            ime: u8,
            ie: u8,
            ram: [][]u16,
        },
        final: struct {
            pc: u16,
            sp: u16,
            a: u8,
            b: u8,
            c: u8,
            d: u8,
            e: u8,
            f: u8,
            h: u8,
            l: u8,
            ime: u8,
            ram: [][]u16,
        },
    };

    const result: std.json.Parsed(Data) = try std.json.parseFromSlice(Data, std.testing.allocator, data, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    for (result.value) |t| {
        const cpu = components.cpu.CPU.init();
        std.debug.print("{s}\n", .{t.name});
    }
}
