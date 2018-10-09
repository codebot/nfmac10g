//
// Copyright (c) 2018 Dryv.io, Inc. All rights reserved.
//
// Author: Guy Hutchison
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more
// contributor license agreements.  See the NOTICE file distributed with this
// work for additional information regarding copyright ownership.  NetFPGA
// licenses this file to you under the NetFPGA Hardware-Software License,
// Version 1.0 (the "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module rxpause (

    // Clks and resets
    input                    clk,
    input                    rst,

    // Conf vectors
    input                    rx_pause_enable,

    // AXIS Input
    input                    aresetn,
    input   [63:0]      tdata_i,
    input   [7:0]       tkeep_i,
    input               tvalid_i,
    input               tlast_i,
    input   [0:0]       tuser_i,  // 1 indicates good CRC, 0 bad CRC

    output reg   [0:0]       tuser_o,

    input       cfg_rx_pause_enable,
    input [7:0] cfg_sub_quanta_count, // number of clock cycles equivalent to 1 quanta
                                  // at 156.25Mhz this should be 8
    output      rx_pause_active         // stop TX transmission

    );

  localparam PAUSE_OPCODE = 16'h0001;

  localparam s_idle = 0, s_control_1 = 2, s_normal = 1, s_control_2 = 3, s_control_3 = 4;

  reg [2:0] state, nxt_state;
  reg [15:0] opcode, nxt_opcode;
  reg [15:0] quanta, nxt_quanta;
  reg [15:0] pause_count, nxt_pause_count;
  reg [7:0] sub_count, nxt_sub_count;
  reg new_quanta;
  reg nxt_tuser_o;

  wire [47:0] control_da = { 8'h01, 8'h00, 8'h00, 8'hC2, 8'h80, 8'h01 };
  wire [15:0] control_et = { 8'h08, 8'h88 };

  assign rx_pause_active = (pause_count > 0);

  // tuser_o used to drop pause frames by forcing bad CRC

  always @*
    begin
      nxt_state = state;
      tuser_o = tuser_i;
      nxt_opcode = opcode;
      new_quanta = 1'b0;
      nxt_pause_count = pause_count;
      nxt_sub_count = sub_count;

      // count down pause counter until zero, link is paused when
      // count > 0.  nxt_pause_count can be overriden later to set
      // new quanta.
      if ((pause_count > 0) && cfg_rx_pause_enable) begin
        if (sub_count == (cfg_sub_quanta_count-1)) begin
          nxt_sub_count = 0;
          nxt_pause_count = pause_count - 1;
        end
        else begin
          nxt_sub_count = sub_count + 1;
        end
      end
      else begin
        nxt_pause_count = pause_count;
        nxt_sub_count = 0;
      end

      case (state)
        // look for control frame MAC DA
        s_idle : begin
          if (tvalid_i) begin
            if (tdata_i[47:0] == control_da) begin
              nxt_state = s_control_1;
            end
            else begin
              nxt_state = s_normal;
            end
          end
        end

        // look for control frame MAC ET
        s_control_1 : begin
          if (tvalid_i) begin
            if (tdata_i[47:32] == control_et) begin
              nxt_opcode = {tdata_i[55:48], tdata_i[63:56]};
              nxt_state = s_control_2;
            end
            else begin
              nxt_state = s_normal;
            end
          end
        end

        // check that control opcode is for pause frame, if so
        // wait for EOP to apply
        s_control_2 : begin
          if (tvalid_i) begin 
            if (opcode == PAUSE_OPCODE) begin
              nxt_quanta = { tdata_i[7:0], tdata_i[15:8]};
              nxt_state = s_control_3;
            end
            else begin
              nxt_state = s_normal;
            end
          end
        end

        // wait for EOP to check for valid CRC at the end of the frame
        // if frame is valid, load new quanta into pause counter
        s_control_3 : begin
          if (tvalid_i && tlast_i) begin
            nxt_tuser_o = 1'b0;
            nxt_state = s_idle;
            if (tuser_i) begin
              nxt_pause_count = quanta;
            end
          end
        end

        // wait for EOP on non-pause packets
        s_normal : begin
          if (tvalid_i && tlast_i)
            nxt_state = s_idle;
        end
      endcase
    end

  always @(posedge clk)
    begin
      if (rst)
        begin
          pause_count <= 0;
          sub_count <= 0;
          state <= s_idle;
          opcode <= 16'h0;
          quanta <= 16'h0;
        end
      else
        begin
          pause_count <= nxt_pause_count;
          sub_count <= nxt_sub_count;
          state <= nxt_state;
          opcode <= nxt_opcode;
          quanta <= nxt_quanta;
        end
    end

endmodule // xgmii2axis

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
