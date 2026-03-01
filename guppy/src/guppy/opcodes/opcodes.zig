pub fn Options(steps: usize, bytes: usize) type {
    return struct {
        t_cycles: u8,
        m_cycles: u8,

        bytes: [bytes]u8,
        steps: [steps](*const fn (self: @This()) void),
    };
}

pub fn OPCode(steps: usize, bytes: usize) type {
    return struct {
        t_cycles: u8 = 0,
        m_cycles: u8 = 0,

        bytes: [bytes]u8,
        steps: [steps](*const fn (self: Options(steps, bytes)) void),

        pub fn init(options: Options(steps, bytes)) @This() {
            return .{
                .t_cycles = options.t_cycles,
                .m_cycles = options.m_cycles,
                .bytes = options.bytes,
                .steps = options.steps,
            };
        }
    };
}

fn step_1_0x01(_: Options(2, 3)) void {}
fn step_2_0x01(_: Options(2, 3)) void {}
pub const steps_0x01 = .{ step_1_0x01, step_2_0x01 };
