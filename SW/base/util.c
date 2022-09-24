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
#include <stdbool.h>
#include <stdint.h>
#include "types.h"
#include "ztalib.h"
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

// Convert from float to int12 format
// pos is position of decimal point

int16_t FLOAT2INT(float in) {
   bool flag;
   unsigned int v;
   int v2;
   int e, e2;
   short result;
   int pos=DATA_BIT_WIDTH-1;

   v = *((unsigned int *)&in);
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
   return (result>>4);
}

// Read 24bit BMP image file

uint8_t *bmpRead(const char *filename,int *h,int *w) {
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

