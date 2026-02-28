const std = @import("std");

const sst = @import("../single-step-tests.zig");

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

    pub fn init_test(initial: sst.Initial) @This() {
        var result: @This() = .{};
        result.registers.data = .{
            initial.a, initial.f,
            initial.b, initial.c,
            initial.d, initial.e,
            initial.h, initial.l,
            0,         0,
            0,         0,
        };
        result.registers.set_sp(initial.sp);
        result.registers.set_pc(initial.pc);
        return result;
    }

    pub fn validate_test(self: @This(), final: sst.Final) bool {
        return final.a == self.registers.data[0] and
            final.f == self.registers.data[1] and
            final.b == self.registers.data[2] and
            final.c == self.registers.data[3] and
            final.d == self.registers.data[4] and
            final.e == self.registers.data[5] and
            final.h == self.registers.data[6] and
            final.l == self.registers.data[7] and
            final.sp == self.registers.get_sp() and
            final.pc == self.registers.get_pc();
    }

    pub fn fetch(self: *@This(), memory: *Memory) void {
        const pc = self.registers.get_pc();
        self.code = memory.data[pc];
        self.registers.set_pc(pc + 1);
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
            0x01 => OC{
                .oc3 = .init(.{
                    .value = self.code,
                    .length = 1,
                    .t_cycles = 12,
                    .m_cycles = 3,
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
