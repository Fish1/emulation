const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl_dep.artifact("SDL3");

    const app_mod = b.createModule(.{
        .root_source_file = b.path("src/chip8/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    app_mod.linkLibrary(sdl_lib);
    app_mod.linkSystemLibrary("SDL3", .{});
    // app_mod.link_libc = true;

    const app = b.addExecutable(.{
        .name = "chip8",
        .root_module = app_mod,
    });

    b.installArtifact(app);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(app);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const app_tests = b.addTest(.{
        .root_module = app.root_module,
    });

    const run_app_tests = b.addRunArtifact(app_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_app_tests.step);
}
