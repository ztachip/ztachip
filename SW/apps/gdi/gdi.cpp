#include <stdlib.h>
#include <string.h>
#include <vector>
#include "../../src/soc.h"
#include "../../base/zta.h"
#include "../../base/util.h"
#include "../../base/tensor.h"
#include "gdi.h"

static TENSOR GdiFontTensor;
uint8_t *GdiFont=0;

// Initialize GDI library. This library implements various drawing
// functions

bool GdiInit() {
   GdiFontTensor.CreateWithBitmap("alphabet2.bmp",TensorFormatInterleaved);
   GdiFont=(uint8_t *)GdiFontTensor.GetBuf();
   return true;
}
