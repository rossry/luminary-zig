#ifndef DISPLAY_H
#define DISPLAY_H

#include <cairo.h>

void print_sacn_message(char *message, int y);

void display_init();
void display_color(int xy, int color, int state_color);
void display_light(int id, int color);
int display_flush_synchronous(int epoch, cairo_t **cr_for_async); // returns # flushed pixels
void display_flush_asynchronous(int epoch, cairo_t *cr_from_sync);

#endif /* DISPLAY_H */
