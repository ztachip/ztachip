#include <gtk/gtk.h>
#include <stdlib.h>
#include "gui.h"

// Handling display function using GTK library

#define BYTES_PER_PIXEL 3

typedef struct {
  GtkImage *image;
  GtkWidget *label;
  GtkWidget *overlay;
  GtkWidget *draw;
  GtkWidget *scale;
  GtkAdjustment *hadjustment;
  GtkWidget *hlabel;
  int rows;
  int cols;
  int stride;
  cairo_surface_t *plot_surface;
  cairo_t *plot;
  cairo_t *eraser;
} ImageData;

static float currScalePos=0.0;
static int (*guicallback)(unsigned char *);
static ImageData id;
static GtkWidget *window;
static GdkPixbuf *pb;
static guchar *pixels;
static int ROWS=0;
static int COLS=0;


void free_pixels(guchar *pixels, gpointer data) {
  free(pixels);
}

// Periodic function to update screen

int update_pic(gpointer data) {
  ImageData *id = (ImageData*)data;
  GdkPixbuf *pb = gtk_image_get_pixbuf(id->image);
  guchar *g = gdk_pixbuf_get_pixels(pb);
  if(guicallback((unsigned char *)g))
     gtk_image_set_from_pixbuf(GTK_IMAGE(id->image), pb);
  return TRUE; // continue timer
}

// Set label widget

void GuiSetText(char *str) {
   if(id.label)
      gtk_label_set_markup(GTK_LABEL(id.label),str);
}

// Get current slider value

float GuiGetScale() {
   return currScalePos/100.0;
}

// Clear draw area

void GuiDrawClear(int w,int h) {
   if(!id.draw)
      return;
   if(w==0)
      w=COLS;
   if(h==0)
      h=ROWS;
   cairo_rectangle(id.eraser,0,0,w,h);
   cairo_fill(id.eraser);
   cairo_stroke(id.eraser);
}

// Draw a rectangle in the draw area

void GuiDrawRectangle(int x,int y,int w,int h,char *label) {
   if(!id.draw)
      return;
   cairo_rectangle(id.plot,x,y,w,h);
   cairo_stroke(id.plot);
   cairo_move_to(id.plot,x,y);
   if(label)
      cairo_show_text(id.plot,label);
}

// Callback for slider

static void scale_moved(GtkRange *range,gpointer user_data) {
   gdouble pos=gtk_range_get_value(range);
   currScalePos=pos;
}

// Draw area paint function

gboolean guidrawcallback(GtkWidget *widget,cairo_t *drawing_area,ImageData *id) {
   cairo_set_source_surface(drawing_area,id->plot_surface,0,0);
   cairo_paint(drawing_area);
   return false;
}

// Application initialize GUI

int GuiInit(int argc,char **argv,int w,int h,bool showSlider,bool showLabel,bool showDraw) {

  gtk_init(&argc,&argv);

  ROWS=h;
  COLS=w;

  // Setup Cairo stuffs

  id.plot_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32,COLS,ROWS);
  id.plot = cairo_create(id.plot_surface);
  cairo_set_source_rgb(id.plot,1.0,0.0,0.0);
  id.eraser = cairo_create(id.plot_surface);
  cairo_set_source_rgba(id.eraser,0.0,0.0,0.0,0.0);
  cairo_set_operator(id.eraser,CAIRO_OPERATOR_CLEAR);

  id.rows = ROWS;
  id.cols = COLS;
  id.stride = COLS * BYTES_PER_PIXEL;
  id.stride += (4 - id.stride % 4) % 4; // ensure multiple of 4

  pixels = (guchar *)calloc(ROWS * id.stride, 1);

  pb = gdk_pixbuf_new_from_data(
    pixels,
    GDK_COLORSPACE_RGB,     // colorspace
    0,                      // has_alpha
    8,                      // bits-per-sample
    COLS, ROWS,             // cols, rows
    id.stride,              // rowstride
    free_pixels,            // destroy_fn
    NULL                    // destroy_fn_data
  );

  id.image = GTK_IMAGE(gtk_image_new_from_pixbuf(pb));
  if(showLabel)
     id.label = gtk_label_new("");
  else
     id.label = 0;
  id.overlay = gtk_overlay_new();

  if(showDraw) {
     id.draw = gtk_drawing_area_new();
     g_signal_connect(G_OBJECT(id.draw),"draw",G_CALLBACK(guidrawcallback),&id); 
  } else {
     id.draw = 0;
  }

  if(showSlider) {
     currScalePos=0.0;
     id.hadjustment=gtk_adjustment_new(0,0,100,5,10,0);
     id.hlabel=gtk_label_new("Move scale...");
     id.scale = gtk_scale_new(GTK_ORIENTATION_HORIZONTAL,id.hadjustment);
     gtk_widget_set_hexpand(id.scale,TRUE);
     gtk_widget_set_valign(id.scale,GTK_ALIGN_START);
     g_signal_connect(id.scale,"value-changed",G_CALLBACK(scale_moved),id.hlabel);
  } else {
     id.hadjustment=0;
     id.hlabel=0;
     id.scale=0;
  }

  if(id.draw)
     gtk_widget_set_size_request(id.draw,COLS,ROWS);
  if(id.label) {
     gtk_widget_set_halign(id.label,GTK_ALIGN_START);
     gtk_widget_set_valign(id.label,GTK_ALIGN_START);
  }

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_title(GTK_WINDOW(window), "Image");
  gtk_window_set_default_size(GTK_WINDOW(window), COLS, ROWS);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

  gtk_overlay_add_overlay(GTK_OVERLAY(id.overlay),GTK_WIDGET(id.image));
  if(id.label)
     gtk_overlay_add_overlay(GTK_OVERLAY(id.overlay),id.label);
  if(id.draw)
     gtk_overlay_add_overlay(GTK_OVERLAY(id.overlay),id.draw);
  if(id.scale)
     gtk_overlay_add_overlay(GTK_OVERLAY(id.overlay),id.scale);
  gtk_container_add(GTK_CONTAINER(window),id.overlay);
  gtk_widget_show_all(window);

  return 0;
}

// Application start running GUI thread

int GuiRun(int (*_guicallback)(unsigned char *)) {
  guicallback=_guicallback;
  g_timeout_add(2,
                update_pic,
                &id);
  gtk_widget_show_all(window);
  gtk_main();
  return 0;
}
