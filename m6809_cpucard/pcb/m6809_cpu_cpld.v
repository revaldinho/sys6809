module m6809_cpu_cpld();

  supply1 VDD;
  supply0 GND;

  wire    A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0, A8_B;
  wire    D7,D6,D5,D4,D3,D2,D1,D0;
  wire    DR7,DR6,DR5,DR4,DR3,DR2,DR1,DR0;
  wire    ECLK, ECLK_B, ECLK_BUF, QCLK;
  wire    RNW;
  wire    IRQ_B_PU, NMI_B_PU, FIRQ_B_PU;
  wire    MRDY_BUSY_PU, BREQ_B_AVMA_PU, HALT_B_PU;
  wire    RST_B_0, RST_1, RESET_B;
  wire    BS, BA, IACK_B;
  wire    LED_PU;
  wire    CSUART_B, CSIO_B;
  wire    DIP0, DIP1;
  wire    TDO, TMS, TDI, TCK;
  wire    ROMEN_B, RFSH_B, ROMDIS;
  wire    SYS_A8, SYS_ECLK, SYS_MRDY, SYS_BREQ_B, DECODE_FE_B;
  wire    EXTAL_LIC_CPU, XTAL_TSC_CPU;
  wire    HSCLK;
  wire    ALTCLK, ALTCLKOUT;

  //                                                      c   r
  //                 		                          p t a
  //     			                      r r l u m
  //    		   	                      o a n b 4
  //  	 			                      m m k e 4
  idc_hdr_50w CONN0 (
    		    .p50(GND)  	        // (Sound),   o o o o o : sound never connected - use as additional ground
    		    .p48(A15),   	// (A15),     * * * * * :
    		    .p46(A13),   	// (A13),     * * * * * :
    		    .p44(A11),   	// (A11),     * * * * o :
    		    .p42(A9),     	// (A9),      * * * * o :
    		    .p40(A7),     	// (A7),      * * * * o :
    		    .p38(A5),     	// (A5),      * * * * o :
    		    .p36(A3),     	// (A3),      * * o * o : CPLINK no connect on A[3:2]
    		    .p34(A1),     	// (A1),      * * * * o :
    		    .p32(DR7),    	// (D7),      * * * * * :
    		    .p30(DR5),    	// (D5),      * * * * * :
    		    .p28(DR3),    	// (D3),      * * * * * :
    		    .p26(DR1),    	// (D1),      * * * * * :
    		    .p24(VDD),     	// (VDD),     * * * * * :
    		    .p22(CSUART_B),    	// (M1_B),    o * o * o : no-connect on CPU card - available for system signals
    		    .p20(QCLK),         //(IOREQ_B),  * * * * * : Use as Q clock
    		    .p18(RNW), 	        // (WR_B),    * * * * * : WR_B = RNW
    		    .p16(IRQ_B_PU),     //(INT_B),    o * o * o :
    		    .p14(SYS_BREQ_B),   //(BUSRQ_B),  o * o * o :
    		    .p12(SYS_MRDY),     //(READY),    o * * * o :
    		    .p10(RESET_B),      //(RESET_B),  * * * * o :
    		    .p8 (ROMDIS),       //(ROMDIS),   * * o o o :
    		    .p6 (HALT_B_PU),    //(RAMDIS),   o * o o * : no-connect on CPU card - available for system signals
    		    .p4 (GND),          //(LPEN),     o o o o o : LPEN not connected - use as additional GND
    		    .p2 (GND),	        // (VSS),     * * * * * :
		    //-----------------------------------------------------------------------------
		    .p49(GND),	        //(VSS),      * * * * * :
		    .p47(A14),	        //(A14),      * * * * * :
		    .p45(A12),	        //(A12),      * * * * o :
		    .p43(A10),	        //(A10),      * * * * o :
		    .p41(SYS_A8),	//(A8)        * * * * * : SYS_A8 Driven from sys logic (SYS_A8=A8$(BS&!BA)) for remapping
		    .p39(A6),	        //(A6),       * * * * o :
		    .p37(A4),	        //(A4),       * * * * o :
		    .p35(A2),	        //(A2),       * * o * o : CPLINK no connect on A[3:2]
		    .p33(A0),	        //(A0),       * * * * o :
		    .p31(DR6),	        //(D6)        * * * * * :
		    .p29(DR4),	        //(D4),       * * * * * :
		    .p27(DR2),	        //(D2),       * * * * * :
		    .p25(DR0),	        //(D0),       * * * * * :
		    .p23(FIRQ_B_PU),     //(MREQ_B),   * * * * * :
		    .p21(RFSH_B),        //(RFSH_B),   o * o o * :
		    .p19(CSIO_B),	//(RD_B),     * * * * * :
		    .p17(VDD),              //(HALT_B),   o o o o o : HALT Never connected - reuse as additional VDD
		    .p15(NMI_B_PU),      //(NMI_B),    o * o o o :
		    .p13(IACK_B),        //(BUSACK_B), o * o * o :
		    .p11(ALTCLKOUT),     //(BUSRESET_B)o * o o * : no-connect on CPU card - available for system signals
		    .p9 (ROMEN_B),       //(ROMEN_B),  * * o o o :
		    .p7 (A8),	         //(RAMRD_B),  o * o o * : no-connect on CPU card - available for system signals
		    .p5 (VDD),           //(CURSOR),   o o o o o : CURSOR not connected - reused as additional VDD
		    .p3 (GND),           //(EXP_B),    o o o o o : EXP_B not connected - reused as additional GND
		    .p1 (SYS_ECLK)       //(CLK),      * * * * * :
		    );


  mc6809 IC0 (
    	      .vss(GND ),         .haltb(HALT_B_PU),
    	      .nmib(NMI_B_PU ),   .xtal(XTAL_TSC_CPU),
    	      .irqb(IRQ_B_PU ),   .extal(EXTAL_LIC_CPU),
    	      .firqb(FIRQ_B_PU ), .resetb(RESET_B),
    	      .bs(BS),            .mrdy(MRDY_BUSY_PU),
    	      .ba(BA),            .q(QCLK),
    	      .vcc(VDD),          .e(ECLK),
    	      .a0(A0),            .dma_breqb(BREQ_B_AVMA_PU),
    	      .a1(A1),            .rnw(RNW),
    	      .a2(A2),            .d0(D0),
    	      .a3(A3),            .d1(D1),
    	      .a4(A4),            .d2(D2),
    	      .a5(A5),            .d3(D3),
    	      .a6(A6),            .d4(D4),
    	      .a7(A7),            .d5(D5),
    	      .a8(A8),            .d6(D6),
    	      .a9(A9),            .d7(D7),
    	      .a10(A10),          .a15(A15),
    	      .a11(A11),          .a14(A14),
    	      .a12(A12),          .a13(A13)
	      );

  // Schmitt Trigger for buffering
  SN7414 IC1(
	     .i0(ECLK),    .vdd(VDD),
	     .o0(ECLK_B),  .i3(ECLK_B),
	     .i1(RST_B_0), .o3(ECLK_BUF),
	     .o1(RST_1),   .i4(A8),
	     .i2(RST_1),   .o4(A8_B),
	     .o2(RESET_B), .i5(GND),
	     .vss(GND),    .o5()
	     );

  // Partial Decode of top byte for IO addressing
  SN7430 IC2 (.vdd(VDD),
              .i0(A15),
              .i1(A14),
              .i2(A13),
              .i3(A12),
              .i4(A11),
              .i5(A10),
              .i6(A9),
              .i7(A8_B),
              .o(DECODE_FE_B),
              .vss(GND)
              );

  // Socket for CMOS oscillator
  cmos_osc_14 OSC0 (
                    .gnd(GND),
                    .vdd(VDD),
                    .en(VDD),
                    .clk(HSCLK)
                    );

  // Socket for second CMOS oscillator (baud clock?)
  cmos_osc_14 OSC1 (
                    .gnd(GND),
                    .vdd(VDD),
                    .en(VDD),
                    .clk(ALTCLK)
                    );

  // CPLD44 for programmable control logic
  xc9572pc44  CPLD (
                    .p1(EXTAL_LIC_CPU),
                    .p2(ECLK),    // E from or to CPU
                    .p3(QCLK),    // Q from or to CPU
                    .p4(XTAL_TSC_CPU),
                    .gck1(HSCLK), // incoming oscillator clock
                    .gck2(BS),
                    .gck3(BA),
                    .p8(BREQ_B_AVMA_PU),
                    .p9(A5),
                    .gnd1(GND),
                    .p11(A6),
                    .p12(A7),
                    .p13(A8),
                    .p14(),
                    .tdi(TDI),
                    .tms(TMS),
                    .tck(TCK),
                    .p18(DIP0),
                    .p19(DIP1),
                    .p20(ALTCLKOUT),
                    .vccint1(VDD),
                    .p22(RFSH_B),  // unallocated CPC name
                    .gnd2(GND),
                    .p24(ROMEN_B), // unallocated CPC name
                    .p25(ROMDIS),  // unallocated CPC name
                    .p26(IRQ_B_PU),
                    .p27(ALTCLK),
                    .p28(SYS_MRDY),
                    .p29(SYS_BREQ_B),
                    .tdo(TDO),
                    .gnd3(GND),
                    .vccio(VDD),
                    .p33(SYS_RST_B),
                    .p34(),
                    .p35(SYS_A8),
                    .p36(CSUART_B),
                    .p37(CSIO_B),
                    .p38(IACK_B),
                    .gsr(RESET_B),
                    .gts2(),
                    .vccint2(VDD),
                    .gts1(RNW),
                    .p43(MRDY_BUSY_PU),
                    .p44(DECODE_FE_B),
                    );

  // Test point for the clock
  hdr1x05  TP0 ( .p1(GND), .p2(HSCLK), .p3(GND), .p4(ECLK), .p5(ECLK_BUF));

  // Standard layout JTAG port for programming the CPLD
  hdr8way JTAG (
                .p1(GND),  .p2(GND),
                .p3(TMS),  .p4(TDI),
                .p5(TDO),  .p6(TCK),
                .p7(VDD),  .p8(),
                );

  // Reset button/cap/resistor combination
  resistor r10k (.p0(VDD),.p1(RST_B_0));
  cap100nf C8( .p0(RST_B_0), .p1(GND));

  TSWITCH sw0 (
	       .a_0(RST_B_0), .a_1(RST_B_0),
	       .b_0(GND),.b_1(GND)
	       );

  // Link for E or buffered version to backplane
  hdr1x03  lk0( .p1(ECLK), .p2(SYS_ECLK), .p3(ECLK_BUF));

  // Power ON LED
  LED3MM led (.A(LED_PU),.K(GND));
  resistor r2k2 (.p0(LED_PU), .p1(VDD));

  DIP2 dip2(
            .sw0_a(DIP0), .sw0_b(GND),
            .sw1_a(DIP1),.sw1_b(GND),
            );

  // Misc pull-ups
  r10k_sil9 sil10k(
    		   .common(VDD),
    		   .p0(MRDY_BUSY_PU),
    		   .p1(BREQ_B_AVMA_PU),
    		   .p2(HALT_B_PU),
    		   .p3(IRQ_B_PU),
    		   .p4(FIRQ_B_PU),
    		   .p5(NMI_B_PU),
    		   .p6(DIP0),
		   .p7(DIP1)
    		   );

  // current limiting resistors on databus
  vresistor r100_0 (.p0(D0), .p1(DR0));
  vresistor r100_1 (.p0(D1), .p1(DR1));
  vresistor r100_2 (.p0(D2), .p1(DR2));
  vresistor r100_3 (.p0(D3), .p1(DR3));
  vresistor r100_4 (.p0(D4), .p1(DR4));
  vresistor r100_5 (.p0(D5), .p1(DR5));
  vresistor r100_6 (.p0(D6), .p1(DR6));
  vresistor r100_7 (.p0(D7), .p1(DR7));

  // IC decoupling
  cap100nf C0 ( .p0(VDD), .p1(GND) );
  cap100nf C1 ( .p0(VDD), .p1(GND) );
  cap100nf C2 ( .p0(VDD), .p1(GND) );
  cap100nf C3 ( .p0(VDD), .p1(GND) );
  cap100nf C4 ( .p0(VDD), .p1(GND) );
  cap100nf C5 ( .p0(VDD), .p1(GND) );
  cap100nf C6 ( .p0(VDD), .p1(GND) );
  //board decoupling
  cap22uf  C7  (.plus(VDD), .minus(GND) );

endmodule
