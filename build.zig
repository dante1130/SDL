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

    const sdl_lib = b.addStaticLibrary(.{
        .name = "SDL",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    build_sdl_with_cmake.step.dependOn(&configure_sdl_with_cmake.step);

    sdl_lib.step.dependOn(&build_sdl_with_cmake.step);
    sdl_lib.addIncludePath(.{ .cwd_relative = "lib/include" });
    sdl_lib.addLibraryPath(.{ .cwd_relative = "lib/lib" });
    sdl_lib.linkSystemLibrary("SDL3-static");
    sdl_lib.linkLibC();

    b.installArtifact(sdl_lib);
}
