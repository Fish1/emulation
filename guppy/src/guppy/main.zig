const std = @import("std");
const components = @import("components/components.zig");
const sst = @import("single-step-tests.zig");

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
            bus.tick();
        }

        delta = timer.read();
        timer.reset();
    }
}

test "cpu single step tests" {
    const data = try std.fs.cwd().readFileAlloc(std.testing.allocator, "./tests/sm83/v1/01.json", 1000000);
    defer std.testing.allocator.free(data);

    const result: std.json.Parsed(sst.Tests) = try std.json.parseFromSlice(sst.Tests, std.testing.allocator, data, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    for (result.value) |t| {
        std.debug.print("running test: {s}\n", .{t.name});
        std.debug.print("{any}\n", .{t.initial});
        var memory = components.memory.Memory.init_test(t.initial);
        var cpu = components.cpu.CPU.init_test(t.initial);
        cpu.fetch(&memory);
        cpu.registers.inc_pc();
        var bus = components.bus.Bus.init(.{
            .cpu = &cpu,
            .memory = &memory,
        });
        while (cpu.opcode_count <= 1) {
            bus.tick();
        }

        try std.testing.expect(memory.validate_test(t.final));
        try std.testing.expect(cpu.validate_test(t.final));
    }
}
