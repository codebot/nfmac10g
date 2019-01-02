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

module tx 
  (
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                axis_aresetn,           // To padding_ctrl_mod of padding_ctrl.v
   input [63:0]         axis_tdata,             // To padding_ctrl_mod of padding_ctrl.v
   input [7:0]          axis_tkeep,             // To padding_ctrl_mod of padding_ctrl.v
   input                axis_tlast,             // To padding_ctrl_mod of padding_ctrl.v
   input [0:0]          axis_tuser,             // To padding_ctrl_mod of padding_ctrl.v
   input                axis_tvalid,            // To padding_ctrl_mod of padding_ctrl.v
   input                carrier_sense,          // To padding_ctrl_mod of padding_ctrl.v
   input                cfg_rx_pause_enable,    // To padding_ctrl_mod of padding_ctrl.v
   input [47:0]         cfg_station_macaddr,    // To padding_ctrl_mod of padding_ctrl.v
   input [15:0]         cfg_tx_pause_refresh,   // To padding_ctrl_mod of padding_ctrl.v
   input                clk,                    // To padding_ctrl_mod of padding_ctrl.v, ...
   input [79:0]         configuration_vector,   // To axis2xgmii_mod of axis2xgmii.v
   input                rst,                    // To padding_ctrl_mod of padding_ctrl.v, ...
   input                rx_pause_active,        // To padding_ctrl_mod of padding_ctrl.v
   input                tx_pause_send,          // To padding_ctrl_mod of padding_ctrl.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               axis_tready,            // From padding_ctrl_mod of padding_ctrl.v
   output               tx_statistics_valid,    // From axis2xgmii_mod of axis2xgmii.v
   output [25:0]        tx_statistics_vector,   // From axis2xgmii_mod of axis2xgmii.v
   output [7:0]         xgmii_txc,              // From axis2xgmii_mod of axis2xgmii.v
   output [63:0]        xgmii_txd              // From axis2xgmii_mod of axis2xgmii.v
   // End of automatics
   );

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [1:0]            dic;                    // From axis2xgmii_mod of axis2xgmii.v
  wire                  lane4_start;            // From axis2xgmii_mod of axis2xgmii.v
  wire [63:0]           m_axis_tdata;           // From padding_ctrl_mod of padding_ctrl.v
  wire [7:0]            m_axis_tkeep;           // From padding_ctrl_mod of padding_ctrl.v
  wire                  m_axis_tlast;           // From padding_ctrl_mod of padding_ctrl.v
  wire                  m_axis_tready;          // From axis2xgmii_mod of axis2xgmii.v
  wire [0:0]            m_axis_tuser;           // From padding_ctrl_mod of padding_ctrl.v
  wire                  m_axis_tvalid;          // From padding_ctrl_mod of padding_ctrl.v
  // End of automatics

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------
/* -----\/----- EXCLUDED -----\/-----
    assign s_axis_tdata = axis_tdata;
    assign s_axis_tkeep = axis_tkeep;
    assign s_axis_tvalid = axis_tvalid;
    assign axis_tready = s_axis_tready;
    assign s_axis_tlast = axis_tlast;
    assign s_axis_tuser = axis_tuser;
 -----/\----- EXCLUDED -----/\----- */

    //-------------------------------------------------------
    // padding_ctrl
    //-------------------------------------------------------
  /* padding_ctrl AUTO_TEMPLATE
   (
    .aresetn(axis_aresetn),                                // I
    .s_axis_tdata (axis_tdata[]),
    .s_axis_tkeep (axis_tkeep[]),
    .s_axis_tvalid (axis_tvalid),
    .s_axis_tready (axis_tready),
    .s_axis_tlast (axis_tlast),
    .s_axis_tuser (axis_tuser[]),
   );
   */
  padding_ctrl 
    padding_ctrl_mod 
      (/*AUTOINST*/
       // Outputs
       .s_axis_tready                   (axis_tready),           // Templated
       .m_axis_tdata                    (m_axis_tdata[63:0]),
       .m_axis_tkeep                    (m_axis_tkeep[7:0]),
       .m_axis_tvalid                   (m_axis_tvalid),
       .m_axis_tlast                    (m_axis_tlast),
       .m_axis_tuser                    (m_axis_tuser[0:0]),
       // Inputs
       .clk                             (clk),
       .rst                             (rst),
       .aresetn                         (axis_aresetn),          // Templated
       .s_axis_tdata                    (axis_tdata[63:0]),      // Templated
       .s_axis_tkeep                    (axis_tkeep[7:0]),       // Templated
       .s_axis_tvalid                   (axis_tvalid),           // Templated
       .s_axis_tlast                    (axis_tlast),            // Templated
       .s_axis_tuser                    (axis_tuser[0:0]),       // Templated
       .m_axis_tready                   (m_axis_tready),
       .lane4_start                     (lane4_start),
       .dic                             (dic[1:0]),
       .carrier_sense                   (carrier_sense),
       .rx_pause_active                 (rx_pause_active),
       .tx_pause_send                   (tx_pause_send),
       .cfg_rx_pause_enable             (cfg_rx_pause_enable),
       .cfg_tx_pause_refresh            (cfg_tx_pause_refresh[15:0]),
       .cfg_station_macaddr             (cfg_station_macaddr[47:0]));

    //-------------------------------------------------------
    // axis2xgmii
    //-------------------------------------------------------
  /* axis2xgmii AUTO_TEMPLATE
   (
        .dic_o(dic[]),                                           // O [1:0]
        .xgmii_d(xgmii_txd[]),                                   // O [63:0]
        .xgmii_c(xgmii_txc[]),                                   // O [7:0]
        .tdata(m_axis_tdata[]),                                  // I [63:0]
        .tkeep(m_axis_tkeep[]),                                  // I [7:0]
        .tvalid(m_axis_tvalid),                                // I
        .tready(m_axis_tready),                                // O
        .tlast(m_axis_tlast),                                  // I
        .tuser(m_axis_tuser[]),                                   // I [0:0]
    .good_frames(),
    .bad_frames(),
   );
   */
  axis2xgmii 
    axis2xgmii_mod 
      (/*AUTOINST*/
       // Outputs
       .good_frames                     (),                      // Templated
       .bad_frames                      (),                      // Templated
       .tx_statistics_vector            (tx_statistics_vector[25:0]),
       .tx_statistics_valid             (tx_statistics_valid),
       .lane4_start                     (lane4_start),
       .dic_o                           (dic[1:0]),              // Templated
       .xgmii_d                         (xgmii_txd[63:0]),       // Templated
       .xgmii_c                         (xgmii_txc[7:0]),        // Templated
       .tready                          (m_axis_tready),         // Templated
       // Inputs
       .clk                             (clk),
       .rst                             (rst),
       .configuration_vector            (configuration_vector[79:0]),
       .tdata                           (m_axis_tdata[63:0]),    // Templated
       .tkeep                           (m_axis_tkeep[7:0]),     // Templated
       .tvalid                          (m_axis_tvalid),         // Templated
       .tlast                           (m_axis_tlast),          // Templated
       .tuser                           (m_axis_tuser[0:0]));     // Templated

endmodule // tx

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
