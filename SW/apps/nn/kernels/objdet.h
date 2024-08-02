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

#ifndef _APPS_NN_KERNELS_FCN_H_
#define _APPS_NN_KERNELS_FCN_H_
#ifdef __cplusplus
extern "C" {
#endif

// Each box will have a list of classes 
// Each box is assigned to a thread
// Number of classes that can be held by a thread at one time
#define CLASS_PER_THREAD 8

// Result is 2 words per box
// First word is the max score
// Second word is the class with highest score
#define RESULT_MAX_SCORE  0
#define RESULT_CLASS      1

extern void kernel_objdet_exe(
    unsigned int _req_id,
    unsigned int _score,
    unsigned int _score_result,
    unsigned int _class_result,
    int _numBoxes,
    int _numClasses
);

#ifdef __cplusplus
}
#endif
#endif
