const std = @import("std");

pub fn Memory() type {
    return struct {
        memory: [std.math.maxInt(u16)]u8,

        pub fn init() @This() {
            return .{ .memory = undefined };
        }

        /// Load ROM from file into memory.
        pub fn loadROM(this: *@This(), path: []const u8) !void {
            const file = try std.fs.openFileAbsolute(path, .{});
            defer file.close();

            var file_buffer = std.io.bufferedReader(file.reader());
            var buffer: [1]u8 = undefined;

            var offset: usize = 0;
            while (try file_buffer.read(&buffer) != 0) {
                this.memory[offset] = buffer[0];
                offset += 1;
            }
        }

        /// Read from an address in memory.
        pub fn read(this: @This(), address: usize) u8 {
            return this.memory[address];
        }

        /// Write to an address in memory.
        pub fn write(this: *@This(), address: u16, value: u8) void {
            this.memory[address] = value;
        }
    };
}
