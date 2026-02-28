pub fn Options(steps: usize) type {
    return struct {
        value: u8,
        length: u8,
        t_cycles: u8,
        m_cycles: u8,
        steps: [steps](*const fn (self: @This()) void),
    };
}

pub fn OPCode(steps: usize) type {
    return struct {
        value: u8 = 0,
        length: u8 = 0,
        t_cycles: u8 = 0,
        m_cycles: u8 = 0,
        steps: [steps](*const fn (self: Options(steps)) void),

        pub fn init(options: Options(steps)) @This() {
            return .{
                .value = options.value,
                .length = options.length,
                .t_cycles = options.t_cycles,
                .m_cycles = options.m_cycles,
                .steps = options.steps,
            };
        }
    };
}
