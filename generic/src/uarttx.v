`include "uart.vh"

// TX Specific sizing for slow clock
`define TXTICKSPERBIT    16
`define TXTICKSPERBITBY2 (`TXTICKSPERBIT>>1)

`ifdef TWO_STOP_BITS
  `define TXTICKSPERSTOPBIT    `TXTICKSPERBIT*2
  `define TXTICKCTRSZ          5 // to be large enough to count to TXTICKSPERBIT-1
`else
  `define TXTICKSPERSTOPBIT    `TXTICKSPERBIT
  `define TXTICKCTRSZ          4 // to be large enough to count to TXTICKSPERBIT-1
`endif
`define TXIDLE  2'b00
`define TXSTART 2'b01
`define TXBIT   2'b11
`define TXSTOP  2'b10

`define TXWORDSZ    8
`define TXWORDCTRSZ 3

module uarttx(
	      input [7:0] din,
	      input       host_wr,
	      output      serout,
	      output      host_dir,
	      input       clk,
	      input       reset_b
	      );

  reg [1:0] state_d, state_q;
  reg [`TXTICKCTRSZ-1:0] ctr_d, ctr_q;
  reg [`TXWORDSZ-1:0] txword_d, txword_q;
  reg [`TXWORDCTRSZ-1:0] bit_ctr_d, bit_ctr_q;
  reg                    serout_r;

  assign host_dir = (state_q == `TXIDLE ) ;
  assign serout = serout_r;

  always @ ( * ) begin
    ctr_d = ctr_q + 1;
    txword_d = txword_q;
    bit_ctr_d = bit_ctr_q;
    state_d = state_q;
    serout_r = 1'b1;

    case ( state_q )
      `TXIDLE: begin
	if ( host_wr ) begin
	  txword_d = din ;
	  state_d = `TXSTART;
	  ctr_d = 0;
	end
      end
      `TXSTART: begin
	serout_r = 1'b0;
	if ( ctr_q == `TXTICKSPERBIT-1 ) begin
	  ctr_d = 0;
          bit_ctr_d = 0;
	  state_d = `TXBIT;
	end
      end
      `TXBIT: begin
	serout_r = txword_q[0];
	if ( ctr_q == `TXTICKSPERBIT-1 ) begin
	  ctr_d = 0;
	  txword_d = { 1'b1, txword_q[`TXWORDSZ-1:1]};
	  bit_ctr_d = bit_ctr_d+1;
	  if (bit_ctr_q == `TXWORDSZ-1 ) begin
	    state_d = `TXSTOP;
	  end
	end
      end
      `TXSTOP: begin
	serout_r = 1'b1;
	if ( ctr_q == `TXTICKSPERSTOPBIT-1 ) begin
	  state_d = `TXIDLE;
	end
      end
    endcase
  end

   always @ ( negedge clk) begin
      ctr_q <= ctr_d;
   end


  always @ ( negedge clk or negedge reset_b ) begin
    if ( ! reset_b ) begin
      state_q <= `TXIDLE ;
      bit_ctr_q <= 0;
      txword_q <= {`TXWORDSZ{1'b1}} ;
    end
    else begin
      txword_q <= txword_d;
      state_q <= state_d;
      bit_ctr_q <= bit_ctr_d;
    end
  end

endmodule
