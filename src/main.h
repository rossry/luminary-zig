#include "cellular.h"
#include <sys/time.h>

typedef struct timeval timeval_t;

void c_init();
void c_exit();

void c_compute_cyclic_evolution_cell(
    int xy,
    int epoch,
    int scratch[],
    int control_directive_0[],
    int control_directive_0_next[],
    int control_directive_1[],
    int control_directive_1_next[],
    int control_orth[],
    int control_orth_next[],
    int control_diag[],
    int control_diag_next[],
    int rainbow_0[],
    int rainbow_0_next[],
    int impatience_0[],
    int rainbow_1[],
    int rainbow_1_next[],
    int impatience_1[],
    int pressure_self[],
    int pressure_orth[],
    int pressure_orth_next[],
    int pressure_diag[],
    int pressure_diag_next[],
    double excitement[],
    int waves_orth[],
    int waves_orth_next[],
    int waves_diag[],
    int waves_diag_next[],
    turing_vector_t turing_u[],
    turing_vector_t turing_v[]
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

void c_compute_fio_step(
    int spectrary_active,
    int umbrary_active,
    int epoch
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

void c_compute_turing_evolution_cell(
    int xy,
    int spectrary_active,
    int umbrary_active,
    int epoch,
    int control_directive_0[],
    int rainbow_0[],
    int rainbow_0_next[],
    int pressure_self[],
    int waves_orth_next[],
    turing_vector_t turing_u[],
    turing_vector_t turing_v[]
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
    int control_directive_0[],
    int control_directive_0_next[],
    int control_directive_1[],
    int control_directive_1_next[],
    int control_orth[],
    int control_orth_next[],
    int control_diag[],
    int control_diag_next[],
    int rainbow_0[],
    int rainbow_0_next[],
    int rainbow_1[],
    int rainbow_1_next[],
    int pressure_orth[],
    int pressure_orth_next[],
    int pressure_diag[],
    int pressure_diag_next[],
    int waves_orth[],
    int waves_orth_next[],
    int waves_diag[],
    int waves_diag_next[],
    turing_vector_t turing_u[],
    turing_vector_t turing_v[]
);

void c_draw_ui(
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
    int waves_orth_next[],
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
    int* n_dirty_pixels,
    double* compute_avg,
    double* fio_avg,
    double* draw_avg,
    double* refresh_avg,
    double* wait_avg,
    double* sleep_avg,
    double* total_avg,
    double* n_dirty_pixels_avg
);
