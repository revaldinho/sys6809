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

`define RAM_CTRL 1
`define UART 1
//`define RETIME_RESET_D 1

`ifdef UART
`include "uart.vh"
`endif

module cpld_ram1m_plcc84(
                         input        rfsh_b,
                         input        adr15_aux, // unused
                         input [15:0] adr,
                         input        ioreq_b,
                         input        mreq_b,
                         input        reset_b,
                         input        busreset_b,
                         input        busack_b,
                         input        wr_b, // now rnw on 6809
                         input        rd_b,
                         input        m1_b,
                         inout [7:0]  data,
                         input        clk,
                         input [3:0]  dip,
                         input        ramrd_b,
                         input        romen_b,

                         inout        ramdis,
                         inout        int_b,
                         inout        nmi_b,
                         inout        ready,
                         inout [7:0]  gpio,
                         inout        romdis,
                         inout [4:0]  ramadrhi, // bits 4,3 also connected to DIP switches 2,1 resp and read on startup

                         inout [4:0]  tp,
                         output       ramcs0_b,
                         output       ramcs1_b,
                         output       busreq_b,
                         output       ramoe_b,
                         output       ramwe_b
                         );


   wire                               reset_b_w;
   wire                               rnw = wr_b;


`ifdef RAM_CTRL
   assign ramadrhi = {3'b000,adr[14] } ; // Use only bottom 32K of bank 0
   assign ramcs1_b = 1'b1 ; // second RAM unused
   assign ramcs0_b = adr[15]; // RAM only at low 32K
   assign ramwe_b = wr_b | !clk ;  // wr_b is rnw signal valid only with E=1
   assign ramoe_b = !(wr_b); // wr_b is rnw signal
`endif


`ifdef RETIME_RESET_D
   reg [1:0]              rst_b_q;
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
//   reg                    oe_q;

   (* KEEP="TRUE" *) wire clkdel1_w,clkdel2_w, filtered_clk_w;

   assign int_b = ( !irq_b_w) ? 1'b0 : 1'bz;
   assign data = ( !uart_cs_b & wr_b & (clk|clkdel1_w|clkdel2_w) ) ? uart_dout_w : 8'bz;

   BUF clkdel ( .I(clk), .O(clkdel1_w));
   BUF clkdel1 ( .I(clkdel1_w), .O(clkdel2_w));
   // late rising edge, minimal delay to falling edge
   assign filtered_clk_w = clk & clkdel1_w & clkdel2_w ;

   uart uart_0 (
                .RXD(tp[0]),
                .TXD(tp[1]),
                .RTS_B(tp[2]),
                .CTS_B(1'b0),
                .regsel(adr[0]),
                .cs_b( uart_cs_b ),
                .rnw( rnw ),
                .din(data),
                .dout(uart_dout_w),
`ifdef ERROR_FLAGS
                .frame_error(tp[3]),
                .overrun(tp[4]),
`endif
                .clk(filtered_clk_w),
                .irq_b(irq_b_w),
                .reset_b(reset_b_w)
                ) ;

`endif

endmodule
