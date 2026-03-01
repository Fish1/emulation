const std = @import("std");

const sst = @import("../single-step-tests.zig");

const Memory = @import("memory.zig").Memory;
const Registers = @import("registers.zig").Registers;
const OPCode = @import("../opcodes/opcodes.zig").OPCode;

const cds = @import("../opcodes/opcodes.zig");

pub const CPUError = error{
    failed_to_parse,
};

const OC = union {
    oc_0_1: OPCode(0, 1),
    oc_1_1: OPCode(1, 1),
    oc_2_1: OPCode(2, 1),
    oc_0_2: OPCode(0, 2),
    oc_1_2: OPCode(1, 2),
    oc_2_2: OPCode(2, 2),
    oc_0_3: OPCode(0, 3),
    oc_1_3: OPCode(1, 3),
    oc_2_3: OPCode(2, 3),
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
                .oc_0_1 = .init(.{
                    .t_cycles = 4,
                    .m_cycles = 1,
                    .bytes = .{self.code},
                    .steps = .{},
                }),
            },
            0x01 => OC{
                .oc_2_3 = .init(.{
                    .t_cycles = 12,
                    .m_cycles = 3,
                    .bytes = .{ self.code, 0, 0 },
                    .steps = cds.steps_0x01,
                }),
            },
            else => {
                std.log.err("failed to parse code: 0x{x:0>2}", .{self.code});
                return CPUError.failed_to_parse;
            },
        };
    }

    pub fn execute(_: *@This()) void {}
};
