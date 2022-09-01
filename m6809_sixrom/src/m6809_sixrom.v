/*
 * This code is part of the sys6809 set of peripherals.
 * 
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
 */

/*
 * DIP switches are numbered 1-8 on the board, but 0-7 in the Verilog code
 *
 * Only one slot can be enabled
 *
 * DIP 0 = LSB \
 * DIP 1 =      > 2 bit ROM select 0..5 - setting 6 or 7 selects slot 0 
 * DIP 2 = MSB /
 * DIP 3 = unused
 * DIP 4 = unused
 * DIP 5 = unused
 * DIP 6 = unused
 * DIP 7 = unused
 */

module m6809_sixrom (
    input [7:0] dip,
    input reset_b,     // unused
    input adr15,         
    input adr14,         
    input adr13, // unused
    input ioreq_b, // unused
    input mreq_b, // unused
    input romen_b, // unused
    input wr_b, // now rnw
    input rd_b, // unused
    input [7:0] data,  
    input clk,         // unused
    output romdis,     // drive low (via diode) to free pin externally
    output rom01cs_b,
    output rom23cs_b, 
    output rom45cs_b,  
    output roma14,
    output romoe_b 
    );

   reg [5:0] rom16k_cs_r ;

   assign romdis    = 1'b0 ; // unused but allow other h/w to use the pin 
   assign rom01cs_b = !(rom16k_cs_r[0] | rom16k_cs_r[1]) ;
   assign rom23cs_b = !(rom16k_cs_r[2] | rom16k_cs_r[3]) ;
   assign rom45cs_b = !(rom16k_cs_r[4] | rom16k_cs_r[5]) ;  
   assign roma14    =  dip[0]; // odd numbered slots set A14
   assign romoe_b   = !wr_b;  // wr_b is now rnw on the 6809
   
   
   always @ ( * ) 
     begin
        rom16k_cs_r = 6'b0;   
        if (adr15 & adr14) // ROM space at 0xC000-0xFFFF
          case  ( {dip[2],dip[1],dip[0]} )
            3'h0: rom16k_cs_r[0] = 1'b1 ;
            3'h1: rom16k_cs_r[1] = 1'b1 ;
            3'h2: rom16k_cs_r[2] = 1'b1 ;
            3'h3: rom16k_cs_r[3] = 1'b1 ;
            3'h4: rom16k_cs_r[4] = 1'b1 ;
            3'h5: rom16k_cs_r[5] = 1'b1 ;
            3'h6: rom16k_cs_r[0] = 1'b1 ;
            3'h7: rom16k_cs_r[0] = 1'b1 ;  
          endcase
     end //always @ ( * )
   
endmodule // romc

