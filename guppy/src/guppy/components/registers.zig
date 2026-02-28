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

    pub fn get_bc(self: *@This()) u16 {
        return self.get_u16(2);
    }

    pub fn set_bc(self: *@This(), value: u16) void {
        self.set_u16(2, value);
    }

    pub fn get_de(self: *@This()) u16 {
        return self.get_u16(4);
    }

    pub fn set_de(self: *@This(), value: u16) void {
        self.set_u16(4, value);
    }

    pub fn get_hl(self: *@This()) u16 {
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
};
