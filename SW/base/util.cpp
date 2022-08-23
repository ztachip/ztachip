//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "types.h"
#include "ztahost.h"
#include "util.h"

// Some general utility functions...

#pragma pack(push, 1)
typedef struct tagBITMAPFILEHEADER
{
    uint16_t bfType;  //specifies the file type
    uint32_t bfSize;  //specifies the size in bytes of the bitmap file
    uint16_t bfReserved1;  //reserved; must be 0
    uint16_t bfReserved2;  //reserved; must be 0
    uint32_t bOffBits;  //species the offset in bytes from the bitmapfileheader to the bitmap bits
}BITMAPFILEHEADER;


typedef struct tagBITMAPINFOHEADER
{
    uint32_t biSize;  //specifies the number of bytes required by the struct
    uint32_t biWidth;  //specifies width in pixels
    uint32_t biHeight;  //species height in pixels
    uint16_t biPlanes; //specifies the number of color planes, must be 1
    uint16_t biBitCount; //specifies the number of bit per pixel
    uint32_t biCompression;//spcifies the type of compression
    uint32_t biSizeImage;  //size of image in bytes
    uint32_t biXPelsPerMeter;  //number of pixels per meter in x axis
    uint32_t biYPelsPerMeter;  //number of pixels per meter in y axis
    uint32_t biClrUsed;  //number of colors used by th ebitmap
    uint32_t biClrImportant;  //number of colors that are important
}BITMAPINFOHEADER;
#pragma pack(pop)

// Raise to power

float Util::pow(float x,int power) {
   float y=1.0;
   for(int i=0;i < power;i++)
      y=y*x;
   return y;
}

// Convert from float to int12 format
// pos is position of decimal point

void Util::Float2Int(float *in,int16_t *out,int pos,int len) {
   bool flag;
   unsigned int v;
   int v2;
   int e, e2;
   short result;
   for (int i = 0; i < len; i++) {
      v = *((unsigned int *)&in[i]);
      if (v == 0) {
         result=0;
      } else {
         flag = false;
         e = (v >> 23) & 0xff;
         e2 = e-127;
         v2 = (v & 0x007FFFFF);
         v2 |= 0x00800000;
         if (pos >= (e2 + 1)) {
            v2 = v2 >> (pos - e2 - 1);
         } else {
            v2 = 0x00FFFFFF;
            flag=true;
         }
         result = (v2 >> 9)&(0x7fff);
         if (v2 & 0x100) {
            if (result < 0x7FFF) {
               result++;
            } else {
               flag = true;
            }
         }
         if (v & 0x80000000)
            result = -result;
         if (flag) {
            if (result < 0) {
               result=(short)(0x8000);
            }
         }
      }
      out[i]=(result>>4);
   }
}

// Convert from int12 format to float
// pos is the position of decimal place.

void Util::Int2Float(int16_t *in,float *out,int pos,int len) {
   int v;
   for(int i=0;i < len;i++) {
      v=(int)in[i];
      if(v==0) {
         out[i]=0.0;
      } else {
         if(((DATA_BIT_WIDTH-1)-pos) >= 0)
            out[i]=(float)v/Util::pow((float)2.0,(DATA_BIT_WIDTH-1)-pos);
         else
            out[i]=(float)v*Util::pow((float)2.0,pos-(DATA_BIT_WIDTH-1));
      }
   }
}

// Return total tensor array size

size_t Util::GetTensorSize(std::vector<int>& shape) {
   size_t sz=1;
   for(int i=0;i < (int)shape.size();i++) {
      sz*=shape[i];
   }
   return sz;
}

// Read 24bit BMP image file

static uint8_t *bmpRead(const char *filename,int *h,int *w) {
   FILE *filePtr;
   BITMAPFILEHEADER bitmapFileHeader;
   uint8_t *bitmapImage;
   int readsize;
   int bisizeImage;
   BITMAPINFOHEADER bitmapInfoHeader;

   //open filename in read binary mode
   filePtr = fopen(filename, "rb");
   if (filePtr == NULL) {
      return 0;
   }
   //read the bitmap file header
   fread(&bitmapFileHeader, sizeof(BITMAPFILEHEADER), 1, filePtr);

   //verify that this is a bmp file by check bitmap id
   if (bitmapFileHeader.bfType != 0x4D42) {
      fclose(filePtr);
      return 0;
   }

   //read the bitmap info header

   fread(&bitmapInfoHeader, sizeof(BITMAPINFOHEADER), 1, filePtr); // small edit. forgot to add the closing bracket at sizeof

   *w=bitmapInfoHeader.biWidth;
   *h=bitmapInfoHeader.biHeight;

   //move file point to the begging of bitmap data
   fseek(filePtr, bitmapFileHeader.bOffBits, SEEK_SET);
   bisizeImage=(((bitmapInfoHeader.biWidth+3)/4)*4)*(int)bitmapInfoHeader.biHeight*3;

   //allocate enough memory for the bitmap image data
   bitmapImage = (unsigned char*)malloc(bisizeImage);

   //read in the bitmap image data
   readsize=fread(bitmapImage, 1, bisizeImage, filePtr);
   if(readsize != bisizeImage) {
      free(bitmapImage);
      fclose(filePtr);
      return 0;
   }
   //close file and return bitmap iamge data
   fclose(filePtr);
   return bitmapImage;
}

ZtaStatus BitmapRead(const char *bmpFile,TENSOR *outputTensor,TensorFormat fmt)
{
   uint8_t *pict;
   int bmp_w,bmp_h;
   int bmpActualWidth;
   int r,c;
   int w,h;
   int dx,dy;
   uint8_t *output;

   pict = bmpRead(bmpFile,&bmp_h,&bmp_w);
   if(!pict) {
      return ZtaStatusFail;
   }
   if(fmt==TensorFormatSplit) {
      std::vector<int> dim={3,bmp_h,bmp_w};
      outputTensor->Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
   } else {
      std::vector<int> dim={bmp_h,3*bmp_w};
      outputTensor->Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
   }
   output=(uint8_t *)outputTensor->GetBuf();

   w=bmp_w;
   h=bmp_h;
   dx=0;
   dy=0;
   bmpActualWidth=((bmp_w*3+3)/4)*4;
   uint8_t red, blue, green;
   for (r = 0; r < h; r++) {
      for (c = 0; c < w; c++) {
         blue = (pict[((bmp_h-1)-(r+dy))*bmpActualWidth+3*(c+dx)+0]);
         green = (pict[((bmp_h-1)-(r+dy))*bmpActualWidth+3*(c+dx)+1]);
         red = (pict[((bmp_h-1)-(r+dy))*bmpActualWidth+3*(c+dx)+2]);
         if(fmt==TensorFormatSplit) {
            output[0*w*h+r*w+c] = red;
            output[1*w*h+r*w+c] = green;
            output[2*w*h+r*w+c] = blue;
         } else {
             output[3*(r*w+c)] = red;
             output[3*(r*w+c)+1] = green;
             output[3*(r*w+c)+2] = blue;
         }
      }
   }
   free(pict);
   return ZtaStatusOk;
}
