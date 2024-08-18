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

// Implement latch
// This latch is used in a synchronous manner so it is safe
// Input signal is guaranteed to be stable during the level transision
// The latch is mainly used to overclock the memory block to improve memory utiization
// This code should be portable among different synthesis. It is part of the
// platform package because GHDL has trouble with converting latch construct from
// VHDL to verilog
//
module SYNC_LATCH #(parameter DATA_WIDTH=32)
   (
      input enable_in,
      input [DATA_WIDTH-1:0] data_in,
      output [DATA_WIDTH-1:0] data_out
   );

reg [DATA_WIDTH-1:0] data_r;

assign data_out = data_r;

always @(enable_in or data_in) begin
   if(enable_in)
      data_r <= data_in;
end

endmodule
