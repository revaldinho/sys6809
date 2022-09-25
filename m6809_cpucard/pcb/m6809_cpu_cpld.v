
module m6809_cpu_cpld();

  supply1 VDD;
  supply0 GND;

  wire    A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0;
  wire    D7,D6,D5,D4,D3,D2,D1,D0;
  wire    DR7,DR6,DR5,DR4,DR3,DR2,DR1,DR0;
  wire    ECLK, QCLK, ECLK_LPF;
  wire    RNW;
  wire    IRQ_B_PU, NMI_B_PU, FIRQ_B_PU;
  wire    MRDY_PU, BREQ_B_PU, HALT_B_PU;
  wire    RST_B;
  wire    BS, BA, IACK_B;
  wire    LED_PU;
  wire    CSUART_B, CSIO_B;
  wire    DIP0, DIP1;
  wire    TDO, TMS, TDI, TCK;
  wire    SYS_A8, SYS_ECLK;
  wire    HSCLK, AUXCLK;
  wire    CPC_BUSRST_B, CPC_ROMEN_B, CPC_ROMDIS;
  wire    BUSACK_B, SW_RST_B;
  wire    SYS_Q_AUXCLK;

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
    		    .p20(SYS_Q_AUXCLK), //(IOREQ_B),  * * * * * : Use as Q clock
    		    .p18(RNW), 	        // (WR_B),    * * * * * : WR_B = RNW
    		    .p16(IRQ_B_PU),     //(INT_B),    o * o * o :
    		    .p14(BREQ_B_PU),    //(BUSRQ_B),  o * o * o :
    		    .p12(MRDY_PU),      //(READY),    o * * * o :
    		    .p10(RST_B),        //(RST_B),  * * * * o :
    		    .p8 (CPC_ROMDIS),       //(ROMDIS),   * * o o o :
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
		    .p23(FIRQ_B_PU),    //(MREQ_B),   * * * * * :
		    .p21(IACK_B),       //(RFSH_B),   o * o o * :
		    .p19(CSIO_B),  	//(RD_B),     * * * * * :
		    .p17(VDD),          //(HALT_B),   o o o o o : HALT Never connected - reuse as additional VDD
		    .p15(NMI_B_PU),     //(NMI_B),    o * o o o :
		    .p13(BUSACK_B),     //(BUSACK_B), o * o * o :
		    .p11(CPC_BUSRST_B), //(BUSRST_B), o * o o * : no-connect on CPU card - available for system signals
		    .p9 (CPC_ROMEN_B),      //(ROMEN_B),  * * o o o :
		    .p7 (A8),	        //(RAMRD_B),  o * o o * : no-connect on CPU card - available for system signals
		    .p5 (VDD),          //(CURSOR),   o o o o o : CURSOR not connected - reused as additional VDD
		    .p3 (GND),          //(EXP_B),    o o o o o : EXP_B not connected - reused as additional GND
		    .p1 (SYS_ECLK)      //(CLK),      * * * * * :
		    );


  mc6809 IC0 (
    	      .vss(GND ),         .haltb(HALT_B_PU),
    	      .nmib(NMI_B_PU ),   .xtal(GND),
    	      .irqb(IRQ_B_PU ),   .extal(HSCLK),
    	      .firqb(FIRQ_B_PU ), .resetb(RST_B),
    	      .bs(BS),            .mrdy(MRDY_PU),
    	      .ba(BA),            .q(QCLK),
    	      .vcc(VDD),          .e(ECLK),
    	      .a0(A0),            .dma_breqb(BREQ_B_PU),
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
                    .clk(AUXCLK)
                    );

  // CPLD44 for programmable control logic
  xc9572pc44  CPLD (
                    .p1(BA),
                    .p2(BS),
                    .p3(QCLK),
                    .p4(A5),
                    .gck1(ECLK_LPF),
                    .gck2(AUXCLK),
                    .gck3(A6),
                    .p8(BREQ_B_PU),
                    .p9(A7),
                    .gnd1(GND),
                    .p11(A8),
                    .p12(A9),
                    .p13(A10),
                    .p14(A11),
                    .tdi(TDI),
                    .tms(TMS),
                    .tck(TCK),
                    .p18(A12),
                    .p19(A13),
                    .p20(A14),
                    .vccint1(VDD),
                    .p22(A15),
                    .gnd2(GND),
                    .p24(SYS_A8),
                    .p25(RNW),
                    .p26(IRQ_B_PU),
                    .p27(FIRQ_B_PU),
                    .p28(NMI_B_PU),
                    .p29(RST_B),
                    .tdo(TDO),
                    .gnd3(GND),
                    .vccio(VDD),
                    .p33(IACK_B),
                    .p34(BUSACK_B),
                    .p35(CSIO_B),
                    .p36(CSUART_B),
                    .p37(SYS_ECLK),
                    .p38(SYS_Q_AUXCLK),
                    .gsr(CPC_BUSRST_B),
                    .gts2(CPC_ROMEN_B),
                    .vccint2(VDD),
                    .gts1(SW_RST_B),
                    .p43(DIP0),
                    .p44(DIP1)
                    );

  // LPF for ECLK
  vresistor r100_8 (.p0(ECLK),.p1(ECLK_LPF));
  cap47pf C6( .p0(ECLK_LPF), .p1(GND));

  // Test point for the clock
  //  hdr1x05  TP0 ( .p1(GND), .p2(HSCLK), .p3(GND), .p4(ECLK), .p5(QCLK));

  // Standard layout JTAG port for programming the CPLD
  hdr8way JTAG (
                .p1(GND),  .p2(GND),
                .p3(TMS),  .p4(TDI),
                .p5(TDO),  .p6(TCK),
                .p7(VDD),  .p8(),
                );

  // Reset button/cap/resistor combination
  resistor r10k (.p0(VDD),.p1(SW_RST_B));
  cap100nf C7( .p0(SW_RST_B), .p1(GND));

  TSWITCH sw0 (
	       .a_0(SW_RST_B), .a_1(SW_RST_B),
	       .b_0(GND),.b_1(GND)
	       );

  // Power ON LED
  LED3MM led0 (.A(DIP0),.K(GND));
  LED3MM led1 (.A(DIP1),.K(GND));
  LED3MM led2 (.A(LED_PU),.K(GND));
  vresistor r2k2_0 (.p0(DIP0), .p1(VDD));
  vresistor r2k2_1 (.p0(DIP1), .p1(VDD));
  vresistor r2k2_2 (.p0(LED_PU), .p1(VDD));

  DIP2 dip2(
            .sw0_a(DIP0), .sw0_b(GND),
            .sw1_a(DIP1),.sw1_b(GND),
            );

  // Misc pull-ups
  r10k_sil9 sil10k(
    		   .common(VDD),
    		   .p0(HALT_B_PU),
		   .p1(NMI_B_PU)
    		   .p2(IRQ_B_PU),
    		   .p3(FIRQ_B_PU),
    		   .p4(MRDY_PU),
    		   .p5(BREQ_B_PU),
		   .p6(),
    		   .p7(),
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

  //board decoupling
  cap22uf  C5  (.plus(VDD), .minus(GND) );

endmodule
