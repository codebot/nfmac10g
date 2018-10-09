//
// Copyright (c) 2016 University of Cambridge All rights reserved.
//
// Author: Marco Forconesi
//
// This software was developed with the support of
// Prof. Gustavo Sutter and Prof. Sergio Lopez-Buedo and
// University of Cambridge Computer Laboratory NetFPGA team.
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
//`default_nettype none

module rx (

    // Clks and resets
    input                    clk,
    input                    rst,

    // Stats
    output       [31:0]      good_frames,
    output       [31:0]      bad_frames,
    output                   rx_pause_active,

    // Conf vectors
    input        [79:0]      configuration_vector,
    input                    cfg_rx_pause_enable,
    input [7:0]              cfg_sub_quanta_count, // number of clock cycles equivalent to 1 quanta

    // XGMII
    input        [63:0]      xgmii_rxd,
    input        [7:0]       xgmii_rxc,

    // AXIS
    input                    axis_aresetn,
    output       [63:0]      axis_tdata,
    output       [7:0]       axis_tkeep,
    output                   axis_tvalid,
    output                   axis_tlast,
    output       [0:0]       axis_tuser
    );

    //-------------------------------------------------------
    // Local xgmii2axis
    //-------------------------------------------------------
    //wire                     ??;
    wire tuser_i;

    //-------------------------------------------------------
    // Local
    //-------------------------------------------------------
    //wire         [31:0]      ??;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------

    //-------------------------------------------------------
    // xgmii2axis
    //-------------------------------------------------------
    xgmii2axis xgmii2axis_mod (
        .clk(clk),                                             // I
        .rst(rst),                                             // I
        // Stats
        .good_frames(good_frames),                             // O [31:0]
        .bad_frames(bad_frames),                               // O [31:0]
        // Conf vectors
        .configuration_vector(configuration_vector),           // I [79:0]
        // XGMII
        .xgmii_d(xgmii_rxd),                                   // I [63:0]
        .xgmii_c(xgmii_rxc),                                   // I [7:0]
        // AXIS
        .aresetn(axis_aresetn),                                // I
        .tdata(axis_tdata),                                    // O [63:0]
        .tkeep(axis_tkeep),                                    // O [7:0]
        .tvalid(axis_tvalid),                                  // O
        .tlast(axis_tlast),                                    // O
        .tuser(tuser_i)                                     // O [0:0]
        );

    rxpause pause0
      (
       .clk (clk),
       .rst (rst),
       .cfg_rx_pause_enable (cfg_rx_pause_enable),
       .cfg_sub_quanta_count (cfg_sub_quanta_count),
       .aresetn (axis_aresetn),
       .tdata_i(axis_tdata),                                    // O [63:0]
       .tkeep_i(axis_tkeep),                                    // O [7:0]
       .tvalid_i(axis_tvalid),
       .tlast_i(axis_tlast),                                    // O
       .tuser_i(tuser_i),                                     // O [0:0]
       .tuser_o(axis_tuser),
       .rx_pause_active(rx_pause_active)

        );

endmodule // rx

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
