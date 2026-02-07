pub fn Registers() type {
    return struct {
        IR: u8,
        IE: u8,

        A: u8,
        F: u8,

        B: u8,
        C: u8,

        D: u8,
        E: u8,

        H: u8,
        L: u8,

        PC: u16,
        SP: u16,

        pub fn init() @This() {
            return .{
                .IR = 0,
                .IE = 0,
                .A = 0,
                .F = 0,
                .B = 0,
                .C = 0,
                .D = 0,
                .E = 0,
                .H = 0,
                .L = 0,
                .PC = 0,
                .SP = 0,
            };
        }

        pub fn getBC(this: @This()) u16 {
            const b = @as(u16, this.B);
            const c = @as(u16, this.C);
            return (b << 8) | c;
        }

        pub fn setBC(this: *@This(), value: u16) void {
            this.B = @intCast(value >> 8);
            this.L = @intCast(value & 0b11111111);
        }

        pub fn getDE(this: @This()) u16 {
            const d = @as(u16, this.D);
            const e = @as(u16, this.E);
            return (d << 8) | e;
        }

        pub fn setDE(this: *@This(), value: u16) void {
            this.D = @intCast(value >> 8);
            this.E = @intCast(value & 0b11111111);
        }

        pub fn getHL(this: @This()) u16 {
            const h = @as(u16, this.H);
            const l = @as(u16, this.L);
            return (h << 8) | l;
        }

        pub fn setHL(this: *@This(), value: u16) void {
            this.H = @intCast(value >> 8);
            this.L = @intCast(value & 0b11111111);
        }

        pub fn setZero(this: *@This(), value: bool) void {
            this.F = (this.F & 0b01111111) | (@as(u8, @intFromBool(value)) << 7);
        }

        pub fn readZero(this: *@This()) bool {
            return this.F & 0b10000000 != 0;
        }

        pub fn setSubtraction(this: *@This(), value: bool) void {
            this.F = (this.F & 0b10111111) | (@as(u8, @intFromBool(value)) << 6);
        }

        pub fn setHalfCarry(this: *@This(), value: bool) void {
            this.F = (this.F & 0b11011111) | (@as(u8, @intFromBool(value)) << 5);
        }

        pub fn setCarry(this: *@This(), value: bool) void {
            this.F = (this.F & 0b11101111) | (@as(u8, @intFromBool(value)) << 4);
        }
    };
}
