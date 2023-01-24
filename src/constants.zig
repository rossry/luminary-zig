pub const STRICT_EXECUTION_ORDERING: bool = false;

// if you change these, make corresponding changes to cellular.h

pub const MAX_TURING_SCALES: u16 = 5;

// if you change these, make corresponding changes to constants.h

const std = @import("std");

// pub fn RAND_DOUBLE() callconv(.Inline) u16 {return (double)rand() / (double)(RAND_MAX);}

// input, output, control
pub const SACN_SERVER: bool = false;
pub const SACN_TEST_CLIENT: bool = SACN_SERVER and false; // use some keyboard actions to send test-client messages to the server

pub const SACN_CLIENT: bool = false;

pub const PP_SERVER: bool = false;

pub const SPECTRARY: bool = false;

pub const UMBRARY: bool = false;

// physical dimensions
pub const PETALS_ACTIVE: bool = false;

//TODO: to be continued...
pub const FLOOR_COLS: u16 = 96;
pub const FLOOR_ROWS: u16 = 96;

pub const FLOOR_COLS_SHOWN: u16 = FLOOR_COLS;
pub const FLOOR_ROWS_SHOWN: u16 = FLOOR_ROWS;

pub const PETAL_COLS: u16 = if (PETALS_ACTIVE) 18 else 32; // per petal
pub const PETAL_ROWS: u16 = if (PETALS_ACTIVE) 32 else 0;
pub const PETAL_ROWS_CONNECTED: u16 = if (PETALS_ACTIVE) 7 else 0;
pub const PETAL_ROWS_SEPARATED: u16 = (PETAL_ROWS - PETAL_ROWS_CONNECTED);

pub const COLS: u16 = if (PETALS_ACTIVE) 5 * PETAL_COLS else FLOOR_COLS;
pub const ROWS: u16 = (FLOOR_ROWS + PETAL_ROWS);
pub const CELLS: [ROWS * COLS]void = undefined;

pub inline fn PETAL_OF(xy: u16) u16 {
    if (PETALS_ACTIVE) {
        return ((xy) % COLS) / PETAL_COLS;
    } else {
        return 0;
    }
}

pub const DIAGNOSTIC_SAMPLING_RATE: u16 = 1;
pub const DISPLAY_PETALS_MODE: bool = PETALS_ACTIVE and true;
pub const DISPLAY_FLOOR_ALSO: bool = PETALS_ACTIVE and false;

pub const DIAGNOSTIC_ROWS =
    if (DISPLAY_PETALS_MODE)
    (if (DISPLAY_FLOOR_ALSO)
        ((PETAL_ROWS + FLOOR_ROWS_SHOWN / 2) / DIAGNOSTIC_SAMPLING_RATE + 5)
    else
        ((PETAL_ROWS / DIAGNOSTIC_SAMPLING_RATE) * 2 + 3))
else
    (((FLOOR_ROWS_SHOWN - 1) / DIAGNOSTIC_SAMPLING_RATE) + 1);

pub const DIAGNOSTIC_COLS: u16 = 72;

pub const colors = struct {
    // colors (for ncurses)
    pub const RAINBOW_00: u16 = 61;
    pub const RAINBOW_01: u16 = 133;
    pub const RAINBOW_02: u16 = 204;
    pub const RAINBOW_03: u16 = 203;
    pub const RAINBOW_04: u16 = 209;
    pub const RAINBOW_05: u16 = 179;
    pub const RAINBOW_06: u16 = 155;
    pub const RAINBOW_07: u16 = 83;
    pub const RAINBOW_08: u16 = 42;
    pub const RAINBOW_09: u16 = 43;
    pub const RAINBOW_10: u16 = 32;
    pub const RAINBOW_11: u16 = 62;
    pub const RAINBOW_40: u16 = 54;
    pub const RAINBOW_41: u16 = 53;
    pub const RAINBOW_42: u16 = 89;
    pub const RAINBOW_43: u16 = 95;
    pub const RAINBOW_44: u16 = 94;
    pub const RAINBOW_45: u16 = 58;
    pub const RAINBOW_46: u16 = 64;
    pub const RAINBOW_47: u16 = 28;
    pub const RAINBOW_48: u16 = 29;
    pub const RAINBOW_49: u16 = 23;
    pub const RAINBOW_50: u16 = 59;
    pub const RAINBOW_51: u16 = 60;
    pub const GREY_0: u16 = 242;
    pub const GREY_1: u16 = 243;
    pub const GREY_2: u16 = 244;
    pub const GREY_3: u16 = 245;
    pub const GREY_4: u16 = 246;
    pub const GREY_5: u16 = 247;
    pub const GREY_6: u16 = 248;
    pub const GREY_40: u16 = 232;
    pub const GREY_41: u16 = 235;
    pub const GREY_42: u16 = 248;
    pub const GREY_43: u16 = 241;
    pub const GREY_44: u16 = 244;
    pub const GREY_45: u16 = 247;
    pub const GREY_46: u16 = 250;
};

// speeds, times, distances
pub const BASE_HZ: u16 = 14;
pub const WILDFIRE_SPEEDUP: u16 = 3; // wildfire effects propagate at this multiple of BASE_HZ
pub const DISPLAY_FLUSH_EPOCHS: u16 = 1; // flush display every # epochs

pub const THROTTLE_LOOP: bool = false;
pub const THROTTLE_LOOP_N: u16 = if (THROTTLE_LOOP) 100 else undefined;
pub const THROTTLE_LOOP_USEC: u16 = if (THROTTLE_LOOP) 350 else undefined;
pub const THROTTLE_LOOP_NSEC: u24 = if (THROTTLE_LOOP) THROTTLE_LOOP_USEC * 1_000 else undefined;

pub const TRANSITION_TICKS: u16 = 400;
pub const SECONDARY_TRANSITION_TICKS: u16 = 300;
//pub fn RAND_SECONDARY_TRANSITION() callconv(.Inline) u16 { return rand() % (ROWS * COLS) == 0; }
pub const HIBERNATION_TICKS: u16 = 70_000; // 70000 ticks ~ 103 seconds
pub const INITIALIZATION_EPOCHS: u16 = 1 * WILDFIRE_SPEEDUP; // run this many epochs on startup
pub const PRESSURE_DELAY_EPOCHS: u16 = 30;
pub const PRESSURE_RADIUS_TICKS: u16 = 150;
pub const RAINBOW_TONE_EPOCHS: u16 = 1_200;

// evolution parameters
pub const DECAY_SQUARE: bool = false; // make decay/waves effects square rather than round
pub const TURING_DIFFUSION_PASSES: u16 = 3;
pub const RA2T_I: u16 = 0.765; // 0.35

// ncurses output
pub const OUTPUT_NCURSES: bool = false;

// gif output
pub const OUTPUT_GIF: bool = false;
pub const gif = if (OUTPUT_GIF) struct {
    pub const BLUR: bool = true;
    pub const BLUR_WIDTH: u16 = 4;
    pub const ZOOM: u16 = 15;
    pub const EPOCHS: u16 = 3_100;
} else undefined;

// cairo output
pub const OUTPUT_CAIRO: bool = true;
pub const cairo = if (OUTPUT_CAIRO) struct {
    pub const FULLSCREEN: bool = false;
    pub const VIDEO_FRAMES: bool = true;
    pub const PRINT_VERBOSE: bool = !OUTPUT_NCURSES and true;
    pub const SNAPSHOT_EPOCH: u16 = 1_323;

    pub const BLUR: bool = true;
    pub const PAINT_ALPHA: u16 = 0.1;

    pub const CELL_LABELS: bool = false;
    pub const ZOOM: u16 = if (CELL_LABELS) 15 else 7;

    pub const BLUR_WIDTH =
        if (CELL_LABELS) 0 else switch (ZOOM) {
        15 => 4,
        7 => 2,
        5 => 1,
        3 => 1,
        else => 0,
    };
} else undefined;

// other constants (probably don't mess with these)
pub const COLORS: u16 = 12;
pub inline fn RAND_COLOR(r: std.rand.Random) u16 {
    return r.int(u16) % COLORS;
}
pub const MAKE_GREY: u16 = 20;
pub const MAKE_DARKER: u16 = 40;
pub const EXTRA_COLOR: u16 = 80;
pub const EXTRA_COLORS: u16 = 36;
pub const BLACK: u16 = 15;

pub const DECAYABLE_INCREMENT: u16 = 17;

// array is 97 elements long
pub const WAVES_BASE_ARRAY: [97]i16 = [97]i16{ -331, -319, -307, -295, -283, -271, -260, -249, -237, -226, -215, -205, -194, -184, -173, -163, -154, -144, -135, -125, -116, -108, -99, -91, -83, -75, -68, -61, -54, -47, -41, -35, -29, -24, -18, -14, -9, -5, -1, 2, 4, 6, 6, 7, 8, 8, 9, 9, 9, 9, 9, 8, 8, 7, 6, 6, 4, 2, -1, -5, -9, -14, -18, -24, -29, -35, -41, -47, -54, -61, -68, -75, -83, -91, -99, -108, -116, -125, -135, -144, -154, -163, -173, -184, -194, -205, -215, -226, -237, -249, -260, -271, -283, -295, -307, -319, -331 };
pub const WAVES_BASE_X_ORIG: u16 = 48 - FLOOR_COLS / 2;
pub const WAVES_INCREMENT: u16 = DECAYABLE_INCREMENT;

pub const petal_mapping = if (true) undefined else struct {
    pub const PETAL_PIXEL_PATTERN: u16 = 3;
    // // here's the untranslated C macros for petal patterns, for reference; not implemented for now
    // #if PETAL_PIXEL_PATTERN == 1
    //     #define PETAL_MAPPING { \
    //              	         	         	         	         	         	         	 7, 8, 1,	         	 9, 8, 1,	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	 6, 10, 1,	         	         	         	10, 10, 1,	         	         	         	         	         	         	\
    //              	         	         	         	 4, 11, 1,	         	         	         	 8, 11, 1,	         	         	         	12, 11, 1,	         	         	         	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	         	         	         	 4, 13, 1,	         	         	         	 8, 13, 1,	         	         	         	12, 13, 1,	         	         	         	         	\
    //              	         	         	         	         	         	 6, 14, 1,	         	         	         	10, 14, 1,	         	         	         	         	         	         	\
    //              	         	         	 3, 15, 1,	         	         	         	         	         	         	         	         	         	13, 15, 1,	         	         	         	\
    //              	         	         	         	         	         	 6, 16, 1,	         	         	         	10, 16, 1,	         	         	         	         	         	         	\
    //              	         	         	         	 4, 17, 1,	         	         	         	 8, 17, 1,	         	         	         	12, 17, 1,	         	         	         	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	         	         	         	 4, 19, 1,	         	         	         	 8, 19, 1,	         	         	         	12, 19, 1,	         	         	         	         	\
    //              	         	         	         	         	         	 6, 20, 1,	         	         	         	10, 20, 1,	         	         	         	         	         	         	\
    //     }
    //     #define PETAL_MAPPING_PIXELS 24
    // #elif PETAL_PIXEL_PATTERN == 3
    //     #define PETAL_MAPPING { \
    //              	         	         	         	         	         	         	 7, 0, 1,	         	 9, 0, 1,	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	         	         	         	         	 5, 2, 1,	         	 7, 2, 1,	         	 9, 2, 1,	         	11, 2, 1,	         	         	         	         	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	         	         	         	 4, 4, 1,	         	 6, 4, 1,	         	         	         	10, 4, 1,	         	12, 4, 1,	         	         	         	         	\
    //              	         	 2, 5, 1,	         	         	         	         	         	 8, 5, 1,	         	         	         	         	         	14, 5, 1,	         	         	\
    //              	         	         	         	         	 5, 6, 1,	         	         	         	         	         	11, 6, 1,	         	         	         	         	         	\
    //              	 1, 7, 1,	         	 3, 7, 1,	         	         	         	 7, 7, 1,	         	 9, 7, 1,	         	         	         	13, 7, 1,	         	15, 7, 1,	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	 1, 9, 1,	         	 3, 9, 1,	         	         	         	 7, 9, 1,	         	 9, 9, 1,	         	         	         	13, 9, 1,	         	15, 9, 1,	         	\
    //              	         	         	         	         	 5,10, 1,	         	         	         	         	         	11,10, 1,	         	         	         	         	         	\
    //      0,11, 1,	         	 2,11, 1,	         	         	         	         	         	 8,11, 1,	         	         	         	         	         	14,11, 1,	         	16,11, 1,	\
    //              	         	         	         	 4,12, 1,	         	 6,12, 1,	         	         	         	10,12, 1,	         	12,12, 1,	         	         	         	         	\
    //              	 1,13, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	15,13, 1,	         	\
    //              	         	         	         	 4,14, 1,	         	 6,14, 1,	         	         	         	10,14, 1,	         	12,14, 1,	         	         	         	         	\
    //      0,15, 1,	         	 2,15, 1,	         	         	         	         	         	 8,15, 1,	         	         	         	         	         	14,15, 1,	         	16,15, 1,	\
    //              	         	         	         	         	 5,16, 1,	         	         	         	         	         	11,16, 1,	         	         	         	         	         	\
    //              	 1,17, 1,	         	 3,17, 1,	         	         	         	 7,17, 1,	         	 9,17, 1,	         	         	         	13,17, 1,	         	15,17, 1,	         	\
    //              	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	\
    //              	 1,19, 1,	         	 3,19, 1,	         	         	         	 7,19, 1,	         	 9,19, 1,	         	         	         	13,19, 1,	         	15,19, 1,	         	\
    //              	         	         	         	         	 5,20, 1,	         	         	         	         	         	11,20, 1,	         	         	         	         	         	\
    //              	         	 2,21, 1,	         	         	         	         	         	 8,21, 1,	         	         	         	         	         	14,21, 1,	         	         	\
    //              	         	         	         	 4,22, 1,	         	 6,22, 1,	         	         	         	10,22, 1,	         	12,22, 1,	         	         	         	         	\
    //     }
    //     #define PETAL_MAPPING_PIXELS 72
    // #elif PETAL_PIXEL_PATTERN == 10
    //     #define PETAL_MAPPING { \
    //              	         	         	         	         	         	         	 7, 0, 1,	 8, 0, 1,	 9, 0, 1,	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	 6, 1, 1,	         	         	         	10, 1, 1,	         	         	         	         	         	         	\
    //              	         	         	         	         	 5, 2, 1,	         	         	         	         	         	11, 2, 1,	         	         	         	         	         	\
    //              	         	         	         	 4, 3, 1,	         	         	         	         	         	         	         	12, 3, 1,	         	         	         	         	\
    //              	         	         	 3, 4, 1,	         	         	         	         	         	         	         	         	         	13, 4, 1,	         	         	         	\
    //              	         	 2, 5, 1,	         	         	         	         	         	 8, 5, 1,	         	         	         	         	         	14, 5, 1,	         	         	\
    //              	         	 2, 6, 1,	         	         	         	         	 7, 6, 1,	         	 9, 6, 1,	         	         	         	         	14, 6, 1,	         	         	\
    //              	 1, 7, 1,	         	         	         	         	 6, 7, 1,	         	         	         	10, 7, 1,	         	         	         	         	15, 7, 1,	         	\
    //              	 1, 8, 1,	         	         	         	 5, 8, 1,	         	         	         	         	         	11, 8, 1,	         	         	         	15, 8, 1,	         	\
    //              	 1, 9, 1,	         	         	         	 5, 9, 1,	         	         	         	         	         	11, 9, 1,	         	         	         	15, 9, 1,	         	\
    //      0, 10, 1,	         	         	         	 4, 10, 1,	         	         	         	         	         	         	         	12, 10, 1,	         	         	         	16, 10, 1,	\
    //      0, 11, 1,	         	         	         	 4, 11, 1,	         	         	         	         	         	         	         	12, 11, 1,	         	         	         	16, 11, 1,	\
    //      0, 12, 1,	         	         	         	 4, 12, 1,	         	         	         	         	         	         	         	12, 12, 1,	         	         	         	16, 12, 1,	\
    //      0, 13, 1,	         	         	         	 4, 13, 1,	         	         	         	         	         	         	         	12, 13, 1,	         	         	         	16, 13, 1,	\
    //      0, 14, 1,	         	         	         	 4, 14, 1,	         	         	         	         	         	         	         	12, 14, 1,	         	         	         	16, 14, 1,	\
    //      0, 15, 1,	         	         	         	 4, 15, 1,	         	         	         	         	         	         	         	12, 15, 1,	         	         	         	16, 15, 1,	\
    //              	 1, 16, 1,	         	         	 4, 16, 1,	         	         	         	         	         	         	         	12, 16, 1,	         	         	15, 16, 1,	         	\
    //              	 1, 17, 1,	         	         	         	 5, 17, 1,	         	         	         	         	         	11, 17, 1,	         	         	         	15, 17, 1,	         	\
    //              	 1, 18, 1,	         	         	         	 5, 18, 1,	         	         	         	         	         	11, 18, 1,	         	         	         	15, 18, 1,	         	\
    //              	         	 2, 19, 1,	         	         	         	 6, 19, 1,	         	         	         	10, 19, 1,	         	         	         	14, 19, 1,	         	         	\
    //              	         	 2, 20, 1,	         	         	         	         	 7, 20, 1,	         	 9, 20, 1,	         	         	         	         	14, 20, 1,	         	         	\
    //              	         	         	 3, 21, 1,	         	         	         	         	 8, 21, 1,	         	         	         	         	13, 21, 1,	         	         	         	\
    //              	         	         	         	 4, 22, 1,	         	         	         	         	         	         	         	12, 22, 1,	         	         	         	         	\
    //     }
    //     #define PETAL_MAPPING_PIXELS 79
    // #elif PETAL_PIXEL_PATTERN == 11
    //     #define PETAL_MAPPING { \
    //              	         	         	         	         	         	         	 7, 0, 1,	 8, 0, 1,	 9, 0, 1,	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	 6, 1, 1,	         	         	         	10, 1, 1,	         	         	         	         	         	         	\
    //              	         	         	         	         	 5, 2, 1,	         	         	         	         	         	11, 2, 1,	         	         	         	         	         	\
    //              	         	         	         	 4, 3, 1,	 5, 3, 1,	         	         	         	         	         	11, 3, 1,	12, 3, 1,	         	         	         	         	\
    //              	         	         	 3, 4, 1,	         	 5, 4, 1,	         	         	         	         	         	11, 4, 1,	         	13, 4, 1,	         	         	         	\
    //              	         	 2, 5, 1,	         	         	         	 6, 5, 1,	         	         	         	10, 5, 1,	         	         	         	14, 5, 1,	         	         	\
    //              	         	 2, 6, 1,	         	         	         	 6, 6, 1,	         	         	         	10, 6, 1,	         	         	         	14, 6, 1,	         	         	\
    //              	 1, 7, 1,	         	         	         	         	 6, 7, 1,	         	         	         	10, 7, 1,	         	         	         	         	15, 7, 1,	         	\
    //              	 1, 8, 1,	         	         	         	         	         	 7, 8, 1,	         	 9, 8, 1,	         	         	         	         	         	15, 8, 1,	         	\
    //              	 1, 9, 1,	         	         	         	         	         	 7, 9, 1,	         	 9, 9, 1,	         	         	         	         	         	15, 9, 1,	         	\
    //      0, 10, 1,	         	         	         	         	         	         	 7, 10, 1,	         	 9, 10, 1,	         	         	         	         	         	         	16, 10, 1,	\
    //      0, 11, 1,	         	         	         	         	         	         	         	 8, 11, 1,	         	         	         	         	         	         	         	16, 11, 1,	\
    //      0, 12, 1,	         	         	         	         	         	         	         	 8, 12, 1,	         	         	         	         	         	         	         	16, 12, 1,	\
    //      0, 13, 1,	         	         	         	         	         	         	         	 8, 13, 1,	         	         	         	         	         	         	         	16, 13, 1,	\
    //      0, 14, 1,	         	         	         	         	         	         	 7, 14, 1,	         	 9, 14, 1,	         	         	         	         	         	         	16, 14, 1,	\
    //      0, 15, 1,	         	         	         	         	         	         	 7, 15, 1,	         	 9, 15, 1,	         	         	         	         	         	         	16, 15, 1,	\
    //              	 1, 16, 1,	         	         	         	         	         	 7, 16, 1,	         	 9, 16, 1,	         	         	         	         	         	15, 16, 1,	         	\
    //              	 1, 17, 1,	         	         	         	         	 6, 17, 1,	         	         	         	10, 17, 1,	         	         	         	         	15, 17, 1,	         	\
    //              	 1, 18, 1,	         	         	         	         	 6, 18, 1,	         	         	         	10, 18, 1,	         	         	         	         	15, 18, 1,	         	\
    //              	         	 2, 19, 1,	         	         	         	 6, 19, 1,	         	         	         	10, 19, 1,	         	         	         	14, 19, 1,	         	         	\
    //              	         	 2, 20, 1,	         	         	 5, 20, 1,	         	         	         	         	         	11, 20, 1,	         	         	14, 20, 1,	         	         	\
    //              	         	         	 3, 21, 1,	         	 5, 21, 1,	         	         	         	         	         	11, 21, 1,	         	13, 21, 1,	         	         	         	\
    //              	         	         	         	 4, 22, 1,	         	         	         	         	         	         	         	12, 22, 1,	         	         	         	         	\
    //     }
    //     #define PETAL_MAPPING_PIXELS 82
    // #elif PETAL_PIXEL_PATTERN == 21
    //     #define PETAL_MAPPING { \
    //              	         	         	         	         	         	         	         	         	         	         	13, 0, 1,	14, 0, 1,	15, 0, 1,	16, 0, 1,	17, 0, 1,	         	         	         	         	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	         	         	10, 1, 1,	11, 1, 1,	12, 1, 1,	         	         	         	         	         	18, 1, 1,	19, 1, 1,	20, 1, 1,	         	         	         	         	         	         	         	         	\
    //              	         	         	         	         	         	 8, 2, 1,	 9, 2, 1,	         	         	         	         	         	         	         	         	         	         	         	21, 2, 1,	22, 2, 1,	         	         	         	         	         	         	\
    //              	         	         	         	         	 7, 3, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	23, 3, 1,	         	         	         	         	         	\
    //              	         	         	         	 6, 4, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	24, 4, 1,	         	         	         	         	\
    //              	         	         	 5, 5, 1,	         	 7, 5, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	23, 5, 1,	         	25, 5, 1,	         	         	         	\
    //              	         	 4, 6, 1,	         	         	         	 8, 6, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	22, 6, 1,	         	         	         	26, 6, 1,	         	         	\
    //              	         	 4, 7, 1,	         	         	         	         	 9, 7, 1,	         	         	         	         	         	         	         	         	         	         	         	21, 7, 1,	         	         	         	         	26, 7, 1,	         	         	\
    //              	 3, 8, 1,	         	         	         	         	         	         	10, 8, 1,	         	         	         	         	         	         	         	         	         	20, 8, 1,	         	         	         	         	         	         	27, 8, 1,	         	\
    //              	 3, 9, 1,	         	         	         	         	         	         	         	11, 9, 1,	         	         	         	         	         	         	         	19, 9, 1,	         	         	         	         	         	         	         	27, 9, 1,	         	\
    //              	 3, 10, 1,	         	         	         	         	         	         	         	         	12, 10, 1,	         	         	         	         	         	18, 10, 1,	         	         	         	         	         	         	         	         	27, 10, 1,	         	\
    //      2, 11, 1,	         	         	         	         	         	         	         	         	         	         	13, 11, 1,	         	         	         	17, 11, 1,	         	         	         	         	         	         	         	         	         	         	28, 11, 1,	\
    //      2, 12, 1,	         	         	         	         	         	         	         	         	         	         	         	14, 12, 1,	         	16, 12, 1,	         	         	         	         	         	         	         	         	         	         	         	28, 12, 1,	\
    //      2, 13, 1,	         	         	         	         	         	         	         	         	         	         	         	         	15, 13, 1,	         	         	         	         	         	         	         	         	         	         	         	         	28, 13, 1,	\
    //      2, 14, 1,	         	         	         	         	         	         	         	         	         	         	         	14, 14, 1,	         	16, 14, 1,	         	         	         	         	         	         	         	         	         	         	         	28, 14, 1,	\
    //      2, 15, 1,	         	         	         	         	         	         	         	         	         	         	13, 15, 1,	         	         	         	17, 15, 1,	         	         	         	         	         	         	         	         	         	         	28, 15, 1,	\
    //              	 3, 16, 1,	         	         	         	         	         	         	         	         	12, 16, 1,	         	         	         	         	         	18, 16, 1,	         	         	         	         	         	         	         	         	27, 16, 1,	         	\
    //              	 3, 17, 1,	         	         	         	         	         	         	         	11, 17, 1,	         	         	         	         	         	         	         	19, 17, 1,	         	         	         	         	         	         	         	27, 17, 1,	         	\
    //              	 3, 18, 1,	         	         	         	         	         	         	10, 18, 1,	         	         	         	         	         	         	         	         	         	20, 18, 1,	         	         	         	         	         	         	27, 18, 1,	         	\
    //              	         	 4, 19, 1,	         	         	         	         	 9, 19, 1,	         	         	         	         	         	         	         	         	         	         	         	21, 19, 1,	         	         	         	         	26, 19, 1,	         	         	\
    //              	         	 4, 20, 1,	         	         	         	 8, 20, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	22, 20, 1,	         	         	         	26, 20, 1,	         	         	\
    //              	         	         	 5, 21, 1,	         	 7, 21, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	23, 21, 1,	         	25, 21, 1,	         	         	         	\
    //              	         	         	         	 6, 22, 1,	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	         	24, 22, 1,	         	         	         	         	\
    //     }
    //     #define PETAL_MAPPING_PIXELS 88
    // #else /* PETAL_PIXEL_PATTERN == ? */
    //     #define PETAL_MAPPING {}
    //     #define PETAL_MAPPING_PIXELS 0
    // #endif /* PETAL_PIXEL_PATTERN == ? */
};

// derived constants
pub const USEC_PER_EPOCH: u16 = (1_000_000 / BASE_HZ / WILDFIRE_SPEEDUP);
// When blocking for input, aim to block until USABLE_USEC_PER_EPOCH usec have
// passed this epoch. You'll miss, which is why this is < USEC_PER_EPOCH.
//
// Take up the ratio if you don't have enough "wait" time in the diagnostic,
// and can tolerate more stutter.
pub const USABLE_USEC_PER_EPOCH: u16 = (0.6 * USEC_PER_EPOCH);
pub const USABLE_MSEC_PER_EPOCH: u16 = (USABLE_USEC_PER_EPOCH / 1_000);

// pattern names
pub const PATTERN_ERR: u16 = 0;
pub const PATTERN_BASE: u16 = 1;
pub const PATTERN_RAINBOW_SPOTLIGHTS_ON_GREY: u16 = 2;
pub const PATTERN_RAINBOW_SPOTLIGHTS_ON_TWO_TONES: u16 = 3;
pub const PATTERN_TWO_TONES: u16 = 4;
pub const PATTERN_OPPOSED_TONES: u16 = 5;
pub const PATTERN_TRIAD_TONES: u16 = 6;
pub const PATTERN_UNUSED: u16 = 7;
pub const PATTERN_HANABI: u16 = 8;
pub const PATTERN_Q2: u16 = 9;
pub const PATTERN_FULL_RAINBOW: u16 = 10;
pub const PATTERN_SOLID: u16 = 20;
pub const PATTERN_N_TONES: u16 = 30;
//pub fn PATTERN_RAND_N_TONES() u16 { PATTERN_N_TONES+2+(rand()%3); }
pub const AGGRESSIVE_REVERSION: u16 = 100;

pub const PATTERN_SACN_COLOR: u16 = 2_048; // range from here to 13x here
pub const PATTERN_SACN_TEXTURE: u16 = 256;
pub const PATTERN_SACN_INTENSITY: u16 = 1;
pub const PATTERN_SACN_INTENSE: u16 = 255;

pub fn PATTERN_SACN(color: u16, texture: u16, intensity: u16) u16 {
    return (1 + color) * PATTERN_SACN_COLOR + texture * PATTERN_SACN_TEXTURE + intensity * PATTERN_SACN_INTENSITY;
}
pub fn PATTERN_IS_SACN(pattern: u16) u16 {
    return pattern >= PATTERN_SACN_COLOR;
}
pub fn PATTERN_SACN_GET_COLOR(pattern: u16) u16 {
    return pattern / PATTERN_SACN_COLOR - 1;
}
pub fn PATTERN_SACN_GET_TEXTURE(pattern: u16) u16 {
    return (pattern % PATTERN_SACN_COLOR) / PATTERN_SACN_TEXTURE;
}
pub fn PATTERN_SACN_GET_INTENSITY(pattern: u16) u16 {
    return pattern % PATTERN_SACN_TEXTURE;
}

pub const SCENE_BASE: u16 = 0;
pub const SCENE_NO_HIBERNATION: u16 = 1;
pub const SCENE_CIRCLING_RAINBOWS: u16 = 10;
pub const SCENE_Q2: u16 = 50;

pub const MENU_ACTIONS: u16 = 1_000;
pub const MENU_SCENES: u16 = 2_000;
