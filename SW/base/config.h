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

//--------------------------------------------------------------
//
// ************ IMPORTANT *************************************
//
//
// This file specifies tunable parameters to match
// the FPGA configuration defined in HW/src/config.vhd
// Any changes in hardware configuration from HW/src/config.vhd 
// that also present in file must be applied here as well.
//
//--------------------------------------------------------------

#ifndef _BASE_CONFIG_H_
#define _BASE_CONFIG_H_

//--------------------------------------------------------------
// Max number of pcores
// This must match NUM_PCORE defined in config.vhd
//    4 for small version
//    8 for large version
//--------------------------------------------------------------

#define NUM_PCORE 4  

//#define NUM_PCORE 8  

//---------------------------------------------------------------
// Max tensor size in log2
// Max tensor size = 2**MAX_TENSOR_LOG2_SIZE
// This must match MAX_TENSOR_LOG2_SIZE defined in config.vhd
//---------------------------------------------------------------

#define MAX_TENSOR_LOG2_SIZE  26

//#define MAX_TENSOR_LOG2_SIZE  24 

//---------------------------------------------------------------
// Enable/disable FPU. This option is required to run LLM models
// This must match fpu_enabled_c defined on config.vhd
//----------------------------------------------------------------
 
#define FPU_ENABLED TRUE

#endif
