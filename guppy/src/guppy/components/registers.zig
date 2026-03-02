const std = @import("std");

pub const Registers = struct {
    data: [12]u8 = std.mem.zeroes([12]u8),

    pub fn init() @This() {
        return .{};
    }

    pub fn get_a(self: @This()) u8 {
        return self.data[0];
    }

    pub fn set_a(self: @This(), value: u8) void {
        self.data[0] = value;
    }

    pub fn get_f(self: @This()) u8 {
        return self.data[1];
    }

    pub fn set_f(self: @This(), value: u8) void {
        self.data[1] = value;
    }

    pub fn get_u16(self: @This(), index: u4) u16 {
        return std.mem.readInt(u16, self.data[index..][0..2], .little);
    }

    pub fn set_u16(self: *@This(), index: u4, value: u16) void {
        return std.mem.writeInt(u16, self.data[index..][0..2], value, .little);
    }

    pub fn get_b(self: @This()) u8 {
        return self.data[2];
    }

    pub fn get_c(self: @This()) u8 {
        return self.data[3];
    }

    pub fn get_d(self: @This()) u8 {
        return self.data[4];
    }

    pub fn get_e(self: @This()) u8 {
        return self.data[5];
    }

    pub fn get_h(self: @This()) u8 {
        return self.data[6];
    }

    pub fn get_l(self: @This()) u8 {
        return self.data[7];
    }

    pub fn get_bc(self: @This()) u16 {
        return self.get_u16(2);
    }

    pub fn set_bc(self: *@This(), value: u16) void {
        self.set_u16(2, value);
    }

    pub fn get_de(self: @This()) u16 {
        return self.get_u16(4);
    }

    pub fn set_de(self: *@This(), value: u16) void {
        self.set_u16(4, value);
    }

    pub fn get_hl(self: @This()) u16 {
        return self.get_u16(6);
    }

    pub fn set_hl(self: *@This(), value: u16) void {
        self.set_u16(6, value);
    }

    pub fn get_sp(self: @This()) u16 {
        return self.get_u16(8);
    }

    pub fn set_sp(self: *@This(), value: u16) void {
        self.set_u16(8, value);
    }

    pub fn get_pc(self: @This()) u16 {
        return self.get_u16(10);
    }

    pub fn set_pc(self: *@This(), value: u16) void {
        self.set_u16(10, value);
    }

    pub fn inc_pc(self: *@This()) void {
        self.set_u16(10, self.get_pc() + 1);
    }

    pub fn log(self: @This()) void {
        std.debug.print("a = {}\n", .{self.get_a()});
        std.debug.print("f = {}\n", .{self.get_f()});
        std.debug.print("b = {}\n", .{self.get_b()});
        std.debug.print("c = {}\n", .{self.get_c()});
        std.debug.print("bc = {}\n", .{self.get_bc()});
        std.debug.print("d = {}\n", .{self.get_d()});
        std.debug.print("e = {}\n", .{self.get_e()});
        std.debug.print("de = {}\n", .{self.get_de()});
        std.debug.print("h = {}\n", .{self.get_h()});
        std.debug.print("l = {}\n", .{self.get_l()});
        std.debug.print("hl = {}\n", .{self.get_hl()});
        std.debug.print("sp = {}\n", .{self.get_sp()});
        std.debug.print("pc = {}\n", .{self.get_pc()});
    }
};
