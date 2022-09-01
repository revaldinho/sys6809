// RX Specific sizing for slow clock
`define RXTICKSPERBIT    16
`define RXTICKSPERBITBY2 (`RXTICKSPERBIT>>1)
`define RXTICKCTRSZ      4 // to be large enough to count to RXTICKSPERBIT-1

// State Machine Codes
`define RXIDLE  3'b000
`define RXSTART 3'b001
`define RXBIT   3'b010
`define RXSTOP  3'b011
`define RXEND   3'b100

`define RXWORDSZ    8
`define RXWORDCTRSZ 3

module uartrx(
	      input        serin,
	      output [7:0] host_dout,
	      input        clk,
	      input        reset_b,
	      input        host_rd,
	      output       host_dor,
	      output       cts
	    );

  reg [2:0] state_d, state_q;
  reg [`RXTICKCTRSZ-1:0] ctr_d, ctr_q;
  reg [`RXWORDSZ-1:0] rxbyte_d, rxbyte_q;
  reg [`RXWORDCTRSZ-1:0] bit_idx_d, bit_idx_q;
  reg [1:0] sin_q;

  wire falling_w = sin_q[0] & !sin_q[1];

  wire fifo_dir_w;
  wire fifo_empty;
  reg we_d, we_q;

  assign cts = fifo_empty;

  rxfifo rxfifo_0 (
		   .din(rxbyte_q),
		   .we(we_q),
		   .host_rd(host_rd),
		   .host_dout(host_dout),
		   .host_dor(host_dor),
		   .dir(fifo_dir_w),
		   .empty(fifo_empty),
		   .clk(clk),
		   .reset_b(reset_b)
		   );

  always @ (* ) begin
    we_d = 1'b0;
    state_d = state_q;
    ctr_d = ctr_q + 1;
    rxbyte_d = rxbyte_q;
    bit_idx_d = bit_idx_q;

    case (state_q)
      `RXIDLE: begin
	ctr_d = 0;
	if ( falling_w ) state_d = `RXSTART ;
      end
      `RXSTART : begin
         // Reset state machine if start bit is 1 !
	 if ( ctr_q == `RXTICKSPERBITBY2-1 && sin_q[0]) begin
	    state_d = `RXIDLE;
         end
         
	 if (ctr_q == `RXTICKSPERBIT-1) begin
	    bit_idx_d = 0;
	    ctr_d = 0;
	    state_d = `RXBIT;
	 end
      end
      `RXBIT : begin
	if (ctr_q == `RXTICKSPERBITBY2-1 )
	  // bits arrive LSB first
	  rxbyte_d = { sin_q[0], rxbyte_q[7:1]} ;
	else if ( ctr_q == `RXTICKSPERBIT-1 ) begin
	  ctr_d = 0;
	  bit_idx_d = bit_idx_d+1;
	  if (bit_idx_q == `RXWORDSZ-1)
	    state_d = `RXSTOP;
	end
      end
      `RXSTOP : begin
         if (ctr_q == `RXTICKSPERBIT-1)
	   state_d = `RXEND;
      end
      `RXEND : begin
	 // Write the received byte to the FIFO
	 if ( fifo_dir_w ) begin
	    we_d = 1'b1;
	    state_d = `RXIDLE;
	 end
      end
      default: begin
	 state_d = `RXIDLE;
      end
    endcase
  end
   
   always @ ( negedge clk or negedge reset_b ) begin
      if ( ! reset_b ) begin
         { sin_q, bit_idx_q, rxbyte_q, we_q} <= 0;
         state_q <= `RXIDLE;
      end
      else begin
         state_q <= state_d;
         bit_idx_q <= bit_idx_d;
         sin_q <= { serin, sin_q[1]};
         rxbyte_q <= rxbyte_d;
         we_q <= we_d;         
      end
   end
   
   always @ (negedge clk) begin   
      ctr_q <= ctr_d;
   end

endmodule
