const Step = *const fn (self: *OPCode) void;

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

fn step_1_0x01(_: *OPCode) void {}
fn step_2_0x01(_: *OPCode) void {}
pub const m_steps_0x01 = blk: {
    var m: [4]Step = undefined;
    m[0] = step_1_0x01;
    m[1] = step_2_0x01;
    break :blk m;
};
pub const t_steps_0x01 = blk: {
    var t: [16]Step = undefined;
    t[0] = step_1_0x01;
    t[1] = step_2_0x01;
    break :blk t;
};
