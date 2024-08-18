//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//----------------------------------------------------------------------------
//---
//-- Synchronize a signal accross different clock domain
//---

module CCD_SYNC #(parameter WIDTH=1)
   (
      input reset_in,
      input inclock_in,
      input outclock_in,
      input [WIDTH-1:0] input_in,
      output [WIDTH-1:0] output_out
   );

xpm_cdc_array_single #(
      .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(WIDTH)       // DECIMAL; range: 1-1024
   )
xpm_cdc_array_single_inst
   (
      .dest_out(output_out), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                           // output is registered.
      .dest_clk(outclock_in), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(inclock_in),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(input_in)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                              // domain. It is assumed that each bit of the array is unrelated to the others.
                              // This is reflected in the constraints applied to this macro. To transfer a binary
                              // value losslessly across the two clock domains, use the XPM_CDC_GRAY macro
                              // instead.
   );

endmodule