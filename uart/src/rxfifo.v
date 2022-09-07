// FIFOSZ must be >=2
// total buffer size = FIFOSZ +1, inc. the shift register input buffer
`define FIFOSZ      2
`define FIFOPTRSZ   1   // roundup(log2(FIFOSZ))

module rxfifo
   (
    input [7:0]  din,
    input        we,
    input        host_rd,
    output [7:0] host_dout,
    output       host_dor,
    output       dir,
    input        clk,
    input        reset_b
    );


   reg [7:0]     buffer_q [`FIFOSZ-1:0];
   reg [`FIFOSZ-1:0] valid_q ;
   reg [`FIFOPTRSZ-1:0] wptr_q;
   reg [`FIFOPTRSZ-1:0] rptr_q;

   assign dir = ! ( &valid_q) ; // Ready for input from local receiver if buffer not completely full
   assign host_dor = |valid_q;  // Ready for output to host if buffer has any data at all
   assign host_dout = buffer_q[rptr_q] ;

   always @ ( negedge clk or negedge reset_b)
    begin
       if ( !reset_b ) begin
	  {rptr_q,wptr_q,valid_q} <= 0;
       end
       else begin
	  if ( host_rd & valid_q[rptr_q] ) begin
	     valid_q[rptr_q] <= 1'b0;
             if (rptr_q == (`FIFOSZ-1))
	       rptr_q <= 0;
             else
	       rptr_q <= (rptr_q+1);
	  end
	  if (we & !valid_q[wptr_q] ) begin
	    buffer_q[wptr_q]<= din;
            valid_q[wptr_q] <= 1'b1;
            if (wptr_q == (`FIFOSZ-1))
	      wptr_q <= 0;
            else
	      wptr_q <= (wptr_q+1);
	  end
       end
    end
endmodule
