const std = @import("std");
const alloc = std.heap.c_allocator; // TODO-C: change to std.heap.GeneralPurposeAllocator
var r = std.rand.DefaultPrng.init(2);

const constants = @import("constants.zig");

const STRICT_EXECUTION_ORDERING: bool = constants.STRICT_EXECUTION_ORDERING;

const SPECTRARY: bool = constants.SPECTRARY;
const UMBRARY: bool = constants.UMBRARY;

const ROWS: u16 = constants.ROWS;
const COLS: u16 = constants.COLS;
const CELLS: [ROWS * COLS]void = constants.CELLS;

const main_c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("main.h");
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
const sacn_c = if (!constants.SACN_SERVER) undefined else @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("sacn-server-luminary.h");
    @cInclude("sacn-constants-luminary.h");
    if (constants.SACN_TEST_CLIENT) {
        @cInclude("sacn-test-client-luminary.h");
    }
});
var sacn_channels: sacn_c.sacn_channels_t = if (constants.SACN_SERVER) unreachable else undefined;
var sacn_test_client_color: u8 = if (constants.SACN_SERVER) 0 else undefined;
var sacn_test_client_pattern: u8 = if (constants.SACN_SERVER) 0 else undefined;
var sacn_test_client_transition: u8 = if (constants.SACN_SERVER) 0 else undefined;

pub fn main() !u8 {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var epoch_limit: u32 = 0;

    var spectrary_active: bool = undefined;
    // this should be a 3dft.dat file, as produced by snd2fftw
    var spectrary_file: []u8 = undefined;

    var umbrary_active: bool = undefined;
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

    var now: u8 = 0;
    var next: u8 = 1;
    var next_next: u8 = undefined;

    var scratch = [_]c_int{0} ** (ROWS * COLS);

    var control_directive_0_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;
    var control_directive_1_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;
    var control_orth_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;
    var control_diag_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;

    var rainbow_tone = [_]c_int{0} ** (ROWS * COLS);

    var rainbow_0_ = init: {
        var xss: [2][ROWS * COLS]c_int = undefined;
        for ([_]usize{ 0, 1 }) |w| {
            for (xss[w]) |*x| {
                x.* = constants.RAND_COLOR(r.random());
            }
        }
        break :init xss;
    };
    var impatience_0 = [_]c_int{0} ** (ROWS * COLS);
    var rainbow_1_ = init: {
        var xss: [2][ROWS * COLS]c_int = undefined;
        for ([_]usize{ 0, 1 }) |w| {
            for (xss[w]) |*x| {
                x.* = constants.RAND_COLOR(r.random());
            }
        }
        break :init xss;
    };
    var impatience_1 = [_]c_int{0} ** (ROWS * COLS);

    var pressure_self = [_]c_int{0} ** (ROWS * COLS);
    var pressure_orth_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;
    var pressure_diag_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;

    var excitement = [_]f64{0.0} ** (ROWS * COLS);

    //// needed to drive waves_(orth|diag)'s top row
    //// hand-tuned to radiate from a center 84 cells above the midpoint of the top side
    //int waves_base[] = WAVES_BASE_ARRAY;
    //int waves_base_z_orig = 16;

    var waves_orth_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;
    var waves_diag_ = [_][ROWS * COLS]c_int{[_]c_int{0} ** (ROWS * COLS)} ** 2;

    var turing_u = init: {
        var xs: [ROWS * COLS]main_c.turing_vector_t = undefined;
        for (xs) |*x| {
            const MAX_TURING_SCALES: u16 = 5;
            x.* = main_c.turing_vector_t{
                .state = r.random().float(f64) * 2 - 1.0,
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
        var xs: [ROWS * COLS]main_c.turing_vector_t = undefined;
        for (xs) |*x| {
            const MAX_TURING_SCALES: u16 = 5;
            x.* = main_c.turing_vector_t{
                .state = r.random().float(f64) * 2 - 1.0,
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

    if (constants.SACN_SERVER) {
        if (constants.SACN_TEST_CLIENT) {
            sacn_c.sacn_test_client_start();
        }

        sacn_c.sacn_server_start();

        if (constants.SACN_TEST_CLIENT) {
            sacn_c.sacn_test_client_set_level(constants.CHANNEL_M_MODE, 200);
            sacn_c.sacn_test_client_set_level(constants.CHANNEL_M_MODE, 200); // duped to sync seq no.
        }
    }

    // performance-monitoring variables
    var time_start: main_c.timeval_t = init: {
        var x: main_c.timeval_t = undefined;
        _ = main_c.gettimeofday(&x, null);
        break :init x;
    };
    var time_computed: main_c.timeval_t = undefined;
    var time_drawn: main_c.timeval_t = undefined;
    var time_refreshed: main_c.timeval_t = undefined;
    var time_handled: main_c.timeval_t = undefined;
    var time_slept: main_c.timeval_t = undefined;
    var time_stop: main_c.timeval_t = undefined;
    var time_fio_start: main_c.timeval_t = undefined;
    var time_fio_stop: main_c.timeval_t = undefined;
    var n_dirty_pixels: c_int = 0;
    var compute_avg: f64 = 0;
    var fio_avg: f64 = 0;
    var draw_avg: f64 = 0;
    var refresh_avg: f64 = 0;
    var wait_avg: f64 = 0;
    var sleep_avg: f64 = 0;
    var total_avg: f64 = 0;
    var n_dirty_pixels_avg: f64 = 0;

    main_c.c_init();
    defer main_c.c_exit();

    const N_PRIMARY_WORKERS = 4;

    // TODO include these in the turing_vector struct
    var turing_u_start = std.Thread.Semaphore{};
    var turing_u_finalize = std.Thread.Semaphore{};
    var turing_u_done = std.Thread.Semaphore{};
    var turing_v_start = std.Thread.Semaphore{};
    var turing_v_finalize = std.Thread.Semaphore{};
    var turing_v_done = std.Thread.Semaphore{};
    var turing_shutdown: bool = false;

    var turing_worker_u: std.Thread =
        try std.Thread.spawn(std.Thread.SpawnConfig{}, turing_computation_worker, .{
        &epoch,
        &turing_u,
        &turing_u_start,
        &turing_u_finalize,
        N_PRIMARY_WORKERS,
        &turing_u_done,
        &turing_shutdown,
    });
    var turing_worker_v: std.Thread = try std.Thread.spawn(std.Thread.SpawnConfig{}, turing_computation_worker, .{
        &epoch,
        &turing_v,
        &turing_v_start,
        &turing_v_finalize,
        N_PRIMARY_WORKERS,
        &turing_v_done,
        &turing_shutdown,
    });
    var primary_worker_start = [_]std.Thread.Semaphore{std.Thread.Semaphore{}} ** N_PRIMARY_WORKERS;
    var primary_worker_done = [_]std.Thread.Semaphore{std.Thread.Semaphore{}} ** N_PRIMARY_WORKERS;
    var primary_workers_shutdown: bool = false;

    var primary_workers = init: {
        var xs: [N_PRIMARY_WORKERS]std.Thread = undefined;
        for (xs) |*x, i| {
            x.* = try std.Thread.spawn(std.Thread.SpawnConfig{}, primary_computation_worker, .{
                @intCast(u16, i),
                N_PRIMARY_WORKERS,
                &now,
                &next,
                &epoch,
                &scratch,
                &control_directive_0_,
                &control_directive_1_,
                &control_orth_,
                &control_diag_,
                &rainbow_0_,
                &impatience_0,
                &rainbow_1_,
                &impatience_1,
                &pressure_self,
                &pressure_orth_,
                &pressure_diag_,
                &excitement,
                &waves_orth_,
                &waves_diag_,
                &turing_u,
                &turing_v,
                &primary_worker_start[i],
                &primary_worker_done[i],
                &turing_u_finalize,
                &turing_v_finalize,
                &primary_workers_shutdown,
            });
        }
        break :init xs;
    };

    if (!STRICT_EXECUTION_ORDERING) {
        for (primary_worker_start) |*start| {
            start.post();
        }

        turing_u_start.post();
        turing_v_start.post();
    }

    // main loop
    while (epoch <= epoch_limit or epoch_limit <= 0) : (epoch += 1) {
        _ = main_c.gettimeofday(&time_start, null);

        // begin computing evolution
        if (STRICT_EXECUTION_ORDERING) {
            for (primary_worker_start) |*start| {
                start.post();
            }
        }
        for (primary_worker_done) |*done| {
            done.wait();

            // turing_x_finalize semaphores already posted by primary workers replacing the below
            // turing_u_finalize.post();
            // turing_v_finalize.post();
        }

        main_c.c_compute_global_pattern_driver(
            epoch,
            scene,
            &control_directive_0_[now],
            &control_directive_0_[next],
            &control_directive_1_[now],
            &control_directive_1_[next],
            &control_orth_[now],
            &control_orth_[next],
            &waves_orth_[now],
            &waves_orth_[next],
            &waves_diag_[now],
            &waves_diag_[next],
        );

        _ = main_c.gettimeofday(&time_fio_start, null);

        if (SPECTRARY and spectrary_active) {
            main_c.spectrary_update();
        }

        if (UMBRARY and umbrary_active) {
            main_c.umbrary_update(epoch * 22_222);
        }

        for (CELLS) |_, xy| {
            if (constants.THROTTLE_LOOP and xy % constants.THROTTLE_LOOP_N == 0) {
                std.time.sleep(constants.THROTTLE_LOOP_NSEC);
            }

            main_c.c_apply_other_rules_cell(
                @intCast(c_int, xy),
                &control_directive_0_[now],
                &rainbow_tone,
                &rainbow_0_[now],
                &rainbow_0_[next],
                &pressure_self,
                &waves_orth_[next],
            );
        }

        if (STRICT_EXECUTION_ORDERING) {
            turing_u_start.post();
            turing_v_start.post();

            // finalize semaphores already posted by primary_workers, replacing the below
            // var i:u8 = 0;
            // while (i < N_PRIMARY_WORKERS) : (i += 1) {
            //     turing_u_finalize.post();
            //     turing_v_finalize.post();
            // }
        }

        turing_u_done.wait();
        turing_v_done.wait();

        _ = main_c.gettimeofday(&time_fio_stop, null);

        for (CELLS) |_, xy| {
            if (constants.THROTTLE_LOOP and xy % constants.THROTTLE_LOOP_N == 0) {
                std.time.sleep(constants.THROTTLE_LOOP_NSEC);
            }

            main_c.normalize_turing(
                @ptrCast([*c]main_c.turing_vector_t, &turing_u),
                @ptrCast([*c]main_c.turing_vector_t, &turing_v),
                @intCast(c_int, xy),
            );
        }

        if (!STRICT_EXECUTION_ORDERING) {
            turing_u_start.post();
            turing_v_start.post();
        }

        if (UMBRARY and umbrary_active) {
            for (CELLS) |_, xy| {
                if (constants.THROTTLE_LOOP and xy % constants.THROTTLE_LOOP_N == 0) {
                    std.time.sleep(constants.THROTTLE_LOOP_NSEC);
                }

                main_c.c_apply_umbrary_cell(
                    @intCast(c_int, xy),
                    @boolToInt(umbrary_active),
                    epoch,
                    &rainbow_0_[next],
                    @ptrCast([*c]main_c.turing_vector_t, &turing_u),
                    @ptrCast([*c]main_c.turing_vector_t, &turing_v),
                );
            }
        }
        // end computing evolution

        _ = main_c.gettimeofday(&time_computed, null);

        // begin draw/increment mutex
        main_c.c_draw_and_io(
            @boolToInt(spectrary_active),
            @boolToInt(umbrary_active),
            epoch,
            @ptrCast([*c]main_c.turing_vector_t, &turing_u),
            @ptrCast([*c]main_c.turing_vector_t, &turing_v),
        );

        // flip double-buffering indices
        next_next = now;
        now = next;
        next = next_next;
        next_next = undefined;
        // end draw/increment mutex

        _ = main_c.gettimeofday(&time_drawn, null);

        if (!STRICT_EXECUTION_ORDERING) {
            for (primary_worker_start) |*start| {
                start.post();
            }
        }

        if (constants.cairo.PRINT_VERBOSE) {
            std.debug.print("compute:{d:5.1}ms  ", .{(compute_avg - fio_avg) / 1_000.0});
            std.debug.print("file io:{d:5.1}ms  ", .{fio_avg / 1_000});
            std.debug.print("draw:{d:5.1}ms  ", .{draw_avg / 1_000});
            std.debug.print("refresh:{d:5.1}ms/{d}  ", .{ refresh_avg / 1_000, constants.DISPLAY_FLUSH_EPOCHS });
            std.debug.print("wait:{d:5.1}ms  ", .{wait_avg / 1_000});
            std.debug.print("sleep:{d:5.1}ms  ", .{sleep_avg / 1_000});
            std.debug.print("Hz:{d:5.1}/{d}(/{d})  ", .{ 1.0 / (total_avg / 1_000_000), constants.DISPLAY_FLUSH_EPOCHS, constants.WILDFIRE_SPEEDUP });
            if (!constants.cairo.VIDEO_FRAMES) {
                std.debug.print("\n", .{});
            }
        }

        main_c.c_display_flush(
            epoch,
            &time_refreshed,
            &n_dirty_pixels,
            &n_dirty_pixels_avg,
        );

        _ = main_c.gettimeofday(&time_refreshed, null);

        main_c.c_draw_ui_and_handle_input(
            @boolToInt(spectrary_active),
            @boolToInt(umbrary_active),
            epoch,
            scene,
            menu_context,
            &control_directive_0_[now],
            &control_directive_1_[now],
            &control_orth_[now],
            &rainbow_tone,
            &waves_orth_[now],
            in_chr,
            &time_start,
            &time_computed,
            &time_drawn,
            &time_refreshed,
            &time_handled,
            &time_slept,
            &time_stop,
            &time_fio_start,
            &time_fio_stop,
            &compute_avg,
            &fio_avg,
            &draw_avg,
            &refresh_avg,
            &wait_avg,
            &sleep_avg,
            &total_avg,
            &n_dirty_pixels_avg,
        );
    }

    primary_workers_shutdown = true;
    for (primary_worker_start) |*start| {
        start.post();
    }
    for (primary_workers) |*worker| {
        worker.join();
    }

    turing_shutdown = true;

    turing_u_finalize.post();
    turing_v_finalize.post();

    turing_u_start.post();
    turing_v_start.post();

    turing_worker_u.join();
    turing_worker_v.join();

    return 0;
}

// TODO move worker-thread logic out to separate files

fn primary_computation_worker(
    xy_start: u16,
    xy_increment: u16,
    now: *u8,
    next: *u8,
    epoch: *c_int,
    scratch: *[ROWS * COLS]c_int,
    control_directive_0_: *[2][ROWS * COLS]c_int,
    control_directive_1_: *[2][ROWS * COLS]c_int,
    control_orth_: *[2][ROWS * COLS]c_int,
    control_diag_: *[2][ROWS * COLS]c_int,
    rainbow_0_: *[2][ROWS * COLS]c_int,
    impatience_0: *[ROWS * COLS]c_int,
    rainbow_1_: *[2][ROWS * COLS]c_int,
    impatience_1: *[ROWS * COLS]c_int,
    pressure_self: *[ROWS * COLS]c_int,
    pressure_orth_: *[2][ROWS * COLS]c_int,
    pressure_diag_: *[2][ROWS * COLS]c_int,
    excitement: *[ROWS * COLS]f64,
    waves_orth_: *[2][ROWS * COLS]c_int,
    waves_diag_: *[2][ROWS * COLS]c_int,
    turing_u: *[ROWS * COLS]main_c.turing_vector_t,
    turing_v: *[ROWS * COLS]main_c.turing_vector_t,
    start: *std.Thread.Semaphore,
    done1: *std.Thread.Semaphore,
    done2: *std.Thread.Semaphore,
    done3: *std.Thread.Semaphore,
    shutdown: *bool,
) void {
    while (!shutdown.*) {
        start.*.wait();

        var xy = xy_start;
        while (xy < ROWS * COLS and true) : (xy += xy_increment) {
            if (constants.THROTTLE_LOOP and xy % constants.THROTTLE_LOOP_N == 0) {
                std.time.sleep(constants.THROTTLE_LOOP_NSEC);
            }

            var x = xy % COLS;
            var y = xy / COLS;

            if (!constants.PETALS_ACTIVE or y < constants.PETAL_ROWS or x < constants.FLOOR_COLS) {
                // thread-safe to run on cells in parallel (see notes in C definition)
                main_c.c_compute_cyclic_evolution_cell(
                    @intCast(c_int, xy),
                    epoch.*,
                    scratch,
                    &control_directive_0_[now.*], // read-only
                    &control_directive_0_[next.*], // only accesses [xy]
                    &control_directive_1_[now.*], // read-only
                    &control_directive_1_[next.*], // only accesses [xy]
                    &control_orth_[now.*], // read-only
                    &control_orth_[next.*], // only accesses [xy]
                    &control_diag_[now.*], // read-only
                    &control_diag_[next.*], // only accesses [xy]
                    &rainbow_0_[now.*], // read-only
                    &rainbow_0_[next.*], // only accesses [xy]
                    impatience_0, // only accesses [xy]
                    &rainbow_1_[now.*], // read-only
                    &rainbow_1_[next.*], // only accesses [xy]
                    impatience_1, // only accesses [xy]
                    pressure_self, // read-only
                    &pressure_orth_[now.*], // read-only
                    &pressure_orth_[next.*], // only accesses [xy]
                    &pressure_diag_[now.*], // read-only
                    &pressure_diag_[next.*], // only accesses [xy]
                    excitement, // only accesses [xy]
                    &waves_orth_[now.*], // read-only
                    &waves_orth_[next.*], // only accesses [xy]
                    &waves_diag_[now.*], // read-only
                    &waves_diag_[next.*], // only accesses [xy]
                    @ptrCast([*c]main_c.turing_vector_t, turing_u), // only accesses [xy]
                    @ptrCast([*c]main_c.turing_vector_t, turing_v), // only accesses [xy]
                );
            }
        }

        done1.*.post();
        done2.*.post();
        done3.*.post();
    }
}

const update_scales =
    if (STRICT_EXECUTION_ORDERING)
    [constants.MAX_TURING_SCALES][constants.MAX_TURING_SCALES]u8{[_]bool{true} ** constants.MAX_TURING_SCALES} ** constants.MAX_TURING_SCALES
else
    [constants.MAX_TURING_SCALES][constants.MAX_TURING_SCALES]bool{
        [_]bool{ true, true, false, false, false },
        [_]bool{ false, false, true, true, false },
        [_]bool{ true, false, false, false, true },
        [_]bool{ false, true, true, false, false },
        [_]bool{ false, false, false, true, true },
    }
    //[constants.MAX_TURING_SCALES]u8{0b10000,0b01000,0b00100,0b00010,0b00001,}
    ;

fn turing_computation_worker(
    epoch: *c_int,
    turing_v: *[ROWS * COLS]main_c.turing_vector_t,
    start: *std.Thread.Semaphore,
    finalize: *std.Thread.Semaphore,
    finalize_waits: u8,
    done: *std.Thread.Semaphore,
    shutdown: *bool,
) !void {
    var subworker_start = [_]std.Thread.Semaphore{std.Thread.Semaphore{}} ** constants.MAX_TURING_SCALES;
    var subworker_done = [_]std.Thread.Semaphore{std.Thread.Semaphore{}} ** constants.MAX_TURING_SCALES;
    var subworkers = init: {
        var xs: [constants.MAX_TURING_SCALES]std.Thread = undefined;
        for (subworker_start) |_, scale| {
            xs[scale] = try std.Thread.spawn(std.Thread.SpawnConfig{}, turing_computation_subworker, .{
                @intCast(u8, scale),
                turing_v,
                &subworker_start[scale],
                &subworker_done[scale],
                shutdown,
            });
        }
        break :init xs;
    };

    while (!shutdown.*) {
        start.*.wait();
        var epoch_tmp: usize = @intCast(usize, @mod(epoch.*, constants.MAX_TURING_SCALES));

        for (update_scales[epoch_tmp]) |update_scale, scale| {
            if (update_scale) {
                subworker_start[scale].post();
            }
        }

        for (update_scales[epoch_tmp]) |update_scale, scale| {
            if (update_scale) {
                subworker_done[scale].wait();
            }
        }

        var i: u8 = 0;
        while (i < finalize_waits) : (i += 1) {
            finalize.*.wait();
        }

        for (CELLS) |_, xy| {
            if (constants.THROTTLE_LOOP and xy % constants.THROTTLE_LOOP_N == 0) {
                std.time.sleep(constants.THROTTLE_LOOP_NSEC);
            }

            main_c.apply_turing(
                @ptrCast([*c]main_c.turing_vector_t, turing_v),
                @intCast(c_int, xy),
                @as(f64, 1.0),
                @intToFloat(f64, @mod(epoch.*, 1_000)) / (1_000.0),
            );
        }

        done.*.post();
    } else {
        for (subworker_start) |*sem| {
            sem.*.post();
        }
        for (subworkers) |*subworker| {
            subworker.join();
        }
    }
}

fn turing_computation_subworker(
    scale: u8,
    turing_v: *[ROWS * COLS]main_c.turing_vector_t,
    start: *std.Thread.Semaphore,
    done: *std.Thread.Semaphore,
    shutdown: *bool,
) void {
    while (!shutdown.*) {
        start.*.wait();

        main_c.compute_turing_scale(@ptrCast([*c]main_c.turing_vector_t, turing_v), scale);

        done.*.post();
    }
}
