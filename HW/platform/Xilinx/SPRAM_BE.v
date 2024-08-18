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
//----------
//-- This module implements single-port ram with byte-enable for Xilinx
//----------

module SPRAM_BE
   #(parameter
      numwords_a=32,
      widthad_a=32,
      width_a=32
    )
    (
      input [widthad_a-1:0] address_a,
      input [width_a/8-1:0] byteena_a,
      input clock0,
      input [width_a-1:0] data_a,
      input wren_a,
      output [width_a-1:0] q_a
    );


wire [width_a/8-1:0] byteena;

assign byteena = (wren_a==1)?byteena_a:0;

xpm_memory_spram #(
   .ADDR_WIDTH_A(widthad_a), // DECIMAL
   .AUTO_SLEEP_TIME(0), // DECIMAL
   .BYTE_WRITE_WIDTH_A(8), // DECIMAL
   .CASCADE_HEIGHT(0), // DECIMAL
   .ECC_MODE("no_ecc"), // String
   .MEMORY_INIT_FILE("none"), // String
   .MEMORY_INIT_PARAM("0"), // String
   .MEMORY_OPTIMIZATION("true"), // String
   .MEMORY_PRIMITIVE("auto"), // String
   .MEMORY_SIZE(numwords_a*width_a), // DECIMAL
   .MESSAGE_CONTROL(0), // DECIMAL
   .READ_DATA_WIDTH_A(width_a), // DECIMAL
   .READ_LATENCY_A(1), // DECIMAL
   .READ_RESET_VALUE_A("0"), // String
   .RST_MODE_A("SYNC"), // String
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .USE_MEM_INIT(1), // DECIMAL
   .USE_MEM_INIT_MMI(0), // DECIMAL
   .WAKEUP_TIME("disable_sleep"), // String
   .WRITE_DATA_WIDTH_A(width_a), // DECIMAL
   .WRITE_MODE_A("read_first"), // String
   .WRITE_PROTECT(1)    // DECIMAL
)
xpm_memory_spram_inst
(
   .dbiterra(),      // 1-bit output: Status signal to indicate double bit error occurrence
   .douta(q_a),          // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
   .sbiterra(),      // 1-bit output: Status signal to indicate single bit error occurrence
   .addra(address_a),    // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
   .clka(clock0),        // 1-bit input: Clock signal for port A.
   .dina(data_a),        // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   .ena(1),            // 1-bit input: Memory enable signal for port A. Must be high on clock
   .injectdbiterra(0), // 1-bit input: Controls double bit error injection on input data when
                          // ECC enabled (Error injection capability is not available in
                          // "decode_only" mode).
   .injectsbiterra(0), // 1-bit input: Controls single bit error injection on input data when
                          // ECC enabled (Error injection capability is not available in
                          // "decode_only" mode).
   .regcea(1),         // 1-bit input: Clock Enable for the last register stage on the output
                          // data path.
   .rsta(0),           // 1-bit input: Reset signal for the final port A output register
                          // stage. Synchronously resets output port douta to the value specified
                          // by parameter READ_RESET_VALUE_A.
   .sleep(0),          // 1-bit input: sleep signal to enable the dynamic power saving feature.
   .wea(byteena)         // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                          // for port A input data port dina. 1 bit wide when word-wide writes
                          // are used. In byte-wide write configurations, each bit controls the
                          // writing one byte of dina to address addra. For example, to
                          // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                          // is 32, wea would be 4'b0010.
);
 
endmodule
