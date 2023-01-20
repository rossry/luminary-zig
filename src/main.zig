const std = @import("std");
const alloc = std.heap.c_allocator; // TODO-C: change to std.heap.GeneralPurposeAllocator
var r = std.rand.DefaultPrng.init(2);

const constants = @import("constants.zig");

const SPECTRARY: bool = constants.SPECTRARY;
const UMBRARY: bool = constants.UMBRARY;

const ROWS: u16 = constants.ROWS;
const COLS: u16 = constants.COLS;

const main_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("cellular.h");
    @cInclude("main.h");
});
const cellular_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("cellular.h");
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
    var epoch: c_int = 0;
    var scene: c_int = constants.SCENE_BASE;
    
    var menu_context: c_int = constants.MENU_ACTIONS;
    
    var scratch = [_]c_int{0} ** (ROWS * COLS);
    
    var control_directive_0 = [_]c_int{0} ** (ROWS * COLS);
    var control_directive_0_next = [_]c_int{0} ** (ROWS * COLS);
    var control_directive_1 = [_]c_int{0} ** (ROWS * COLS);
    var control_directive_1_next = [_]c_int{0} ** (ROWS * COLS);
    var control_orth = [_]c_int{0} ** (ROWS * COLS);
    var control_orth_next = [_]c_int{0} ** (ROWS * COLS);
    var control_diag = [_]c_int{0} ** (ROWS * COLS);
    var control_diag_next = [_]c_int{0} ** (ROWS * COLS);
    
    var rainbow_tone = [_]c_int{0} ** (ROWS * COLS);
    
    var rainbow_0 = init: {
        var xs: [ROWS*COLS]c_int = undefined;
        for (xs) |*x| {x.* = constants.RAND_COLOR(r.random());}
        break :init xs;
    };
    var rainbow_0_next = init: {
        var xs: [ROWS*COLS]c_int = undefined;
        for (xs) |*x| {x.* = constants.RAND_COLOR(r.random());}
        break :init xs;
    };
    var impatience_0 = [_]c_int{0} ** (ROWS * COLS);
    var rainbow_1 = init: {
        var xs: [ROWS*COLS]c_int = undefined;
        for (xs) |*x| {x.* = constants.RAND_COLOR(r.random());}
        break :init xs;
    };
    var rainbow_1_next = init: {
        var xs: [ROWS*COLS]c_int = undefined;
        for (xs) |*x| {x.* = constants.RAND_COLOR(r.random());}
        break :init xs;
    };
    var impatience_1 = [_]c_int{0} ** (ROWS * COLS);
    
    var pressure_self = [_]c_int{0} ** (ROWS * COLS);
    var pressure_orth = [_]c_int{0} ** (ROWS * COLS);
    var pressure_orth_next = [_]c_int{0} ** (ROWS * COLS);
    var pressure_diag = [_]c_int{0} ** (ROWS * COLS);
    var pressure_diag_next = [_]c_int{0} ** (ROWS * COLS);
    
    var excitement = [_]f64{0.0} ** (ROWS * COLS);
    
    
    //// needed to drive waves_(orth|diag)'s top row
    //// hand-tuned to radiate from a center 84 cells above the midpoint of the top side
    //int waves_base[] = WAVES_BASE_ARRAY;
    //int waves_base_z_orig = 16;
    
    var waves_orth = [_]c_int{0} ** (ROWS * COLS);
    var waves_orth_next = [_]c_int{0} ** (ROWS * COLS);
    var waves_diag = [_]c_int{0} ** (ROWS * COLS);
    var waves_diag_next = [_]c_int{0} ** (ROWS * COLS);
    
    var turing_u = init: {
        var xs: [ROWS*COLS]main_c.turing_vector_t = undefined;
        for (xs) |*x| {
            const MAX_TURING_SCALES: u16 = 5;
            x.* = main_c.turing_vector_t{
                .state = r.random().float(f64)*2 - 1.0,
                .n_scales = @intCast(c_int, 5),
                .scale = undefined,
                .increment = [MAX_TURING_SCALES]f64{
                    0.020,
                    0.028,
                    0.036,
                    0.044,
                    0.052,
                },
                
                .debug = @intCast(c_int, 0),
            };
        }
        break :init xs;
    };
    var turing_v = init: {
        var xs: [ROWS*COLS]main_c.turing_vector_t = undefined;
        for (xs) |*x| {
            const MAX_TURING_SCALES: u16 = 5;
            x.* = main_c.turing_vector_t{
                .state = 0.0, // TODO: rand_between(-0.5, 0.5) instead
                .n_scales = @intCast(c_int, 5),
                .scale = undefined,
                .increment = [MAX_TURING_SCALES]f64{
                    0.020,
                    0.028,
                    0.036,
                    0.044,
                    0.052,
                },
                
                .debug = @intCast(c_int, 0),
            };
        }
        break :init xs;
    };
    
    var in_chr: c_int = 0;

    return @intCast(u8, main_c.c_run(
        @intCast(c_int, epoch_limit),
        @boolToInt(spectrary_active),
        @boolToInt(umbrary_active),
        epoch,
        scene,
        menu_context,
        &scratch,
        &control_directive_0,
        &control_directive_0_next,
        &control_directive_1,
        &control_directive_1_next,
        &control_orth,
        &control_orth_next,
        &control_diag,
        &control_diag_next,
        &rainbow_tone,
        &rainbow_0,
        &rainbow_0_next,
        &impatience_0,
        &rainbow_1,
        &rainbow_1_next,
        &impatience_1,
        &pressure_self,
        &pressure_orth,
        &pressure_orth_next,
        &pressure_diag,
        &pressure_diag_next,
        &excitement,
        &waves_orth,
        &waves_orth_next,
        &waves_diag,
        &waves_diag_next,
        @ptrCast([*c]main_c.turing_vector_t, &turing_u),
        @ptrCast([*c]main_c.turing_vector_t, &turing_v),
        in_chr,
    ));
}
