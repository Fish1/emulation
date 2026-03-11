const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

var window: ?*sdl.SDL_Window = null;
var window_surface: [*c]sdl.SDL_Surface = undefined;
var draw_surface: [*c]sdl.SDL_Surface = undefined;

var now: u64 = 0;
var last: u64 = 0;
var delta: f64 = 0;

const WindowInitErrors = error{
    FAILED_TO_INITIALIZE_RENDERER,
    FAILED_TO_CREATE_WINDOW,
};

pub fn init() WindowInitErrors!void {
    const success = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    if (success == false) {
        const err = sdl.SDL_GetError();
        const zerr = std.mem.span(err);
        std.debug.print("{s}\n", .{zerr});
        return WindowInitErrors.FAILED_TO_INITIALIZE_RENDERER;
    }

    window = sdl.SDL_CreateWindow("My Window", 500, 500, 0);
    if (window == null) {
        return WindowInitErrors.FAILED_TO_CREATE_WINDOW;
    }

    window_surface = sdl.SDL_GetWindowSurface(window);
    draw_surface = sdl.SDL_CreateSurface(64, 32, sdl.SDL_PIXELFORMAT_RGBA32);
}

pub fn deinit() void {
    sdl.SDL_DestroySurface(window_surface);
    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
}

pub const Event = enum {
    unknown,
    quit,
    key_1_up,
    key_2_up,
    key_3_up,
    key_4_up,
    key_q_up,
    key_w_up,
    key_e_up,
    key_r_up,
    key_a_up,
    key_s_up,
    key_d_up,
    key_f_up,
    key_z_up,
    key_x_up,
    key_c_up,
    key_v_up,
    key_1_down,
    key_2_down,
    key_3_down,
    key_4_down,
    key_q_down,
    key_w_down,
    key_e_down,
    key_r_down,
    key_a_down,
    key_s_down,
    key_d_down,
    key_f_down,
    key_z_down,
    key_x_down,
    key_c_down,
    key_v_down,
};

pub fn poll() ?Event {
    var event: sdl.SDL_Event = undefined;
    const polled = sdl.SDL_PollEvent(&event);
    if (polled == false) {
        return null;
    }
    return switch (event.type) {
        sdl.SDL_EVENT_QUIT => .quit,
        sdl.SDL_EVENT_KEY_UP => switch (event.key.key) {
            sdl.SDLK_1 => .key_1_up,
            sdl.SDLK_2 => .key_2_up,
            sdl.SDLK_3 => .key_3_up,
            sdl.SDLK_4 => .key_4_up,
            sdl.SDLK_Q => .key_q_up,
            sdl.SDLK_W => .key_w_up,
            sdl.SDLK_E => .key_e_up,
            sdl.SDLK_R => .key_r_up,
            sdl.SDLK_A => .key_a_up,
            sdl.SDLK_S => .key_s_up,
            sdl.SDLK_D => .key_d_up,
            sdl.SDLK_F => .key_f_up,
            sdl.SDLK_Z => .key_z_up,
            sdl.SDLK_X => .key_x_up,
            sdl.SDLK_C => .key_c_up,
            sdl.SDLK_V => .key_v_up,
            else => .unknown,
        },
        sdl.SDL_EVENT_KEY_DOWN => switch (event.key.key) {
            sdl.SDLK_1 => .key_1_down,
            sdl.SDLK_2 => .key_2_down,
            sdl.SDLK_3 => .key_3_down,
            sdl.SDLK_4 => .key_4_down,
            sdl.SDLK_Q => .key_q_down,
            sdl.SDLK_W => .key_w_down,
            sdl.SDLK_E => .key_e_down,
            sdl.SDLK_R => .key_r_down,
            sdl.SDLK_A => .key_a_down,
            sdl.SDLK_S => .key_s_down,
            sdl.SDLK_D => .key_d_down,
            sdl.SDLK_F => .key_f_down,
            sdl.SDLK_Z => .key_z_down,
            sdl.SDLK_X => .key_x_down,
            sdl.SDLK_C => .key_c_down,
            sdl.SDLK_V => .key_v_down,
            else => .unknown,
        },
        else => .unknown,
    };
}

pub const RenderError = error{
    failed_to_fill_surface_rect,
    failed_to_update_window_surface,
    failed_to_read_surface_pixel,
    failed_to_write_surface_pixel,
    failed_to_stretch_surface,
};

pub fn clear_screen() RenderError!void {
    const success = sdl.SDL_FillSurfaceRect(draw_surface, null, sdl.SDL_MapSurfaceRGB(draw_surface, 0x00, 0x00, 0x00));
    if (success == false) {
        return RenderError.failed_to_fill_surface_rect;
    }
}

pub fn xor_pixel(x: u8, y: u8, incoming: u1) RenderError!u8 {
    const _x = x % 64;
    const _y = y % 32;
    var current_r: u8 = undefined;
    var current_g: u8 = undefined;
    var current_b: u8 = undefined;
    var current_a: u8 = undefined;
    var success = sdl.SDL_ReadSurfacePixel(draw_surface, _x, _y, &current_r, &current_g, &current_b, &current_a);
    if (success == false) {
        return RenderError.failed_to_read_surface_pixel;
    }

    const current: u1 = @intFromBool(@as(u32, @intCast(current_r)) + @as(u32, @intCast(current_g)) + @as(u32, @intCast(current_b)) > 0);

    var new_r: u8 = undefined;
    var new_g: u8 = undefined;
    var new_b: u8 = undefined;
    if (current == incoming) {
        new_r = 0;
        new_g = 0;
        new_b = 0;
    } else {
        new_r = 255;
        new_g = 255;
        new_b = 255;
    }

    success = sdl.SDL_WriteSurfacePixel(draw_surface, _x, _y, new_r, new_g, new_b, 255);
    if (success == false) {
        return RenderError.failed_to_write_surface_pixel;
    }

    if (current == 1 and incoming == 1) {
        return 1;
    } else {
        return 0;
    }
}

pub fn tick() !void {
    last = now;
    now = sdl.SDL_GetPerformanceCounter();
    delta = @as(f64, @floatFromInt((now - last) * 10000)) / @as(f64, @floatFromInt(sdl.SDL_GetPerformanceCounter()));
    const success = sdl.SDL_UpdateWindowSurface(window);
    if (success == false) {
        return RenderError.failed_to_update_window_surface;
    }
}

pub fn show_display() RenderError!void {
    const success = sdl.SDL_UpdateWindowSurface(window);
    if (success == false) {
        return RenderError.failed_to_update_window_surface;
    }
}

pub fn flip_buffer() RenderError!void {
    const src_rect = sdl.SDL_Rect{
        .x = 0,
        .y = 0,
        .w = 64,
        .h = 32,
    };
    const dst_rect = sdl.SDL_Rect{
        .x = 0,
        .y = 0,
        .w = 500,
        .h = 500,
    };

    const success = sdl.SDL_StretchSurface(draw_surface, &src_rect, window_surface, &dst_rect, sdl.SDL_SCALEMODE_NEAREST);
    if (success == false) {
        return RenderError.failed_to_stretch_surface;
    }
}

pub fn get_delta() f64 {
    return delta;
}

pub fn delay(milliseconds: u32) void {
    sdl.SDL_Delay(milliseconds);
}
