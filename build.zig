const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = b.host,
        .optimize = .ReleaseFast,
    });

    const source_files = [_][]const u8{
        "src/cellular.c",
        "src/display.c",
        "src/main.c",
        "src/pattern.c",
    };

    for (source_files) |source| {
        exe.addCSourceFile(.{
            .file = .{ .src_path = .{ .owner = b, .sub_path = source } },
            .flags = &[_][]const u8{ "-std=c99", "-I", "src", "-I", "lib/gifenc", "-I", "/usr/include/cairo" },
        });
    }

    exe.addIncludePath(.{ .src_path = .{ .owner = b, .sub_path = "src" } });

    exe.linkLibC();
    exe.linkSystemLibrary("cairo");
    exe.linkSystemLibrary("ncurses");

    b.installArtifact(exe);
}
