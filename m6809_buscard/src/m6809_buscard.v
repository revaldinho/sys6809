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
               
               output [2:0] tube_adr,
               output       tube_rnw_b,
               output       tube_phi2,
               output       tube_cs_b,
               output       tube_rst_b       
               );	

`define UART 1
`define RETIME_RESET_D 1

   wire                     rnw = wr_b;
   

   
`ifdef RETIME_RESET_D
   reg [1:0]              rst_b_q;
   assign reset_b_w = rst_b_q[0] & reset_b;

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
   reg [7:0]              uart_dout_q;
   reg                    oe_q;

   (* KEEP="TRUE" *) wire clkdel1_w,clkdel2_w, filtered_clk_w;
   
   assign int_b = ( !irq_b_w) ? 1'b0 : 1'bz;
   assign data = ( oe_q & (clk|clkdel1_w|clkdel2_w) ) ? uart_dout_q : 8'bz;
   
   BUF clkdel ( .I(clk), .O(clkdel1_w));
   BUF clkdel1 ( .I(clkdel1_w), .O(clkdel2_w));
   // late rising edge, minimal delay to falling edge
   assign filtered_clk_w = clk & clkdel1_w & clkdel2_w ; 
   
   // Also provide more hold time on outputs but can use FFs for data and
   // control and then gate with the delayed clock
   always @ ( posedge filtered_clk_w) begin
      uart_dout_q = uart_dout_w;
      oe_q = !uart_cs_b & wr_b;
   end
   
   uart uart_0 (
                .RXD(pmod_gpio[0]),
                .TXD(pmod_gpio[1]),
                .CTS_B(pmod_gpio[2]),
                .RTS_B(1'b0),
                .regsel(adr[0]),
                .cs_b( uart_cs_b ),
                .rnw( rnw ),
                .din(data),
                .dout(uart_dout_w),
                .clk(filtered_clk_w),
                .irq_b(irq_b_w),
                .reset_b(reset_b_w)
                ) ;
   
`endif


   
endmodule // m6809_buscard
