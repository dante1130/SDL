const std = @import("std");

pub fn build(b: *std.Build) void {
    const configure_sdl_with_cmake = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S",
        ".",
        "-B",
        "build",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX=lib",
        "-DSDL_SHARED=ON",
        "-DSDL_STATIC=OFF",
        "-DSDL_TEST_LIBRARY=OFF",
        "-DSDL_TESTS=OFF",
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
}
