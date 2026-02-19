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
};

pub fn poll() ?Event {
    var event: sdl.SDL_Event = undefined;
    const polled = sdl.SDL_PollEvent(&event);
    if (polled == false) {
        return null;
    }
    return switch (event.type) {
        sdl.SDL_EVENT_QUIT => .quit,
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
    var success = sdl.SDL_FillSurfaceRect(window_surface, null, sdl.SDL_MapSurfaceRGB(window_surface, 0x00, 0x00, 0x00));
    if (success == false) {
        return RenderError.failed_to_fill_surface_rect;
    }

    success = sdl.SDL_UpdateWindowSurface(window);
    if (success == false) {
        return RenderError.failed_to_update_window_surface;
    }
}

pub fn xor_pixel(x: u8, y: u8, set: bool) RenderError!void {
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

    const current: u32 = @as(u32, @intCast(current_r)) + @as(u32, @intCast(current_g)) + @as(u32, @intCast(current_b));
    const current_set = current > 0;

    var new_r: u8 = undefined;
    var new_g: u8 = undefined;
    var new_b: u8 = undefined;
    if (current_set == set) {
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
}

pub fn render() RenderError!void {
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

    var success = sdl.SDL_StretchSurface(draw_surface, &src_rect, window_surface, &dst_rect, sdl.SDL_SCALEMODE_NEAREST);
    if (success == false) {
        return RenderError.failed_to_stretch_surface;
    }

    success = sdl.SDL_UpdateWindowSurface(window);
    if (success == false) {
        return RenderError.failed_to_update_window_surface;
    }

    last = now;
    now = sdl.SDL_GetPerformanceCounter();
    delta = @as(f64, @floatFromInt((now - last) * 10000)) / @as(f64, @floatFromInt(sdl.SDL_GetPerformanceCounter()));
}

pub fn get_delta() f64 {
    return delta;
}

pub fn delay(milliseconds: u32) void {
    sdl.SDL_Delay(milliseconds);
}
