// RX Specific sizing for slow clock
`define RXTICKSPERBIT    16
`define RXTICKSPERBITBY2 (`RXTICKSPERBIT>>1)
`define RXTICKCTRSZ      4 // to be large enough to count to RXTICKSPERBIT-1

// State Machine Codes
`define RXIDLE  2'b00
`define RXSTART 2'b01
`define RXBIT   2'b11
`define RXSTOP  2'b10

`define RXWORDSZ    8
`define RXWORDCTRSZ 3

`include "uart.vh"

module uartrx(
	      input        serin,
	      output [7:0] host_dout,
	      input        clk,
	      input        reset_b,
	      input        host_rd,
	      output       host_dor,
              output       frame_error,
              output       overrun
	    );

  reg [1:0] state_d, state_q;
  reg [`RXTICKCTRSZ-1:0] ctr_d, ctr_q;
  reg [`RXWORDSZ-1:0] rxbyte_d, rxbyte_q;
  reg [`RXWORDCTRSZ-1:0] bit_idx_d, bit_idx_q;
  reg [1:0] sin_q;

  wire falling_w = sin_q[0] & !sin_q[1];

  wire fifo_dir_w;
  reg we_d, we_q;

`ifdef ERROR_FLAGS
  reg frame_error_d, frame_error_q;
  reg overrun_d, overrun_q;
  assign overrun = overrun_q;
  assign frame_error = frame_error_q;
`else
  assign overrun = 1'b0;
  assign frame_error = 1'b0;
`endif

  rxfifo rxfifo_0 (
		   .din(rxbyte_q),
		   .we(we_q),
		   .host_rd(host_rd),
		   .host_dout(host_dout),
		   .host_dor(host_dor),
		   .dir(fifo_dir_w),
		   .clk(clk),
		   .reset_b(reset_b)
		   );

  always @ (* ) begin
    we_d = 1'b0;
    state_d = state_q;
    ctr_d = ctr_q + 1;
    rxbyte_d = rxbyte_q;
    bit_idx_d = bit_idx_q;
`ifdef ERROR_FLAGS
    overrun_d = overrun_q;
    frame_error_d = frame_error_q;
`endif

    case (state_q)
      `RXIDLE: begin
	if ( falling_w ) begin
          state_d = `RXSTART ;
	  ctr_d = 0;
        end
      end
      `RXSTART : begin
        // Reset state machine if start bit is 1 !
        //	 if ( ctr_q == `RXTICKSPERBITBY2-1 && sin_q[0]) begin
        //	    state_d = `RXIDLE;
        //         end
	if (ctr_q == `RXTICKSPERBIT-1) begin
`ifdef ERROR_FLAGS
          frame_error_d = 0;
          overrun_d = 0;
`endif
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
`ifdef ERROR_FLAGS
	if (ctr_q == `RXTICKSPERBITBY2-1 ) begin
          frame_error_d = !sin_q[0]; // Frame error if stop bit is zero
        end
`endif
        if (ctr_q == `RXTICKSPERBIT-1) begin
	  // Write the received byte to the FIFO if space available
          // otherwise it will be dropped and an overrun error signalled
	  we_d = fifo_dir_w;
`ifdef ERROR_FLAGS
          overrun_d = !fifo_dir_w;
`endif
	  state_d = `RXIDLE;
        end
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
      ctr_q <= ctr_d;
    end
  end

`ifdef ERROR_FLAGS
  always @ (negedge clk or negedge reset_b ) begin
    if ( ! reset_b ) begin
      {frame_error_q, overrun_q } <= 0;
    end
    else begin
      frame_error_q <= frame_error_d;
      overrun_q <= overrun_d;
    end
  end
`endif //  `ifdef ERROR_FLAGS

endmodule
