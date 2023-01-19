const std = @import("std");
const alloc = std.heap.c_allocator; // TODO-C: change to std.heap.GeneralPurposeAllocator

const spectrary: bool = false;
const umbrary:   bool = false;

const main_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("main.h");
});

pub fn main() !u8 {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    
    var epoch_limit: u32 = 0;
    
    for (args) |arg, n| {
        switch (n) {
            0 => {},
            1 => {
                epoch_limit = try std.fmt.parseInt(u32, arg, 10);
            },
            else => {
                std.debug.print("usage: {s} -- [INT: epoch limit]\n", .{args[0]});
                return 2;
            }
        }
    }
    if (spectrary) {
        undefined; // handle spectrary args
    }
    if (umbrary) {
        undefined; // handle umbrary args
    }
    
    return @intCast(u8,
        main_c.c_run(
            @intCast(c_int, epoch_limit),
            @boolToInt(false),
            null,
            @boolToInt(false),
            null
        )
    );
}
