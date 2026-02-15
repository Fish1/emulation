const std = @import("std");

const window = @import("window");
const components = @import("./components.zig");

const Mother = @import("mother.zig").Mother;

pub fn main() !void {
    var memory = components.memory.Memory.init();
    var program_counter = components.program_counter.ProgramCounter.init();
    var registers = components.registers.Registers.init();
    const cpu = components.cpu.CPU.init();

    var mother = Mother.init(.{
        .memory = &memory,
        .program_counter = &program_counter,
        .registers = &registers,
        .cpu = &cpu,
    });

    try window.init();
    defer window.deinit();

    try mother.load_program("./bin/1-chip8-logo.ch8");

    var quit = false;
    while (quit == false) {
        while (window.poll()) |event| {
            switch (event) {
                .quit => quit = true,
                else => {},
            }
        }

        try mother.tick();
    }
}
