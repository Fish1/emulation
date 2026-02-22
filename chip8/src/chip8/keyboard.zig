const std = @import("std");
const window = @import("window");

pub const KeyState = enum {
    just_pressed,
    pressed,
    just_released,
    released,
};

pub const Keyboard = struct {
    keys: [16]KeyState = @splat(.released),

    pub fn init() @This() {
        return .{};
    }

    pub fn get_released_key(self: *@This()) ?u8 {
        for (self.keys, 0..) |key, index| {
            if (key == .just_pressed) {
                return @intCast(index);
            }
        }
        return null;
    }

    pub fn clear_keys(self: *@This()) void {
        for (&self.keys) |*key| {
            key.* = switch (key.*) {
                .just_pressed => .pressed,
                .just_released => .released,
                else => key.*,
            };
        }
    }

    pub fn handle_event(self: *@This(), event: window.Event) void {
        switch (event) {
            .key_x_down => self.keys[0] = .just_pressed,
            .key_1_down => self.keys[1] = .just_pressed,
            .key_2_down => self.keys[2] = .just_pressed,
            .key_3_down => self.keys[3] = .just_pressed,
            .key_q_down => self.keys[4] = .just_pressed,
            .key_w_down => self.keys[5] = .just_pressed,
            .key_e_down => self.keys[6] = .just_pressed,
            .key_a_down => self.keys[7] = .just_pressed,
            .key_s_down => self.keys[8] = .just_pressed,
            .key_d_down => self.keys[9] = .just_pressed,
            .key_z_down => self.keys[10] = .just_pressed,
            .key_c_down => self.keys[11] = .just_pressed,
            .key_4_down => self.keys[12] = .just_pressed,
            .key_r_down => self.keys[13] = .just_pressed,
            .key_f_down => self.keys[14] = .just_pressed,
            .key_v_down => self.keys[15] = .just_pressed,

            .key_x_up => self.keys[0] = .just_released,
            .key_1_up => self.keys[1] = .just_released,
            .key_2_up => self.keys[2] = .just_released,
            .key_3_up => self.keys[3] = .just_released,
            .key_q_up => self.keys[4] = .just_released,
            .key_w_up => self.keys[5] = .just_released,
            .key_e_up => self.keys[6] = .just_released,
            .key_a_up => self.keys[7] = .just_released,
            .key_s_up => self.keys[8] = .just_released,
            .key_d_up => self.keys[9] = .just_released,
            .key_z_up => self.keys[10] = .just_released,
            .key_c_up => self.keys[11] = .just_released,
            .key_4_up => self.keys[12] = .just_released,
            .key_r_up => self.keys[13] = .just_released,
            .key_f_up => self.keys[14] = .just_released,
            .key_v_up => self.keys[15] = .just_released,
            else => {},
        }
    }
};
