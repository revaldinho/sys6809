
module m6809_cpu_cpld();

  supply1 VDD;
  supply0 GND;

  wire    A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0;
  wire    D7,D6,D5,D4,D3,D2,D1,D0;
  wire    DR7,DR6,DR5,DR4,DR3,DR2,DR1,DR0;

  special_wire    ECLK, QCLK, ECLK_LPF, SYS_Q_AUXCLK, SYS_ECLK;
  special_wire    HSCLK, AUXCLK;

  wire    RNW;
  wire    IRQ_B_PU, NMI_B_PU, FIRQ_B_PU;
  wire    MRDY_PU, BREQ_B_PU, HALT_B_PU;
  wire    RST_B;
  wire    BS, BA, IACK_B;
  wire    CSUART_B, CSIO_B;
  wire    DIP0_PU, DIP1_PU;
  wire    TDO, TMS, TDI, TCK;
  wire    SYS_A8;
  wire    LED_PU;
  wire    CPC_BUSRST_B_PU, CPC_ROMEN_B, CPC_ROMDIS;
  wire    BUSACK_B, SW_RST_B, RAMDIS;

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
    		    .p8 (HALT_B_PU),       //(ROMDIS),   * * o o o :
    		    .p6 (RAMDIS),       //(RAMDIS),   o * o o * : no-connect on CPU card - available for system signals
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
		    .p11(CPC_BUSRST_B_PU), //(BUSRST_B), o * o o * : no-connect on CPU card - available for system signals
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
                    .p4(IRQ_B_PU),
                    .gck1(HSCLK),
                    .gck2(AUXCLK),
                    .gck3(ECLK_LPF),
                    .p8(FIRQ_B_PU),
                    .p9(NMI_B_PU),
                    .gnd1(GND),
                    .p11(A15),
                    .p12(A14),
                    .p13(A13),
                    .p14(A12),
                    .tdi(TDI),
                    .tms(TMS),
                    .tck(TCK),
                    .p18(A11),
                    .p19(A10),
                    .p20(A9),
                    .vccint1(VDD),
                    .p22(BREQ_B_PU),
                    .gnd2(GND),
                    .p24(A7),
                    .p25(RNW),
                    .p26(A6),
                    .p27(A5),
                    .p28(SYS_Q_AUXCLK),
                    .p29(SYS_A8),
                    .tdo(TDO),
                    .gnd3(GND),
                    .vccio(VDD),
                    .p33(A8),
                    .p34(BUSACK_B),
                    .p35(CSIO_B),
                    .p36(CSUART_B),
                    .p37(SYS_ECLK),
                    .p38(IACK_B),
                    .gsr(CPC_BUSRST_B_PU),
                    .gts2(RST_B),
                    .vccint2(VDD),
                    .gts1(SW_RST_B),
                    .p43(DIP0_PU),
                    .p44(DIP1_PU)
                    );

  hdr1x05 tp0 (.p1(ECLK), .p2(GND), .p3(ECLK_LPF), .p4(GND), .p5(QCLK));

  // LPF for ECLK
  resistor r100_8 (.p0(ECLK),.p1(ECLK_LPF));
  cap47pf C6( .p0(ECLK_LPF), .p1(GND));


  // Standard layout JTAG port for programming the CPLD
  hdr8way JTAG (
                .p1(GND),  .p2(GND),
                .p3(TMS),  .p4(TDI),
                .p5(TDO),  .p6(TCK),
                .p7(VDD),  .p8(),
                );

  // Reset button/cap/resistor combination
  vresistor r10k (.p0(VDD),.p1(SW_RST_B));
  cap100nf C7( .p0(SW_RST_B), .p1(GND));

  TSWITCH sw0 (
	       .a_0(SW_RST_B), .a_1(SW_RST_B),
	       .b_0(GND),.b_1(GND)
	       );

  // Power ON LED
  LED3MM d0 (.A(LED_PU),.K(GND));
  LED3MM d1 (.A(CPC_BUSRST_B_PU),.K(GND));
  LED3MM d2 (.A(DIP0_PU),.K(GND));
  LED3MM d3 (.A(DIP1_PU),.K(GND));
  vresistor r2k2_0 (.p0(LED_PU), .p1(VDD));
  vresistor r2k2_1 (.p0(CPC_BUSRST_B_PU), .p1(VDD));
  vresistor r2k2_2 (.p0(DIP0_PU), .p1(VDD));
  vresistor r2k2_3 (.p0(DIP1_PU), .p1(VDD));

  DIP2 dip2(
            .sw0_a(DIP0_PU), .sw0_b(GND),
            .sw1_a(DIP1_PU),.sw1_b(GND),
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
