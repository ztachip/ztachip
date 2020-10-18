#ifndef _EXAMPLES_VISION_AI_GUI_H_
#define _EXAMPLES_VISION_AI_GUI_H_

extern "C" int GuiInit(int argc,char **argv,int w,int h,bool showSlider,bool showLabel,bool showDraw);
extern "C" int GuiRun(int (*_guicallback)(unsigned char *));
extern "C" void GuiSetText(char *str);
extern "C" float GuiGetScale();
extern "C" void GuiDrawClear(int w,int h);
extern "C" void GuiDrawRectangle(int x,int y,int w,int h,char *label);

#endif
