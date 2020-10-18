#ifndef __TARGET_BASE_PROGRAMMER_H__
#define __TARGET_BASE_PROGRAMMER_H__

#include <stdint.h>
#include "types.h"

// Utility class to implement software upload to mcore/pcore

class Programmer {
public:
   static ZtaStatus Program(const char *fname);
   static uint32_t GetExportFunction(const char *funcName);
private:
   static ZtaStatus loadSymbols(const char *fname);
   static ZtaStatus programPcore(const char *fname);
   static ZtaStatus programMcore(const char *filename);
private:
};

#endif
#pragma once
