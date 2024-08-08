#include "cellular.h"
#include <sys/time.h>

typedef struct timeval timeval_t;

void c_init();
void c_exit();

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
