const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const configure_sdl_with_cmake = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S",
        ".",
        "-B",
        "build",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX=lib",
        "-DSDL_SHARED=OFF",
        "-DSDL_STATIC=ON",
        "-DSDL_TEST_LIBRARY=OFF",
        "-DSDL_TEST=OFF",
        "-DSDL_INSTALL_TESTS=OFF",
    });

    const build_sdl_with_cmake = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--build",
        "build",
        "--target",
        "install",
        "--config",
        "Release",
    });

    build_sdl_with_cmake.step.dependOn(&configure_sdl_with_cmake.step);
    b.getInstallStep().dependOn(&build_sdl_with_cmake.step);

    const sdl_lib = b.addModule("SDL.lib", .{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });

    sdl_lib.addLibraryPath(b.path("lib/lib"));
    sdl_lib.addIncludePath(b.path("lib/include"));
    sdl_lib.linkSystemLibrary("SDL3-static", .{ .preferred_link_mode = .static });
}
