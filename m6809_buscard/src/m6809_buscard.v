/*
 * Copyright (C) 2022 Revaldinho
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 */

//`define UART 1
//`define RETIME_RESET_D 1

`ifdef UART
`include "uart.vh"
`endif

module m6809_buscard(
               // host
               input        clk,
               input [15:0] adr,
               input        rd_b,
               input        wr_b,
               input        ioreq_b,
               input        mreq_b,
               input        wait_b,
               input        reset_b,
               inout [7:0]  data,
//               inout        int_b,
//               input        busrq_b,
//               input        busack_b,
//               input        ready,
//               input        m1_b,

               // pmod port
               inout [7:0]  pmod_gpio,

               // tube
               input        tube_int_b,

               inout [7:0]  tube_data,
               input        pi_gpio_15, // RX on UART HEADER
               output       pi_gpio_14, // TX on UART HEADER

               output [2:0] tube_adr,
               output       tube_rnw_b,
               output       tube_phi2,
               output       tube_cs_b,
               output       tube_rst_b
               );
  wire                      reset_b_w;
  wire                      rnw = wr_b;

`ifdef RETIME_RESET_D
  reg [1:0]                 rst_b_q;
  assign reset_b_w = rst_b_q[0];

  always @ ( negedge clk or negedge reset_b)
     if ( !reset_b)
       rst_b_q <= 2'b0;
     else
       rst_b_q <= { 1'b1, rst_b_q[1]};
`else
  assign reset_b_w = reset_b;
`endif

`ifdef UART
   wire [7:0]             uart_dout_w;
   wire                   uart_cs_b = !(adr[15] & !adr[14] & adr[13] ); // 0xAxxx
   wire                   irq_b_w;

   (* KEEP="TRUE" *) wire clkdel1_w,clkdel2_w, filtered_clk_w;

   assign int_b = ( !irq_b_w) ? 1'b0 : 1'bz;
   assign data = ( !uart_cs_b & wr_b & (clk|clkdel1_w|clkdel2_w) ) ? uart_dout_w : 8'bz;

   BUF clkdel ( .I(clk), .O(clkdel1_w));
   BUF clkdel1 ( .I(clkdel1_w), .O(clkdel2_w));
   // late rising edge, minimal delay to falling edge
   assign filtered_clk_w = clk & clkdel1_w & clkdel2_w ;

   uart uart_0 (
                .RXD(pi_gpio_15),
                .TXD(pi_gpio_14),
                .RTS_B(pmod_gpio[0]),
                .CTS_B(1'b0),
                .regsel(adr[0]),
                .cs_b( uart_cs_b ),
                .rnw( rnw ),
                .din(data),
`ifdef ERROR_FLAGS
                .frame_error(pmod_gpio[1]),
                .overrun(pmod_gpio[2]),
`endif
                .dout(uart_dout_w),
                .clk(filtered_clk_w),
                .irq_b(irq_b_w),
                .reset_b(reset_b_w)
                ) ;

`else // !`ifdef UART
  // Simple test

  BUF clkdel ( .I(clk), .O(clkdel1_w));
  BUF clkdel1 ( .I(clkdel1_w), .O(clkdel2_w));
  // late rising edge, minimal delay to falling edge
  assign filtered_clk_w = clk & clkdel1_w & clkdel2_w ;


  reg                     clk2;
  always @ ( negedge clk)
    clk2<= !clk2;

  assign pi_gpio_14 = filtered_clk_w;
  assign pmod_gpio[0] = clk2;
  assign pmod_gpio[1] = clk;

`endif



endmodule // m6809_buscard
