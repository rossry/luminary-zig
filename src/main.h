#include "cellular.h"
#include <sys/time.h>

typedef struct timeval timeval_t;

void c_init();
void c_exit();

// only mutates arrays at index [xy]
// only reads from mutable arrays at index [xy]
// therefore, thread-safe to run on cells in parallel
void c_compute_cyclic_evolution_cell(
    int xy,
    int epoch,
    int scratch[],
    int control_directive_0[], // read-only
    int control_directive_0_next[], // only accesses [xy]
    int control_directive_1[], // read-only
    int control_directive_1_next[], // only accesses [xy]
    int control_orth[], // read-only
    int control_orth_next[], // only accesses [xy]
    int control_diag[], // read-only
    int control_diag_next[], // only accesses [xy]
    int rainbow_0[], // read-only
    int rainbow_0_next[], // only accesses [xy]
    int impatience_0[], // only accesses [xy]
    int rainbow_1[], // read-only
    int rainbow_1_next[], // only accesses [xy]
    int impatience_1[], // only accesses [xy]
    int pressure_self[], // read-only
    int pressure_orth[], // read-only
    int pressure_orth_next[], // only accesses [xy]
    int pressure_diag[], // read-only
    int pressure_diag_next[], // only accesses [xy]
    int waves_orth[], // read-only
    int waves_orth_next[], // only accesses [xy]
    int waves_diag[], // read-only
    int waves_diag_next[], // only accesses [xy]
    turing_vector_t turing_u[], // only accesses [xy]
    turing_vector_t turing_v[] // only accesses [xy]
);

void c_compute_global_pattern_driver(
    int epoch,
    int scene,
    int control_directive_0[],
    int control_directive_0_next[],
    int control_directive_1[],
    int control_directive_1_next[],
    int control_orth[],
    int control_orth_next[],
    int waves_orth[],
    int waves_orth_next[],
    int waves_diag[],
    int waves_diag_next[]
);

void c_apply_other_rules_cell(
    int xy,
    int control_directive_0[],
    int rainbow_tone[],
    int rainbow_0[],
    int rainbow_0_next[],
    int pressure_self[],
    int waves_orth_next[]
);

void c_apply_umbrary_cell(
    int xy,
    int umbrary_active,
    int epoch,
    int rainbow_0_next[],
    turing_vector_t turing_u[],
    turing_vector_t turing_v[]
);

void c_draw_and_io(
    int spectrary_active,
    int umbrary_active,
    int epoch,
    turing_vector_t turing_u[],
    turing_vector_t turing_v[]
);

void c_display_flush(
    int epoch,
    timeval_t* refreshed,
    int* n_dirty_pixels,
    double* n_dirty_pixels_avg
);

void c_draw_ui_and_handle_input(
    int spectrary_active,
    int umbrary_active,
    int epoch,
    int scene,
    int menu_context,
    int control_directive_0[],
    int control_directive_1[],
    int control_orth[],
    int rainbow_tone[],
    int waves_orth[],
    int in_chr,
    timeval_t* start,
    timeval_t* computed,
    timeval_t* drawn,
    timeval_t* refreshed,
    timeval_t* handled,
    timeval_t* slept,
    timeval_t* stop,
    timeval_t* fio_start,
    timeval_t* fio_stop,
    double* compute_avg,
    double* fio_avg,
    double* draw_avg,
    double* refresh_avg,
    double* wait_avg,
    double* sleep_avg,
    double* total_avg,
    double* n_dirty_pixels_avg
);
