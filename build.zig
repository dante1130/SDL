const std = @import("std");

pub fn build(b: *std.Build) !void {
    const cwd = try std.fs.cwd().realpathAlloc(b.allocator, ".");

    const absolute_zig_cc_cmd_path = try std.fs.path.resolve(b.allocator, &[_][]const u8{
        cwd,
        "cmake/zig-cc.cmd",
    });

    const cmake_c_compiler_str = try std.fmt.allocPrint(b.allocator, "-DCMAKE_C_COMPILER={s}", .{absolute_zig_cc_cmd_path});

    const configure_sdl_with_cmake = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S",
        ".",
        "-B",
        "build",
        cmake_c_compiler_str,
        "-DCMAKE_GENERATOR=Ninja",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX=lib",
        "-DSDL_SHARED=OFF",
        "-DSDL_STATIC=ON",
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
