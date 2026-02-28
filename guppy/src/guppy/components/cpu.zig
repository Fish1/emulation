const std = @import("std");

const Memory = @import("memory.zig").Memory;
const Registers = @import("registers.zig").Registers;
const OPCode = @import("../opcodes.zig").OPCode;

pub const CPUError = error{
    failed_to_parse,
};

const OC = union {
    oc0: OPCode(0),
    oc1: OPCode(1),
    oc2: OPCode(2),
    oc3: OPCode(3),
    oc4: OPCode(4),
};

pub const CPU = struct {
    registers: Registers = .init(),

    code: u8 = undefined,
    opcode: OC = undefined,

    pub fn init() @This() {
        var result: @This() = .{};
        result.registers.set_pc(0x4000);
        result.registers.set_pc(0x0000);
        return result;
    }

    pub fn fetch(self: *@This(), memory: *Memory) void {
        const pc = self.registers.get_pc();
        self.code = memory.data[pc];
        if (pc + 1 > 0x7fff) {
            std.debug.print("go back\n", .{});
            self.registers.set_pc(0x0150);
        } else {
            self.registers.set_pc(pc + 1);
        }
    }

    pub fn parse(self: *@This()) CPUError!void {
        self.opcode = switch (self.code) {
            0x00 => OC{
                .oc0 = .init(.{
                    .value = self.code,
                    .length = 1,
                    .t_cycles = 4,
                    .m_cycles = 1,
                    .steps = .{},
                }),
            },
            0x13 => OC{
                .oc0 = .init(.{
                    .value = self.code,
                    .length = 1,
                    .t_cycles = 8,
                    .m_cycles = 2,
                    .steps = .{},
                }),
            },
            0x31 => OC{
                .oc0 = .init(.{
                    .value = self.code,
                    .length = 3,
                    .t_cycles = 12,
                    .m_cycles = 3,
                    .steps = .{},
                }),
            },
            0xc3 => OC{
                .oc0 = .init(.{
                    .value = self.code,
                    .length = 3,
                    .t_cycles = 16,
                    .m_cycles = 4,
                    .steps = .{},
                }),
            },
            0xfe => OC{
                .oc0 = .init(.{
                    .value = self.code,
                    .length = 2,
                    .t_cycles = 8,
                    .m_cycles = 2,
                    .steps = .{},
                }),
            },
            else => {
                std.log.err("failed to parse code: 0x{x:0>2}", .{self.code});
                return CPUError.failed_to_parse;
            },
        };

        if (self.code != 0) {
            std.debug.print("pc = {any} , opcode = {any} , byte = 0x{x:0>2}\n", .{ self.registers.get_pc(), self.opcode, self.code });
        }
    }

    pub fn execute(_: *@This()) void {}
};
