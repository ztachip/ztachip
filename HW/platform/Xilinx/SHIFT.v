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

// Implement various shift operation
// Shift operation can be in logical mode or arithmetic mode
// The difference between arithmetic and logical mode is that in arithmetic
// mode, the sign bit is maintained after a right shift
// This should be portable among different synthesis. The reason that the 
// shift operation is in the platform package is because ghdl cannot convert
// VHDL shift operation to verilog version


// Implement left shift in arithmetic mode
// For shift left, arithmetic and logic mode are the same, after the shift
// the LSB is set to zero
//
module SHIFT_LEFT_A #(parameter DIST_WIDTH=32,DATA_WIDTH=4)
   (
      input signed [DATA_WIDTH-1:0] data_in,
      input unsigned [DIST_WIDTH-1:0] distance_in,
      output signed [DATA_WIDTH-1:0] data_out
   );

assign data_out=(data_in <<< distance_in); 

endmodule

// Implement left shift in logical mode
// For shift left, arithmetic and logic mode are the same, after the shift
// the LSB is set to zero
//
module SHIFT_LEFT_L #(parameter DIST_WIDTH=32,DATA_WIDTH=4)
   (
      input [DATA_WIDTH-1:0] data_in,
      input unsigned [DIST_WIDTH-1:0] distance_in,
      output [DATA_WIDTH-1:0] data_out
   );

assign data_out=(data_in << distance_in); 

endmodule

//
// Implement right shift in arithmetic mode
// In arithmetic mode, MSB is set with sign bit extension
//
module SHIFT_RIGHT_A #(parameter DIST_WIDTH=32,DATA_WIDTH=4)
   (
      input signed [DATA_WIDTH-1:0] data_in,
      input unsigned [DIST_WIDTH-1:0] distance_in,
      output signed [DATA_WIDTH-1:0] data_out
   );

assign data_out=(data_in >>> distance_in); 

endmodule

//
// Implement right shift in logical mode
// In logical mode, MSB is set to zero
//
module SHIFT_RIGHT_L #(parameter DIST_WIDTH=32,DATA_WIDTH=4)
   (
      input [DATA_WIDTH-1:0] data_in,
      input unsigned [DIST_WIDTH-1:0] distance_in,
      output [DATA_WIDTH-1:0] data_out
   );

assign data_out=(data_in >> distance_in); 

endmodule
