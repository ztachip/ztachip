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
//-- This module implements simple dual-port ram for Xilinx
//----------

module DPRAM_DUAL_CLOCK 
    #(parameter 
        numwords_a=32,
        numwords_b=32,
        widthad_a=32,
        widthad_b=32,
        width_a=32,
        width_b=32
    )
    (
        input [widthad_a-1:0] address_a,
        input clock_a,
        input clock_b,
        input [width_a-1:0] data_a,
        output [width_b-1:0] q_b,
        input wren_a,
        input [widthad_b-1:0] address_b
    );

wire [0:0] byteena_a;

assign byteena_a[0] = wren_a;

xpm_memory_dpdistram #(
    .ADDR_WIDTH_A(widthad_a), // DECIMAL
    .ADDR_WIDTH_B(widthad_b), // DECIMAL
    .BYTE_WRITE_WIDTH_A(width_a), // DECIMAL
    .CLOCKING_MODE("independent_clock"), // String
    .MEMORY_INIT_FILE("none"), // String
    .MEMORY_INIT_PARAM("0"), // String
    .MEMORY_OPTIMIZATION("true"), // String
    .MEMORY_SIZE(numwords_a*width_a), // DECIMAL
    .MESSAGE_CONTROL(0), // DECIMAL
    .READ_DATA_WIDTH_A(width_b), // DECIMAL
    .READ_DATA_WIDTH_B(width_b), // DECIMAL
    .READ_LATENCY_B(1), // DECIMAL
    .READ_RESET_VALUE_B("0"), // String
    .RST_MODE_A("SYNC"), // String
    .RST_MODE_B("SYNC"), // String
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .USE_EMBEDDED_CONSTRAINT(1), // DECIMAL
    .USE_MEM_INIT(1), // DECIMAL
    .USE_MEM_INIT_MMI(0), // DECIMAL
    .WRITE_DATA_WIDTH_A(width_a)
) xpm_memory_sdpram_inst
(
    .doutb(q_b),         // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
    .addra(address_a),   // ADDR_WIDTH_A-bit input: Address for port A write operations.
    .addrb(address_b),   // ADDR_WIDTH_B-bit input: Address for port B read operations.
    .clka(clock_a),      // 1-bit input: Clock signal for port A. Also clocks port B when
    .clkb(clock_b),      // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                        // "independent_clock". Unused when parameter CLOCKING_MODE is
                          // "common_clock".
    .dina(data_a),       // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
    .ena(wren_a),        // 1-bit input: Memory enable signal for port A. Must be high on clock
    .enb(1),           // 1-bit input: Memory enable signal for port B. Must be high on clock
    .regceb(1),         // 1-bit input: Clock Enable for the last register stage on the output
                           // data path.
    .rsta(0),           // 1-bit input: Reset signal for the final port B output register

    .rstb(0),           // 1-bit input: Reset signal for the final port B output register
                           // stage. Synchronously resets output port doutb to the value specified
                           // by parameter READ_RESET_VALUE_B.
    .wea(byteena_a),      // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                           // for port A input data port dina. 1 bit wide when word-wide writes
                           // are used. In byte-wide write configurations, each bit controls the
                           // writing one byte of dina to address addra. For example, to
                           // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                           // is 32, wea would be 4'b0010.
    .regcea(1)
);

endmodule
