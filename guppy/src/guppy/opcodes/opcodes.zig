const std = @import("std");
const components = @import("../components/components.zig");
const Step = *const fn (self: *OPCode, bus: *components.bus.Bus) void;

pub const OPCodeOptions = struct {
    length: u8,
    m_cycles: u8,
    t_cycles: u8,

    bytes: [3]u8,
    m_steps: [4]Step,
    t_steps: [16]Step,
};

pub const OPCode = struct {
    length: u8,
    m_cycles: u8,
    t_cycles: u8,

    bytes: [3]u8,
    m_steps: [4]Step,
    t_steps: [16]Step,

    a8: u8 = undefined,
    b8: u8 = undefined,
    c8: u8 = undefined,
    a16: u16 = undefined,

    pub fn init(options: OPCodeOptions) @This() {
        return .{
            .length = options.length,
            .m_cycles = options.m_cycles,
            .t_cycles = options.t_cycles,
            .bytes = options.bytes,
            .m_steps = options.m_steps,
            .t_steps = options.t_steps,
        };
    }
};
pub const m_steps_0x00 = blk: {
    const m: [4]Step = undefined;
    break :blk m;
};

pub const t_steps_0x00 = blk: {
    const t: [16]Step = undefined;
    break :blk t;
};

fn step_1_0x01(self: *OPCode, bus: *components.bus.Bus) void {
    self.a8 = bus.memory.data[bus.cpu.registers.get_pc()];
    bus.cpu.registers.inc_pc();
}
fn step_2_0x01(self: *OPCode, bus: *components.bus.Bus) void {
    self.b8 = bus.memory.data[bus.cpu.registers.get_pc()];
    bus.cpu.registers.inc_pc();
}
fn step_3_0x01(self: *OPCode, bus: *components.bus.Bus) void {
    bus.cpu.fetch(bus.memory);
    bus.cpu.registers.inc_pc();

    const data: [2]u8 = .{ self.b8, self.a8 };
    bus.cpu.registers.set_bc(
        std.mem.readInt(u16, &data, .little),
    );
}
pub const m_steps_0x01 = blk: {
    var m: [4]Step = undefined;
    m[0] = step_1_0x01;
    m[1] = step_2_0x01;
    m[2] = step_3_0x01;
    break :blk m;
};
pub const t_steps_0x01 = blk: {
    const t: [16]Step = undefined;
    break :blk t;
};
