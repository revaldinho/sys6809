module m6809_cpld(
		  // Board inputs
		  input       clkin,
                  input       altclk;
		  input       rst_b,
		  input [1:0] dip,
		  // CPU direct connections
		  input       decodeFE_b, // From 7430 NAND/Schmitt
		  input       adr8,
		  input       adr7,
		  input       adr6,
		  input       adr5,
                  input       ba,
		  input       bs,
		  input       rnw,
		  // -E/non-E multifunction signals
		  inout       cpu_eclk,
		  inout       cpu_qclk,
		  inout       extal_lic_cpu,
		  inout       mrdy_busy_cpu,
		  inout       xtal_tsc_cpu,
		  inout       breq_b_avma_cpu,
		  inout       irq_b, // create timer locally ? (clear with iack_b)

		  // Expansion port connections
		  input       sys_mrdy,
		  input       sys_breq_b,
		  output      a8_remapped,
		  output      csuart_b,
		  output      csio_b,
		  output      iack_b,
                  output      altclkout,
		  inout       romen_b, // unallocated CPC signal (also connect to TP)
                  inout       rfsh_b,
		  inout       romdis, // unallocated CPC signal   (also connect to TP)
		  );

  reg [1:0] clockdiv_q;
  wire eclk, qclk, remap_vectors, emode;
  assign remap_vectors = dip[0];
  assign emode = dip[1];

  always @ ( posedge clkin ) begin
    case (clockdiv_q):
      2'b00 : clockdiv_q <= 2'b01; // bit[1]=E, bit[0]=Q
      2'b01 : clockdiv_q <= 2'b11;
      2'b11 : clockdiv_q <= 2'b10;
      2'b10 : clockdiv_q <= 2'b00;
    endcase
  end

  assign a8_remapped = (remap_vectors ) ? adr8 ^ ( bs & !ba ) : adr8; // alternate = !(adr8_b + bs_b + ba) since <adr8,bs&!ba>=<01> is a dont care
  assign csio_b = decodeFE_b;
  assign csuart_b = !(!decodeFE_b & !adr7 & !adr6 & !adr5 )& eclk);
  assign iack_b = !(bs & !ba);

  //                                 -E            non-E
  assign eclk          = (emode) ? clockdiv_q[1] : 1'bz;
  assign qclk          = (emode) ? clockdiv_q[0] : 1'bz;
  assign mrdy_busy_cpu = (emode) ? 1'bz          : sys_mrdy;// No MRDY input on -E (but need to stretch clock externally)
  assign extal_lic_cpu = (emode) ? 1'bz          : clkin;   // Dont use LIC on -E, but drive in external clock for non-E
  assign xtal_tsc_cpu  = (emode) ? 1'b0          : 1'b0;    // tristate control not currently used on -E, grounded on non-E
  assign breq_b_busy_cpu=(emode) ? 1'bz          : 1'b1;    // read busy state on -E, drive disabled breq_b on non-E


endmodule
