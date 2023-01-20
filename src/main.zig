const std = @import("std");
const alloc = std.heap.c_allocator; // TODO-C: change to std.heap.GeneralPurposeAllocator

const constants = @import("constants.zig");

const SPECTRARY: bool = constants.SPECTRARY;
const UMBRARY: bool = constants.UMBRARY;

const ROWS: u16 = constants.ROWS;
const COLS: u16 = constants.COLS;

const main_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("main.h");
});
const display_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("display.h");
});
const spectrary_c = if (!SPECTRARY) undefined else @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("spectrary.h");
});
const umbrary_c = if (!UMBRARY) undefined else @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("umbrary.h");
});

pub fn main() !u8 {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var epoch_limit: u32 = 0;

    var spectrary_active: bool = false;
    // this should be a 3dft.dat file, as produced by snd2fftw
    var spectrary_file: []u8 = undefined;

    var umbrary_active: bool = false;
    // this should be a printf pattern that points to a bmp when passed an int
    // frame 1 needs to exist, and umbrary will scan until it finds a gap
    var umbrary_bmp_format_string: []u8 = undefined;

    for (args) |arg, n| {
        switch (n) {
            0 => {},
            1 => {
                epoch_limit = try std.fmt.parseInt(u32, arg, 10);
            },
            else => {
                std.debug.print("usage: {s} -- [INT: epoch limit]\n", .{args[0]});
                return 2;
            },
        }
    }

    if (SPECTRARY) {
        if (SPECTRARY) {
            unreachable; // handle spectrary args
        }
        if (spectrary_active) {
            spectrary_c.spectrary_init(spectrary_file);
        }
    } else {
        spectrary_active = false;
    }

    if (UMBRARY) {
        if (UMBRARY) {
            unreachable; // handle umbrary args
        }
        if (umbrary_active) {
            umbrary_c.umbrary_init(umbrary_bmp_format_string);
        }
    } else {
        umbrary_active = false;
    }

    display_c.display_init();

    return @intCast(u8, main_c.c_run(
        @intCast(c_int, epoch_limit),
        @boolToInt(spectrary_active),
        @boolToInt(umbrary_active),
    ));
}
