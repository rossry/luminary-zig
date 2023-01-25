const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable("main", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());

    const source_files = [_][]const u8 {
        "src/cellular.c",
        "src/display.c",
        "src/main.c",
        "src/pattern.c"
    };
    
    for (source_files) |source| {
        exe.addCSourceFile(source, &[_][]const u8 {"-std=c99", "-I", "src", "-I", "lib/gifenc", "-I", "/usr/include/cairo"});
    }
    
    exe.addIncludePath("src");
    
    exe.linkLibC();
    exe.linkSystemLibrary("cairo");
    exe.linkSystemLibrary("ncurses");
    
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
