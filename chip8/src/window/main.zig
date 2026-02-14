const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

var window: ?*sdl.SDL_Window = null;
var window_surface: [*c]sdl.SDL_Surface = undefined;

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
};

pub fn clear_screen() RenderError!void {
    var success = sdl.SDL_FillSurfaceRect(window_surface, null, sdl.SDL_MapSurfaceRGB(window_surface, 0xff, 0xff, 0xff));
    if (success == false) {
        return RenderError.failed_to_fill_surface_rect;
    }

    success = sdl.SDL_UpdateWindowSurface(window);
    if (success == false) {
        return RenderError.failed_to_update_window_surface;
    }
}
