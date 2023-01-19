#include "main.h"
#include "constants.h"

#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>
#include <math.h>

#include "cellular.h"
#include "pattern.h"
#include "display.h"

#ifdef SPECTRARY
    #include "spectrary.h"
#endif /* SPECTRARY */

#ifdef UMBRARY
    #include "umbrary.h"
#endif /* UMBRARY */

#ifdef SACN_SERVER
    #include "sacn-server-luminary.h"
    #include "sacn-constants-luminary.h"
    
    sacn_channels_t sacn_channels;
    
    #ifdef SACN_TEST_CLIENT
        #include "sacn-test-client-luminary.h"
        uint8_t sacn_test_client_color = 0;
        uint8_t sacn_test_client_pattern = 0;
        uint8_t sacn_test_client_transition = 0;
    #endif /* SACN_TEST_CLIENT */
#endif /* SACN_SERVER */

double usec_time_elapsed(struct timeval *from, struct timeval *to) {
    return (double)(to->tv_usec - from->tv_usec) + (double)(to->tv_sec - from->tv_sec) * MILLION;
}

int c_main_deprecated(int argc, char *argv[]) {
    int spectrary_active = 0;
    char* spectrary_file = NULL;
    
    #ifdef SPECTRARY
        switch (argc) {
        case 1:
            spectrary_active = 0;
            break;
        case 2:
            spectrary_active = 1;
            if (spectrary_active) {
                spectrary_file = argv[1]
            }
            break;
        default:
            printf("usage: %s [spectrary_file]\n", argv[0]);
            return 1;
        }
    #endif /* SPECTRARY */
    
    int umbrary_active = 0;
    char* umbrary_bmp_format_string = NULL;
        
    #ifdef UMBRARY
        switch (argc) {
        case 1:
            umbrary_active = 0;
            break;
        case 2:
            umbrary_active = 1;
            if (umbrary_active) {
                // this should be a printf pattern that points to a bmp when passed an int
                // frame 1 needs to exist, and umbrary will scan until it finds a gap
                umbrary_bmp_format_string = argv[1];
            }
            break;
        default:
            printf("usage: %s [bmp_format_string]\n", argv[0]);
            return 1;
        }
    #endif /* UMBRARY */
    
    int epoch_limit = 0;
    #ifndef SPECTRARY
        #ifndef UMBRARY
            switch (argc) {
            case 1:
                // pass
                break;
            case 2:
                epoch_limit = strtol(argv[1], NULL, 10);
                break;
            default:
                printf("usage %s [INT: epoch limit]\n", argv[0]);
                return 1;
            }
        #endif /* UMBRARY */
    #endif /* SPECTRARY */
    
    return c_run(
        epoch_limit,
        spectrary_active,
        spectrary_file,
        umbrary_active,
        umbrary_bmp_format_string
    );
}

int c_run(
    int epoch_limit,
    int spectrary_active,
    char* spectrary_file,
    int umbrary_active,
    char* umbrary_bmp_format_string
) {
    int n_cores = sysconf(_SC_NPROCESSORS_ONLN);
    
    #ifdef SPECTRARY
        if (spectrary_active) {
            // this should be a 3dft.dat file, as produced by snd2fftw
            spectrary_init(spectrary_file);
        }
    #endif /* SPECTRARY */
    
    #ifdef UMBRARY
        if (umbrary_active) {
            // this should be a printf pattern that points to a bmp when passed an int
            // frame 1 needs to exist, and umbrary will scan until it finds a gap
            umbrary_init(umbrary_bmp_format_string);
        }
    #endif /* UMBRARY */
    
    display_init();
    
    srand(5);
    
    int epoch = 0;
    int scene = SCENE_BASE;
    
    int menu_context = MENU_ACTIONS;
    
    int scratch[ROWS * COLS];
    
    int control_directive_0[ROWS * COLS];
    int control_directive_0_next[ROWS * COLS];
    int control_directive_1[ROWS * COLS];
    int control_directive_1_next[ROWS * COLS];
    int control_orth[ROWS * COLS];
    int control_orth_next[ROWS * COLS];
    int control_diag[ROWS * COLS];
    int control_diag_next[ROWS * COLS];
    
    int rainbow_tone[ROWS * COLS];
    
    int rainbow_0[ROWS * COLS];
    int rainbow_0_next[ROWS * COLS];
    int impatience_0[ROWS * COLS];
    int rainbow_1[ROWS * COLS];
    int rainbow_1_next[ROWS * COLS];
    int impatience_1[ROWS * COLS];
    
    int pressure_self[ROWS * COLS];
    int pressure_orth[ROWS * COLS];
    int pressure_orth_next[ROWS * COLS];
    int pressure_diag[ROWS * COLS];
    int pressure_diag_next[ROWS * COLS];
    
    double excitement[ROWS * COLS];
    
    /*
    // needed to drive waves_(orth|diag)'s top row
    // hand-tuned to radiate from a center 84 cells above the midpoint of the top side
    int waves_base[] = WAVES_BASE_ARRAY;
    int waves_base_z_orig = 16;
    */
    int waves_orth[ROWS * COLS];
    int waves_orth_next[ROWS * COLS];
    int waves_diag[ROWS * COLS];
    int waves_diag_next[ROWS * COLS];

    turing_vector_t turing_u[ROWS * COLS];
    turing_vector_t turing_v[ROWS * COLS];
    
    int in_chr = 0;
    
    for (int xy = 0; xy < ROWS * COLS; ++xy) {
        scratch[xy] = 0;
        
        control_directive_0[xy] = 0;
        control_directive_1[xy] = 0;
        control_orth[xy] = 0;
        control_diag[xy] = 0;
        
        rainbow_0[xy] = RAND_COLOR;
        rainbow_0_next[xy] = RAND_COLOR;
        impatience_0[xy] = 0;
        rainbow_1[xy] = RAND_COLOR;
        rainbow_1_next[xy] = RAND_COLOR;
        impatience_1[xy] = 0;
        
        rainbow_tone[xy] = 0;
        
        excitement[xy] = 0.0;
        
        pressure_self[xy] = 0;
        pressure_orth[xy] = 0;
        pressure_diag[xy] = 0;
        
        waves_orth[xy] = 0;
        waves_diag[xy] = 0;
        
        turing_u[xy].state = (double)rand() / (double)(RAND_MAX/2) - 1.0;
        turing_u[xy].n_scales = 4;
        turing_u[xy].increment[0] = 0.01*2;
        turing_u[xy].increment[1] = 0.014*2;
        turing_u[xy].increment[2] = 0.018*2;
        turing_u[xy].increment[3] = 0.022*2;
        turing_u[xy].increment[4] = 0.026*2;
        
        turing_v[xy].state = (double)rand() / (double)(RAND_MAX/2) - 1.0;
        turing_v[xy].n_scales = 5;
        turing_v[xy].increment[0] = 0.01*2;
        turing_v[xy].increment[1] = 0.014*2;
        turing_v[xy].increment[2] = 0.018*2;
        turing_v[xy].increment[3] = 0.022*2;
        turing_v[xy].increment[4] = 0.026*2;
    }
    
    #ifdef SACN_SERVER
        #ifdef SACN_TEST_CLIENT
            sacn_test_client_start();
        #endif /* SACN_TEST_CLIENT */
        
        sacn_server_start();
        
        #ifdef SACN_TEST_CLIENT
            sacn_test_client_set_level(CHANNEL_M_MODE, 200);
            sacn_test_client_set_level(CHANNEL_M_MODE, 200); // duped to sync seq no.
        #endif /* SACN_TEST_CLIENT */
    #endif /* SACN_SERVER */
    
    struct timeval start, computed, drawn, refreshed, handled, slept, stop, fio_start, fio_stop;
    int n_dirty_pixels;
    double compute_avg, fio_avg, draw_avg, refresh_avg, wait_avg, sleep_avg, total_avg, n_dirty_pixels_avg;
    compute_avg = fio_avg = draw_avg = refresh_avg = wait_avg = sleep_avg = total_avg = n_dirty_pixels_avg = 0.0;
    
    gettimeofday(&start, NULL);
    
    while (epoch <= epoch_limit || epoch_limit <= 0) {
        ++epoch;
        
        // begin computing evolution
        for (int xy = 0; xy < ROWS * COLS; ++xy) {
            #ifdef THROTTLE_LOOP
            if (xy % THROTTLE_LOOP_N == 0) {
                usleep(THROTTLE_LOOP_USEC);
            }
            #endif /* THROTTLE_LOOP */
            int x = xy % COLS;
            int y = xy / COLS;
            if (y < PETAL_ROWS || x < FLOOR_COLS) {
                compute_decay(
                    control_orth, control_diag,
                    control_orth_next, control_diag_next,
                    control_directive_0, control_directive_1,
                    control_directive_0_next, control_directive_1_next,
                    xy
                );
                
                // revert to control_directive_1
                if (control_orth_next[xy] < HIBERNATION_TICKS
                    && control_orth_next[xy] < control_orth[xy]
                    && control_directive_0_next[xy] != control_directive_1_next[xy]
                    && (RAND_SECONDARY_TRANSITION || control_directive_0_next[xy] > AGGRESSIVE_REVERSION)
                ) {
                    control_directive_0_next[xy] = control_directive_1_next[xy];
                    control_orth_next[xy] += SECONDARY_TRANSITION_TICKS;
                }
                
                if (
                    #ifdef SACN_SERVER
                        !SACN_CONTROL(sacn_channels)
                    #else /* SACN_SERVER */
                        1
                    #endif /* SACN_SERVER */
                ) {
                    // revert to hibernation
                    if (control_orth_next[xy] == 0
                        && control_directive_0_next[xy] != PATTERN_BASE
                        && RAND_SECONDARY_TRANSITION
                    ) {
                        control_directive_0_next[xy] = control_directive_1_next[xy] = PATTERN_BASE;
                        control_orth_next[xy] = SECONDARY_TRANSITION_TICKS;
                    }
                }
                
                // evolve waves_(orth|diag)
                compute_decay(
                    waves_orth, waves_diag,
                    waves_orth_next, waves_diag_next,
                    scratch, scratch, scratch, scratch,
                    xy
                );
                
                if (epoch % WILDFIRE_SPEEDUP == 0) {
                    // evolve rainbow_0
                    // handled below, with separate timing logic
                    //rainbow_0_next[xy] = compute_cyclic(rainbow_0, impatience_0, xy);
                    
                    // evolve rainbow_1
                    if (pressure_orth[xy] > 17) {
                        rainbow_1_next[xy] = -1;
                    } else {
                        rainbow_1_next[xy] = compute_cyclic(rainbow_1, impatience_1, xy);
                    }
                    
                    // evolve pressure_(orth|diag)
                    compute_decay(
                        pressure_orth, pressure_diag,
                        pressure_orth_next, pressure_diag_next,
                        scratch, scratch, scratch, scratch,
                        xy
                    );
                    
                    if (pressure_self[xy] > 0) {
                        pressure_self[xy] -= 1;
                        pressure_orth_next[xy] = pressure_diag_next[xy] = PRESSURE_RADIUS_TICKS;
                    }
                }
                
                excitement[xy] += 1.0 / 3.0;
                excitement[xy] += pressure_orth[xy] * 2 / 3 / PRESSURE_RADIUS_TICKS;
                
                if (
                    1
                    && epoch % WILDFIRE_SPEEDUP == 0
                    #ifdef UMBRARY
                        && !umbrary_active
                    #endif /* UMBRARY */
                    && ( excitement[xy] > 1.0
                         || ((waves_orth_next[xy] / 17) % 800) > 800 - 1 - 6
                       )
                ) {
                    // evolve rainbow_0
                    rainbow_0_next[xy] = compute_cyclic(rainbow_0, impatience_0, xy);
                    
                    // maybe sync (turing_u, turing_v) from rainbow_0
                    if (
                        rainbow_0_next[xy] != rainbow_0[xy]
                        && rainbow_0_next[xy] != color_of_turing(xy, turing_u, turing_v)
                    ) {
		        if (1) {
			    rainbow_add_to_turing(xy, rainbow_0_next, turing_u, turing_v);
		            if ((rainbow_0_next[xy] - rainbow_0[xy] + COLORS)%COLORS == 2) {
  			        rainbow_add_to_turing(xy, rainbow_0_next, turing_u, turing_v);
			    }
                        } else if (
                            (1 + rainbow_0_next[xy] - color_of_turing(xy, turing_u, turing_v) + COLORS)%COLORS
                            <= 3
                        ) {
                            /* CR rrheingans-yoo: if you just incremented, then set
                               to substate 0 (but display substate -1 for one round
                               only). if you just randomized, then set to substate
                               rand{-1,0,1}.
                            */
                            switch (rainbow_0_next[xy] - rainbow_0[xy]) {
                            case 1: case 1-COLORS:
                            case 2: case 2-COLORS:
                                rainbow_to_turing(xy, rainbow_0_next, turing_u, turing_v, (rand()%3)-1);
                                break;
                            default:
                                rainbow_to_turing(xy, rainbow_0_next, turing_u, turing_v, (rand()%3)-1);
                                break;
                            }
                            // CR rrheingans-yoo: maybe compute/apply turing a few
                            // times at [xy] right now?
                        } else {
		  	    if ((rainbow_0[xy] + 1 - color_of_turing(xy, turing_u, turing_v))%EXTRA_COLORS < EXTRA_COLORS/2) {
                                extra_color_to_turing(
                                    xy,
                                    (extra_color_of_turing(xy, turing_u, turing_v)-3+EXTRA_COLORS)%EXTRA_COLORS,
                                    turing_u,
                                    turing_v
                                );
			    } else {
                                extra_color_to_turing(
                                    xy,
                                    (extra_color_of_turing(xy, turing_u, turing_v)+3+EXTRA_COLORS)%EXTRA_COLORS,
                                    turing_u,
                                    turing_v
                                );
			    }
                            rainbow_0_next[xy] = rainbow_0[xy];
                        }
                    }
                    
                    excitement[xy] -= 1.0;
                    if (excitement[xy] > 1.0) {
                        excitement[xy] = 1.0;
                    }
                }
            }
        }
        
        compute_turing_all(turing_u, turing_v);
        
        // drive waves_(orth|diag)'s top row
        /*
        waves_base_z_orig += WAVES_INCREMENT;
        for (int x = 0; x < FLOOR_COLS; ++x) {
            int xy = (PETAL_ROWS)*COLS + x;
            
            //waves_orth_next[xy] = waves_diag_next[xy] = max(waves_orth_next[xy],waves_orth[xy]) + 17;
            //waves_orth_next[ROWS*COLS/2 + COLS/2] = waves_diag_next[ROWS*COLS/2 + COLS/2] = waves_base_z_orig;
            waves_orth_next[xy] = waves_diag_next[xy] = waves_base[x+WAVES_BASE_X_ORIG] + waves_base_z_orig;
            switch (control_directive_0_next[xy]) {
            case PATTERN_N_TONES+2: case PATTERN_N_TONES+3: case PATTERN_N_TONES+4:
                control_directive_0_next[xy] = control_directive_1_next[xy] = PATTERN_N_TONES + 2 + (2*rainbow_tone[xy] + ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) / COLORS) % 3;
                if (control_directive_0_next[xy] != control_directive_0[xy]) {
                    control_orth_next[xy] += 18;
                }
            // default: pass
            }
            
            if (x == epoch % COLS && scene == SCENE_CIRCLING_RAINBOWS) {
                xy = (PETAL_ROWS+2)*COLS + x;
                control_directive_0_next[xy] = PATTERN_FULL_RAINBOW + AGGRESSIVE_REVERSION;
                control_directive_1_next[xy] = PATTERN_TWO_TONES;
                control_orth_next[xy] = HIBERNATION_TICKS + TRANSITION_TICKS;
            }
            
            if (scene == SCENE_Q2) {
                xy = (PETAL_ROWS+1)*COLS + x;
                control_directive_0_next[xy] = control_directive_1_next[xy] = PATTERN_Q2;
                if (control_directive_0_next[xy] != control_directive_0[xy]) {
                    control_orth_next[xy] += 18;
                }
            }
        }
        */
        
        gettimeofday(&fio_start, NULL);
        
        #ifdef SPECTRARY
        if (spectrary_active) {
            spectrary_update();
        }
        #endif /* SPECTRARY */
        
        #ifdef UMBRARY
        if (umbrary_active) {
            //umbrary_update(0);
            umbrary_update(epoch*22222);
        }
        #endif /* UMBRARY */
        
        gettimeofday(&fio_stop, NULL);
        
        for (int xy = 0; xy < ROWS * COLS; ++xy) {
            #ifdef THROTTLE_LOOP
            if (xy % THROTTLE_LOOP_N == 0) {
                usleep(THROTTLE_LOOP_USEC);
            }
            #endif /* THROTTLE_LOOP */
            int x = xy % COLS;
            int y = xy / COLS;
            
            #ifdef NOT_FOR_GG
            if (0
                && (y > PETAL_ROWS && x < FLOOR_COLS) // CR-someday rrheingans-yoo: this should instead be pressure_switch_depressed(xy)
                && rand() % (FLOOR_ROWS * FLOOR_COLS * 15) == 0 // CR-someday rrheingans-yoo: remove me
            ) {
                pressure_self[xy] = PRESSURE_DELAY_EPOCHS;
            }
            
            if (control_directive_0[xy] == PATTERN_FULL_RAINBOW
                || rainbow_0_next[xy] != rainbow_0[xy]
            ) {
                if (
                    #ifdef SACN_SERVER
                        SACN_CONTROL(sacn_channels)
                    #else /* SACN_SERVER */
                        0
                    #endif /* SACN_SERVER */
                ) {
                    rainbow_tone[xy] = PATTERN_SACN_GET_COLOR(control_directive_0[xy]);
                } else {
                    rainbow_tone[xy] = ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) % COLORS;
                }
            }
            #endif /* NOT_FOR_GG */
            
            apply_turing(
                turing_u,
                turing_v,
                xy,
                //1000.0 / max(1000,(epoch%3000)),
                1.0,
                //(double)rainbow_0_next[xy] / 12.0
                (double)(epoch%1000)/(1000.0)
            );
            
            #ifdef UMBRARY
                if (
                    xy%COLS < UMBRARY_OUTPUT_COLS
                    && xy/COLS < UMBRARY_OUTPUT_ROWS
                ) {
                    switch (umbrary_level[(xy/COLS)*UMBRARY_OUTPUT_COLS+(xy%COLS)]) {
                    case 1:
                        rainbow_0_next[xy] = (8+(epoch/900))%COLORS;
                        rainbow_to_turing(xy, rainbow_0_next, turing_u, turing_v, (epoch/300)%3-1);
                        break;
                    case -1:
                        rainbow_0_next[xy] = (2+(epoch/900))%COLORS;
                        rainbow_to_turing(xy, rainbow_0_next, turing_u, turing_v, (epoch/300)%3-1);
                        break;
                    //default:
                        // pass
                    }
                } else {
                    display_color(
                        xy,
                        BLACK,
                        BLACK
                    );
                }
            #endif /* UMBRARY */
        }
        // end computing evolution
        
        gettimeofday(&computed, NULL);
        
        // begin draw/increment mutex
        for (int xy = 0; xy < ROWS * COLS; ++xy) {
            #ifdef THROTTLE_LOOP
            if (xy % THROTTLE_LOOP_N == 0) {
                usleep(THROTTLE_LOOP_USEC);
            }
            #endif /* THROTTLE_LOOP */
            int color = extra_color_of_turing(xy, turing_u, turing_v);
	    /*
	    switch (rainbow_0_next[xy] - rainbow_0[xy]) {
            case 1: case 1-COLORS:
            case 2: case 2-COLORS:
                color = (3*rainbow_0_next[xy] - 1 + EXTRA_COLORS)%EXTRA_COLORS + EXTRA_COLOR;
            // default: // pass
            }
            */
            //color = 3*rainbow_0_next[xy] + EXTRA_COLOR;
            
            if (xy < EXTRA_COLORS) {
                color = xy + EXTRA_COLOR;
            }
            
            #ifdef UMBRARY
            if (umbrary_active) {
                if (epoch > INITIALIZATION_EPOCHS) {
                    if (
                        xy%COLS < UMBRARY_OUTPUT_COLS
                        && xy/COLS < UMBRARY_OUTPUT_ROWS
                    ) {
                        switch (umbrary_level[(xy/COLS)*UMBRARY_OUTPUT_COLS+(xy%COLS)]) {
                        case 1:
                        case -1:
                            display_color(xy, color, color);
                            break;
                        default:
                            display_color(xy, color+MAKE_DARKER, color+MAKE_DARKER);
                        }
                    } else {
                        display_color(
                            xy,
                            BLACK,
                            BLACK
                        );
                    }
                }
            } else {
                if (epoch > INITIALIZATION_EPOCHS) {
                     display_color(
                        xy,
                        color,
                        color
                    );
                }
            }
            #else /* UMBRARY */
                #ifdef SPECTRARY
                if (spectrary_active) {
                    if (epoch > INITIALIZATION_EPOCHS) {
                        /* // 19-bin spectrary
                        int freq = SPECTRARY_FREQS - abs(color - EXTRA_COLORS/2 - EXTRA_COLOR);
                        int c = (color+EXTRA_COLORS*3/4-EXTRA_COLOR)%EXTRA_COLORS + EXTRA_COLOR;
                        */
                        
                        // 36-bin spectrary
                        int freq = color-EXTRA_COLOR;
                        int c = color;
                        
                        if (
                            log(spectrary_level[freq]) > 4.9
                            || ( log(spectrary_level[(freq-1+SPECTRARY_FREQS)%SPECTRARY_FREQS]) > 4.9
                                 && log(spectrary_level[(freq+1)%SPECTRARY_FREQS]) > 4.9
                               )
                        ) {
                            display_color(
                                xy,
                                c,
                                color
                            );
                        } else if (
                            log(spectrary_level[freq]) > 4.6
                            || log(spectrary_level[(freq-1+SPECTRARY_FREQS)%SPECTRARY_FREQS]) > 4.6
                            || log(spectrary_level[(freq+1)%SPECTRARY_FREQS]) > 4.6
                        ) {
                            display_color(
                                xy,
                                c+MAKE_DARKER,
                                color
                            );
                        } else {
                            display_color(
                                xy,
                                BLACK,
                                color
                            );
                        }
                    }
                } else {
                    if (epoch > INITIALIZATION_EPOCHS) {
                         display_color(
                            xy,
                            color,
                            color
                        );
                    }
                }
                #else /* SPECTRARY */
                    if (epoch > INITIALIZATION_EPOCHS) {
                         display_color(
                            xy,
                            color,
                            color
                        );
                    }
                #endif /* SPECTRARY */
            #endif /* UMBRARY */
            
            /*
            if (xy >= EXTRA_COLORS) {
                display_color(xy, BLACK, BLACK);
            }
            */
            
            //display_color(xy, rainbow_0_next[xy], rainbow_0_next[xy]);
            /*
            display_color(
                xy,
                ((waves_orth_next[xy] / 17) / 800) % COLORS,
                ((waves_orth_next[xy] / 17) / 800) % COLORS
            );
            */
            
            /* CR rrheingans-yoo: can we use double-buffering instead? */
            
            // increment all states
            control_directive_0[xy] = control_directive_0_next[xy];
            control_directive_1[xy] = control_directive_1_next[xy];
            control_orth[xy] = control_orth_next[xy];
            control_diag[xy] = control_diag_next[xy];
            
            rainbow_0[xy] = rainbow_0_next[xy];
            rainbow_1[xy] = rainbow_1_next[xy];
            
            pressure_orth[xy] = pressure_orth_next[xy];
            pressure_diag[xy] = pressure_diag_next[xy];
            
            waves_orth[xy] = waves_orth_next[xy];
            waves_diag[xy] = waves_diag_next[xy];
        }
        
        #ifdef SPECTRARY
        if (spectrary_active) {
            for (int freq_i=0; freq_i<SPECTRARY_FREQS; ++freq_i) {
                mvprintw(freq_i, 2*DIAGNOSTIC_COLS-15, "%4.1f |            |  |            ", log(spectrary_level[freq_i]));
                for (int kk=0; kk<log(spectrary_level[freq_i])*2; ++kk) {
                    /* // 19-bin spectrary
                    int c = ((kk%2 ? freq_i : -freq_i) + EXTRA_COLORS/2 + EXTRA_COLORS*3/4)%EXTRA_COLORS + EXTRA_COLOR;
                    */
                    // 36-bin spectrary
                    int c = freq_i+EXTRA_COLOR;
                    attron(COLOR_PAIR(1+c));
                    mvprintw(freq_i, 2*DIAGNOSTIC_COLS-9+kk+(kk<12?0:1)+(kk<14?0:1), "%%");
                    attroff(COLOR_PAIR(1+c));
                }
            }
        }
        #endif /* SPECTRARY */
        // end draw/increment mutex
        
        gettimeofday(&drawn, NULL);
        
        // begin flush display
        if (epoch > INITIALIZATION_EPOCHS) {
            if (epoch % DISPLAY_FLUSH_EPOCHS == 0) {
                n_dirty_pixels = display_flush(epoch);
                n_dirty_pixels_avg = 0.99*n_dirty_pixels_avg + 0.01*n_dirty_pixels;
            }
            
            gettimeofday(&refreshed, NULL);
            
            if (usec_time_elapsed(&start, &refreshed) < USABLE_USEC_PER_EPOCH) {
                timeout(USABLE_MSEC_PER_EPOCH - usec_time_elapsed(&start, &refreshed) / THOUSAND);
                in_chr = getch();
            }
            
            if (in_chr > 0 && in_chr < 256) {
                mvprintw(DIAGNOSTIC_ROWS+1, 50, "input: %c                                           ", in_chr);
                
                int xy;
                switch (in_chr + menu_context) {
                case 'a'+MENU_ACTIONS: case 'a'+MENU_SCENES: case 'A'+MENU_ACTIONS: case 'A'+MENU_SCENES:
                    menu_context = MENU_ACTIONS;
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Menu: Actions");
                    break;
                    
                case 's'+MENU_ACTIONS: case 's'+MENU_SCENES: case 'S'+MENU_ACTIONS: case 'S'+MENU_SCENES:
                    menu_context = MENU_SCENES;
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Menu: Scenes");
                    break;
                    
                case 'c'+MENU_ACTIONS: case 'C'+MENU_ACTIONS:
                    for (int x = 0; x < COLS; ++x) {
                        xy = (PETAL_ROWS+2)*COLS + x;
                        waves_orth[xy] += (int)(10.5 * RAINBOW_TONE_EPOCHS * COLORS);
                    }
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Action: change color");
                    break;
                    
                case 'f'+MENU_ACTIONS:
                case 'F'+MENU_ACTIONS:
                    for (int x = 0; x < COLS; ++x) {
                        xy = (PETAL_ROWS+2)*COLS + x;
                        control_directive_0[xy] = PATTERN_FULL_RAINBOW;
                        control_directive_1[xy] = PATTERN_N_TONES+2;
                        control_orth[xy] = HIBERNATION_TICKS + TRANSITION_TICKS + (in_chr == 'F' || control_orth[xy] == 0 ? 10000 : 0);
                        waves_orth[xy] += (int)(10.5 * RAINBOW_TONE_EPOCHS * COLORS);
                    }
                    if (in_chr == 'F') {
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Action: centered rainbow + duration");
                    } else {
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Action: centered rainbow");
                    }
                    break;
                    
                case '1'+MENU_ACTIONS:
                case '2'+MENU_ACTIONS:
                case '3'+MENU_ACTIONS:
                case '4'+MENU_ACTIONS:
                case '5'+MENU_ACTIONS:
                    xy = (PETAL_ROWS+2)*COLS + (PETAL_COLS * (in_chr-'1')) + PETAL_COLS/2;
                    control_directive_0[xy] = PATTERN_FULL_RAINBOW;
                    control_directive_1[xy] = PATTERN_N_TONES+2;
                    control_orth[xy] = HIBERNATION_TICKS + TRANSITION_TICKS;
                    waves_orth[xy] += (int)(10.5 * RAINBOW_TONE_EPOCHS * COLORS);
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Action: rainbow on petal %d", (in_chr-'1')+1);
                    break;
                
                #ifdef SACN_TEST_CLIENT
                    case '-'+MENU_ACTIONS:
                        sacn_test_client_color -= 5;
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN ch%d:=%3d         ", CHANNEL_M_COLOR, sacn_test_client_color);
                        sacn_test_client_set_level(CHANNEL_M_COLOR, sacn_test_client_color);
                        break;
                    
                    case '='+MENU_ACTIONS:
                        sacn_test_client_color += 5;
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN ch%d:=%3d         ", CHANNEL_M_COLOR, sacn_test_client_color);
                        sacn_test_client_set_level(CHANNEL_M_COLOR, sacn_test_client_color);
                        break;
                    
                    case '['+MENU_ACTIONS:
                        sacn_test_client_pattern -= 5;
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN ch%d:=%3d         ", CHANNEL_M_PATTERN, sacn_test_client_pattern);
                        sacn_test_client_set_level(CHANNEL_M_PATTERN, sacn_test_client_pattern);
                        break;
                    
                    case ']'+MENU_ACTIONS:
                        sacn_test_client_pattern += 5;
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN ch%d:=%3d         ", CHANNEL_M_PATTERN, sacn_test_client_pattern);
                        sacn_test_client_set_level(CHANNEL_M_PATTERN, sacn_test_client_pattern);
                        break;
                    
                    case ';'+MENU_ACTIONS:
                        sacn_test_client_transition -= 5;
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN ch%d:=%3d         ", CHANNEL_M_TRANSITION, sacn_test_client_transition);
                        sacn_test_client_set_level(CHANNEL_M_TRANSITION, sacn_test_client_transition);
                        break;
                    
                    case '\''+MENU_ACTIONS:
                        sacn_test_client_transition += 5;
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN ch%d:=%3d         ", CHANNEL_M_TRANSITION, sacn_test_client_transition);
                        sacn_test_client_set_level(CHANNEL_M_TRANSITION, sacn_test_client_transition);
                        break;
                #endif /* SACN_TEST_CLIENT */
                
                case '0'+MENU_SCENES:
                    scene = SCENE_BASE;
                    #ifdef SACN_SERVER
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> sACN control             ");
                    #else /* SACN_SERVER */
                        mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Scene: Default           ");
                    #endif /* SACN_SERVER */
                    #ifdef SACN_TEST_CLIENT
                        sacn_test_client_set_level(CHANNEL_M_MODE, 128);
                    #endif /* SACN_TEST_CLIENT */
                    break;
                    
                case '1'+MENU_SCENES:
                    scene = SCENE_NO_HIBERNATION;
                    #ifdef SACN_TEST_CLIENT
                        sacn_test_client_set_level(CHANNEL_M_MODE, 0);
                    #endif /* SACN_TEST_CLIENT */
                    break;
                    
                case '2'+MENU_SCENES:
                    scene = SCENE_CIRCLING_RAINBOWS;
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Scene: Circling rainbows ");
                    break;
                    
                case '3'+MENU_SCENES:
                    scene = SCENE_Q2;
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> Scene: Q2                ");
                    break;
                    
                default:
                    mvprintw(DIAGNOSTIC_ROWS+1, 59, "-> (nothing)            ");
                }
            }
            
            #ifdef SACN_SERVER
                sacn_server_poll(&sacn_channels);
                
                if (SACN_CONTROL(sacn_channels)) {
                    int xy;
                    int pattern_next = PATTERN_SACN(sacn_channels.logical.m.color, sacn_channels.logical.m.pattern, PATTERN_SACN_INTENSE);
                    
                    switch(8*sacn_channels.logical.mode + sacn_channels.logical.m.transition) {
                    case 8:
                        xy = PETAL_ROWS*COLS + (COLS+1)/2;
                        if (control_directive_0[xy] != pattern_next) {
                            control_directive_0[xy] = control_directive_1[xy] = pattern_next;
                            control_orth[xy] = max(HIBERNATION_TICKS + TRANSITION_TICKS, control_orth[xy]) + 35;
                        }
                        break;
                    
                    case 9:
                        for (int ii=0; ii<5; ++ii) {
                            xy = PETAL_ROWS*COLS + PETAL_COLS*ii + (PETAL_COLS+1)/2;
                            if (control_directive_0[xy] != pattern_next) {
                                control_directive_0[xy] = control_directive_1[xy] = pattern_next;
                                control_orth[xy] = max(HIBERNATION_TICKS + TRANSITION_TICKS, control_orth[xy]) + 35;
                            }
                        }
                        break;
                    
                    case 10:
                        for (xy=0; xy<ROWS*COLS; ++xy) {
                            control_directive_0[xy] = control_directive_1[xy] = pattern_next;
                        }
                        break;
                    
                    case 11:
                        for (xy=0; xy<ROWS*COLS; ++xy) {
                            control_directive_0[xy] = control_directive_1[xy] = pattern_next;
                            rainbow_tone[xy] = sacn_channels.logical.m.color;
                        }
                        break;
                    
                    case 16: case 17:
                        for (int ii=0; ii<5; ++ii) {
                            xy = (PETAL_ROWS-PETAL_ROWS_CONNECTED*0)*COLS + ii*PETAL_COLS + 0;
                            pattern_next = PATTERN_SACN(sacn_channels.logical.p[PETAL_OF(xy)].color, sacn_channels.logical.p[PETAL_OF(xy)].pattern, PATTERN_SACN_INTENSE);
                            if (control_directive_0[xy] != pattern_next) {
                                control_directive_0[xy] = control_directive_1[xy] = pattern_next;
                                control_orth[xy] = max(HIBERNATION_TICKS + TRANSITION_TICKS, control_orth[xy]) + 35;
                            }
                            xy = (PETAL_ROWS-PETAL_ROWS_CONNECTED*0)*COLS + ii*PETAL_COLS + PETAL_COLS-1;
                            if (control_directive_0[xy] != pattern_next) {
                                control_directive_0[xy] = control_directive_1[xy] = pattern_next;
                                control_orth[xy] = max(HIBERNATION_TICKS + TRANSITION_TICKS, control_orth[xy]) + 35;
                            }
                        }
                        break;
                    
                    case 18:
                        for (xy=0; xy<ROWS*COLS; ++xy) {
                            control_directive_0[xy] = control_directive_1[xy] =
                                PATTERN_SACN(sacn_channels.logical.p[PETAL_OF(xy)].color, sacn_channels.logical.p[PETAL_OF(xy)].pattern, PATTERN_SACN_INTENSE);
                            control_orth[xy] = HIBERNATION_TICKS + TRANSITION_TICKS;
                        }
                        break;
                    
                    case 19:
                        for (xy=0; xy<ROWS*COLS; ++xy) {
                            control_directive_0[xy] = control_directive_1[xy] =
                                PATTERN_SACN(sacn_channels.logical.p[PETAL_OF(xy)].color, sacn_channels.logical.p[PETAL_OF(xy)].pattern, PATTERN_SACN_INTENSE);
                            rainbow_tone[xy] = sacn_channels.logical.p[PETAL_OF(xy)].color;
                            control_orth[xy] = HIBERNATION_TICKS + TRANSITION_TICKS;
                        }
                        break;
                    }
                }
            #endif /* SACN_SERVER */
            
            if (scene == SCENE_NO_HIBERNATION) {
                int xy = (PETAL_ROWS+2)*COLS + (PETAL_COLS * (2)) + PETAL_COLS/2;
                control_orth[xy] = max(control_orth[xy], 10000);
            }
            
            gettimeofday(&handled, NULL);
            
            if (usec_time_elapsed(&start, &handled) < USEC_PER_EPOCH) {
                usleep(USEC_PER_EPOCH - usec_time_elapsed(&start, &handled));
            }
        } else {
            if (epoch % 10 == 0) {
                mvprintw(0, 0, "initializing (%.0f%%)", 100.0 * epoch / INITIALIZATION_EPOCHS);
                refresh();
            }
            gettimeofday(&refreshed, NULL);
            gettimeofday(&handled, NULL);
        }
        
        gettimeofday(&slept, NULL);
        
        gettimeofday(&stop, NULL);
        
        // diagnostic printouts
        compute_avg = 0.99*compute_avg + 0.01*usec_time_elapsed(&start, &computed);
        fio_avg = 0.99*fio_avg + 0.01*usec_time_elapsed(&fio_start, &fio_stop);
        draw_avg = 0.99*draw_avg + 0.01*usec_time_elapsed(&computed, &drawn);
        if (epoch % DISPLAY_FLUSH_EPOCHS == 0) {
            refresh_avg = 0.99*refresh_avg + 0.01*usec_time_elapsed(&drawn, &refreshed);
        }
        wait_avg = 0.99*wait_avg + 0.01*usec_time_elapsed(&refreshed, &handled);
        sleep_avg = 0.99*sleep_avg + 0.01*usec_time_elapsed(&handled, &slept);
        total_avg = 0.99*total_avg + 0.01*usec_time_elapsed(&start, &stop);
        mvprintw(DIAGNOSTIC_ROWS+0, 2*DIAGNOSTIC_COLS-15, "compute:%5.1fms", (compute_avg - fio_avg) / THOUSAND);
        mvprintw(DIAGNOSTIC_ROWS+1, 2*DIAGNOSTIC_COLS-15, "file io:%5.1fms", fio_avg / THOUSAND);
        mvprintw(DIAGNOSTIC_ROWS+2, 2*DIAGNOSTIC_COLS-15, "draw:   %5.1fms", draw_avg / THOUSAND);
        mvprintw(DIAGNOSTIC_ROWS+3, 2*DIAGNOSTIC_COLS-15, "refresh:%5.1fms/%d", refresh_avg / THOUSAND, DISPLAY_FLUSH_EPOCHS);
        mvprintw(DIAGNOSTIC_ROWS+3, 2*DIAGNOSTIC_COLS+3, "(%dk%1dpx)   ", (int)n_dirty_pixels_avg/THOUSAND, ((int)n_dirty_pixels_avg % THOUSAND) / 100);
        mvprintw(DIAGNOSTIC_ROWS+4, 2*DIAGNOSTIC_COLS-15, "wait:   %5.1fms", wait_avg / THOUSAND);
        mvprintw(DIAGNOSTIC_ROWS+5, 2*DIAGNOSTIC_COLS-15, "sleep:  %5.1fms", sleep_avg / THOUSAND);
        mvprintw(DIAGNOSTIC_ROWS+6, 2*DIAGNOSTIC_COLS-15, "[note: %d cores]", n_cores);
        mvprintw(DIAGNOSTIC_ROWS+7, 2*DIAGNOSTIC_COLS-15, "epoch:%9d", epoch);
        mvprintw(DIAGNOSTIC_ROWS+8, 2*DIAGNOSTIC_COLS-15, "Hz:  %7.1f/%d(/%d)  ", 1 / (total_avg / MILLION), DISPLAY_FLUSH_EPOCHS, WILDFIRE_SPEEDUP);
        mvprintw(DIAGNOSTIC_ROWS+9, 2*DIAGNOSTIC_COLS-15, "usable:%5.1fms  ", USABLE_MSEC_PER_EPOCH);
        mvprintw(DIAGNOSTIC_ROWS+10,2*DIAGNOSTIC_COLS-15, "used:  %5.1fms  ", usec_time_elapsed(&start, &refreshed) / THOUSAND);
        
        //#ifdef UMBRARY
        //if (umbrary_active) {
        //    mvprintw(DIAGNOSTIC_ROWS+11, 2*DIAGNOSTIC_COLS-15, "umbrary:%5.1fsec  ", umbrary_usec_elapsed() / MILLION);
        //}
        //#endif /* UMBRARY */
        #ifdef SPECTRARY
        if (spectrary_active) {
            mvprintw(DIAGNOSTIC_ROWS+12, 2*DIAGNOSTIC_COLS-15, "spectrary:%5.1fsec  ", spectrary_time);
            mvprintw(DIAGNOSTIC_ROWS+13, 2*DIAGNOSTIC_COLS-15, "elapsed:  %5.1fsec  ", spectrary_usec_elapsed()/MILLION);
            mvprintw(DIAGNOSTIC_ROWS+14, 2*DIAGNOSTIC_COLS-15, "line read:%d  ", spectrary_n_lines);
        }
        #endif /* SPECTRARY */
        if (DIAGNOSTIC_SAMPLING_RATE != 1) {
            mvprintw(DIAGNOSTIC_ROWS+5, 2*DIAGNOSTIC_COLS-37, "terminal_display_");
            mvprintw(DIAGNOSTIC_ROWS+6, 2*DIAGNOSTIC_COLS-37, "downsampling: %d", DIAGNOSTIC_SAMPLING_RATE);
        }
        switch (scene) {
            case SCENE_BASE:
                #ifdef SACN_SERVER
                    if (SACN_CONTROL(sacn_channels)) {
                        mvprintw(DIAGNOSTIC_ROWS+0, 0, "sACN control active                 ", scene);
                    } else {
                        mvprintw(DIAGNOSTIC_ROWS+0, 0, "sACN control inactive; drive default", scene);
                    }
                #else /* SACN_SERVER */
                    mvprintw(DIAGNOSTIC_ROWS+0, 0, "scene: Default                      ", scene);
                #endif /* SACN_SERVER */
                break;
            case SCENE_NO_HIBERNATION:
                mvprintw(DIAGNOSTIC_ROWS+0, 0, "scene: Default+No_hibernation       ", scene);
                break;
            case SCENE_CIRCLING_RAINBOWS:
                mvprintw(DIAGNOSTIC_ROWS+0, 0, "scene: Circling_rainbows            ", scene);
                break;
            default:
                mvprintw(DIAGNOSTIC_ROWS+0, 0, "scene: ? (#%03d)                    ", scene);
        }
        for (int ii=0; ii<5; ++ii) {
            int xy = 8*COLS + (PETAL_COLS * ii) + 8;
            display_light(ii*2, ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) % COLORS);
            mvprintw(DIAGNOSTIC_ROWS+(2*ii + 1), 0, "%03d: %05d.  %02d.%04d.%02d (%5d:%06d|%5d)",
                520 + ii*2,
                ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) / COLORS,
                ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) % COLORS,
                ((waves_orth_next[xy] / 17) % RAINBOW_TONE_EPOCHS),
                ((waves_orth_next[xy] % 17)),
                control_directive_0[xy],
                control_orth[xy],
                control_directive_1[xy]
            );
            attron(COLOR_PAIR(1 + (rainbow_tone[xy]+1) % COLORS));
            mvprintw(DIAGNOSTIC_ROWS+(2*ii + 1),11," .");
            attroff(COLOR_PAIR(1 + (rainbow_tone[xy]+1) % COLORS));
            
            xy = 8*COLS + (PETAL_COLS * ii) + 22;
            display_light(ii*2+1, ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) % COLORS);
            mvprintw(DIAGNOSTIC_ROWS+(2*ii + 2), 0, "%03d: %05d.  %02d.%04d.%02d (%5d:%06d|%5d)",
                520 + ii*2 + 1,
                ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) / COLORS,
                ((waves_orth_next[xy] / 17) / RAINBOW_TONE_EPOCHS) % COLORS,
                ((waves_orth_next[xy] / 17) % RAINBOW_TONE_EPOCHS),
                ((waves_orth_next[xy] % 17)),
                control_directive_0[xy],
                control_orth[xy],
                control_directive_1[xy]
            );
            attron(COLOR_PAIR(1 + (rainbow_tone[xy]+1) % COLORS));
            mvprintw(DIAGNOSTIC_ROWS+(2*ii + 2),11," .");
            attroff(COLOR_PAIR(1 + (rainbow_tone[xy]+1) % COLORS));
        }
        
        switch (menu_context) {
        case MENU_ACTIONS:
            mvprintw(DIAGNOSTIC_ROWS+0, 50, "menu: Actions | S)cenes                ");
            mvprintw(DIAGNOSTIC_ROWS+2, 50, "c) change color                        ");
            mvprintw(DIAGNOSTIC_ROWS+3, 50, "f) centered effect                 ");
            mvprintw(DIAGNOSTIC_ROWS+4, 50, "1|2|3|4|5) effect on petal N       ");
            #ifdef SACN_TEST_CLIENT
                mvprintw(DIAGNOSTIC_ROWS+5, 50, "-|=) dec/inc sacn test color       ");
                mvprintw(DIAGNOSTIC_ROWS+6, 50, "[|]) dec/inc sacn test pattern     ");
                mvprintw(DIAGNOSTIC_ROWS+7, 50, ";|') dec/inc sacn test transition  ");
            #else /* SACN_TEST_CLIENT */
                mvprintw(DIAGNOSTIC_ROWS+5, 50, "                                   ");
                mvprintw(DIAGNOSTIC_ROWS+6, 50, "                                   ");
            #endif /* SACN_TEST_CLIENT */
            break;
        case MENU_SCENES:
            mvprintw(DIAGNOSTIC_ROWS+0, 50, "menu: Scenes | A)ctions                ");
            #ifdef SACN_SERVER
                mvprintw(DIAGNOSTIC_ROWS+2, 50, "0) sACN control (w/fallback)       ");
            #else /* SACN_SERVER */
                mvprintw(DIAGNOSTIC_ROWS+2, 50, "0) Default (cycling n-tones)       ");
            #endif /* SACN_SERVER */
            mvprintw(DIAGNOSTIC_ROWS+3, 50, "1) cycling n-tones + no_hibernation");
            mvprintw(DIAGNOSTIC_ROWS+4, 50, "2) Circling_rainbows               ");
            mvprintw(DIAGNOSTIC_ROWS+5, 50, "3) Q2 (experimental)               ");
            mvprintw(DIAGNOSTIC_ROWS+6, 50, "                                   ");
            mvprintw(DIAGNOSTIC_ROWS+7, 50, "                                   ");
            break;
        default:
            mvprintw(DIAGNOSTIC_ROWS+0, 50, "menu: ? (#%04d)", menu_context);
        }
        // end flush display
        
        start = stop;
    }
    
    endwin();
    
    return 0;
}
