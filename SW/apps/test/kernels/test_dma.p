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

#include "../../../base/zta.h"

vint16 test_dma_1::x;
vint16 test_dma_1::y;

_kernel_ void test_dma_1::exe() 
{
   _VMASK=-1;
   y = x+1;
}

vint16 test_dma_2::x;
vint16 test_dma_2::y;

_kernel_ void test_dma_2::exe() 
{
   _VMASK=-1;
   y = x+1;
}

vint16 test_dma_3::x;
vint16 test_dma_3::y;

_kernel_ void test_dma_3::exe() 
{
   _VMASK=-1;
   y = x+1;
}