const std = @import("std");
const main_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("main.h");
});

pub fn main() u8 {
    var c_argv: [2][*c]u8 = undefined;
    var s0: [*c]u8 = blk: {
        break :blk &struct {
            var string_temp: @TypeOf("zig build run".*) = "zig build run".*;
        }.string_temp;
    };
    var s1: [*c]u8 = blk: {
        break :blk &struct {
            var string_temp: @TypeOf("500".*) = "500".*;
        }.string_temp;
    };
    c_argv[0] = s0;
    c_argv[1] = s1;
    return @intCast(u8,
        main_c.c_main(
            @as(c_int, 2),
            @ptrCast([*c][*c]u8,
                @alignCast(std.meta.alignment([*c][*c]u8),
                    &c_argv
                )
            )
        )
    );
}
