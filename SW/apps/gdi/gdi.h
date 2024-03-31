#ifndef _TARGET_APPS_GDI_GDI_H_
#define _TARGET_APPS_GDI_GDI_H_

#include <stdlib.h>
#include <string.h>
#include <vector>
#include "../../src/soc.h"
#include "../../base/zta.h"
#include "../../base/util.h"
#include "../../base/tensor.h"

extern bool GdiInit(); 

// Draw text

inline void GdiDrawText(const char *str,int r,int c) {
    extern uint8_t *GdiFont;
    uint8_t *screen=DisplayGetBuffer();
    int i,j,idx;
    uint8_t *s,*d;
    int ch;
    int len,len2;

#define ALPHABET_DIM 16

    if(r<0) r=0;
    if((r+ALPHABET_DIM) >= WEBCAM_HEIGHT)
        return;
    if(c<0) c=0;
    len=strlen(str);
    len2=((WEBCAM_WIDTH-c) >> 4);
    len=(len<len2)?len:len2;
    for(j=0;j < len;j++) {
        ch=(int)(*str++);
        // Locate bitmap for the letter in alphabet2.bmp image 
        if(ch==0)
            idx=0;
        else
            idx=ch-1;
        if(idx >= (6*16))
            idx++;
        if(idx >= (8*16))
            idx=0;
        s=GdiFont+3*((((idx>>4)<<4)<<8)+((idx&0xF)<<4));
        d=&screen[3*(r*WEBCAM_WIDTH+c)];
        for(i=0;i < ALPHABET_DIM;i++) {
            memcpy(d,s,ALPHABET_DIM*3);
            s += (ALPHABET_DIM<<4)*3;
            d += WEBCAM_WIDTH*3;
        }
        c+=ALPHABET_DIM;
    }
}

// Draw rectangle

inline void GdiDrawRectangle(int r1,int c1,int r2,int c2) {
    int r,c;
    uint8_t *p;
    uint8_t *screen=DisplayGetBuffer();

    // Top line
    if(r1<0) r1=0;
    if(r1 >= (WEBCAM_HEIGHT-1)) r1=WEBCAM_HEIGHT-2;
    if(c1<0) c1=0;
    if(c1 >= (WEBCAM_WIDTH-1)) c1=WEBCAM_WIDTH-2;
    if(r2<0) r2=0;
    if(r2 >= (WEBCAM_HEIGHT-1)) r2=WEBCAM_HEIGHT-2;
    if(c2<0) c2=0;
    if(c2 >= (WEBCAM_WIDTH-1)) c2=WEBCAM_WIDTH-2;

    // top line
    for(c=c1,p=&screen[3*(r1*WEBCAM_WIDTH+c1)];c <= c2;c++,p+=3) {
        p[0]=0xff;
        p[1]=0;
        p[2]=0;
    }
    // Left line
    for(r=r1,p=&screen[3*(r1*WEBCAM_WIDTH+c1)];r <= r2;r++,p+=(WEBCAM_WIDTH*3)) {
        p[0]=0xff;
        p[1]=0;
        p[2]=0;
    }
    // Right line
    for(r=r1,p=&screen[3*(r1*WEBCAM_WIDTH+c2)];r <= r2;r++,p+=(WEBCAM_WIDTH*3)) {
        p[0]=0xff;
        p[1]=0;
        p[2]=0;
    }
    // Bottom line
    for(c=c1,p=&screen[3*(r2*WEBCAM_WIDTH+c1)];c <= c2;c++,p+=3) {
        p[0]=0xff;
        p[1]=0;
        p[2]=0;
    }
}

// Draw a point

inline void GdiDrawPoint(int r,int c) {
    uint8_t *display_p=DisplayGetBuffer();
    display_p+=3*(r*DISPLAY_WIDTH+c);
    display_p[0]=0xff;
    display_p[1]=0;
    display_p[2]=0;
    display_p[0+3*DISPLAY_WIDTH]=0xff;
    display_p[1+3*DISPLAY_WIDTH]=0;
    display_p[2+3*DISPLAY_WIDTH]=0;
    display_p[3]=0xff;
    display_p[4]=0;
    display_p[5]=0;
    display_p[3+3*DISPLAY_WIDTH]=0xff;
    display_p[4+3*DISPLAY_WIDTH]=0;
    display_p[5+3*DISPLAY_WIDTH]=0;
}

#endif
