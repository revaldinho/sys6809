module m6809_cpld(
		  input        ba,
		  input        bs,
                  input        auxclk,
		  input        hsclk, // can also drive out hsclk from auxclk if required (and OSC0 not fitted)
		  input [15:5] a,
		  input [1:0]  dip,
		  input        eclk,
                  input        qclk,
		  input        rnw,
		  input        rst_b,

		  inout        breq_b,
		  inout        irq_b,
		  inout        firq_b,
		  inout        nmi_b,

		  output       sys_a8,
		  output       sys_rst_b,
		  output       iack_b,
		  output       busack_b,
		  output       csio_b,
		  output       csuart_b,

		  output       sys_eclk,
		  output       sys_q_auxclk,
		  output       cpc_busrst_b 	// AKA LED0
		  );

  // expect to divide this but start with 3.686MHz xtal/0.9MHz CPU
  assign extal_o = hsclk_in ;

  // Rebuffering only
  assign sys_rst_b = rst_b;

`ifdef SHAPE_ECLK_PULSE
  // reject short pos edge glitches, but delay rising edge
  (* KEEP=TRUE *) wire eclk_1, eclk_2;
  BUF i_0 ( .i(eclk), .o(eclk_1));
  BUF i_1 ( .i(eclk_1), .o(eclk_2));
  assign sys_eclk = eclk & eclk_1 & eclk_2;
`else
  assign sys_eclk = eclk;
`endif

  // DIP Switch selection
  wire remap_vectors = dip[0];
  wire auxclk_sel = dip[1];

  // Signal interrupt ack and bus grant
  assign iack_n = !(bs & !ba);
  assign busack_n = !(bs & ba);

  // Remap vectors from FFF* to FEF*
  // alternate = !(!a[8] + !bs + ba) since <a8,bs&!ba>=<01> is a dont care
  //             a[8]^(bs&!ba)
  assign sys_a8 = (remap_vectors ) ? a[8]^(bs&!ba) : a[8];

  // IO Space at FExx and UART at FE0x
  assign csio_b = !( (&a[15:9]) & !a[8]);
  assign csuart_b = !( !csio_b & !a7 & !a6 & !a5 )& eclk);

  // Drive out Q or aux clock
  assign sys_q_auxclk = (auxclk_sel) ? auxclk : qclk;

endmodule
