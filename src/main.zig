const std = @import("std");

const spectrary: bool = false;
const umbrary:   bool = false;

const main_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("main.h");
});

pub fn main() u8 {
    return @intCast(u8,
        main_c.c_run(
            500,
            @boolToInt(false),
            null,
            @boolToInt(false),
            null
        )
    );
}
