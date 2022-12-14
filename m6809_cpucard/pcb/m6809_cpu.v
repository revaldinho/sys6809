module m6809_cpu();

  supply1 VDD;
  supply0 GND;

  wire    A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0;
  wire    A8SYS;
  wire    D7,D6,D5,D4,D3,D2,D1,D0;
  wire    DR7,DR6,DR5,DR4,DR3,DR2,DR1,DR0;
  wire    E_0,E_B_1,E_2,ECLK;
  wire    Q_0,Q_B_1,Q_2,QCLK;
  wire    WR_B;
  wire    IRQ_B_PU, NMI_B_PU, FIRQ_B_PU, IRQ_B;
  wire    MRDY_PU, BREQ_B_PU, HALT_B_PU;
  wire    RST_B_0, RST_1, RESET_B;
  wire    BS, BA;
  wire    LED_PU;
  wire    XTAL_I, XTAL_O;
  wire    CSUART_B;

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
    		   .p20(QCLK),          //(IOREQ_B),  * * * * * : Use as Q clock
    		   .p18(WR_B), 	        // (WR_B),    * * * * * : WR_B = RNW
    		   .p16(IRQ_B),         //(INT_B),    o * o * o :
    		   .p14(BREQ_B_PU),     //(BUSRQ_B),  o * o * o :
    		   .p12(MRDY_PU),       //(READY),    o * * * o :
    		   .p10(RESET_B),       //(RESET_B),  * * * * o :
    		   .p8 (),              //(ROMDIS),   * * o o o :
    		   .p6 (BA),            //(RAMDIS),   o * o o * : no-connect on CPU card - available for system signals
    		   .p4 (GND),           //(LPEN),     o o o o o : LPEN not connected - use as additional GND
    		   .p2 (GND),	        // (VSS),     * * * * * :
		   //-----------------------------------------------------------------------------
		   .p49(GND),	        //(VSS),      * * * * * :
		   .p47(A14),	        //(A14),      * * * * * :
		   .p45(A12),	        //(A12),      * * * * o :
		   .p43(A10),	        //(A10),      * * * * o :
		   .p41(A8SYS),	        //(A8)        * * * * * : A8SYS Driven from sys logic (A8SYS=A8$(BS&!BA)) for remapping
		   .p39(A6),	        //(A6),       * * * * o :
		   .p37(A4),	        //(A4),       * * * * o :
		   .p35(A2),	        //(A2),       * * o * o : CPLINK no connect on A[3:2]
		   .p33(A0),	        //(A0),       * * * * o :
		   .p31(DR6),	        //(D6)        * * * * * :
		   .p29(DR4),	        //(D4),       * * * * * :
		   .p27(DR2),	        //(D2),       * * * * * :
		   .p25(DR0),	        //(D0),       * * * * * :
		   .p23(FIRQ_B_PU),     //(MREQ_B),   * * * * * :
		   .p21(A8),            //(RFSH_B),   o * o o * : A8 from CPU to system logic for potential remapping
		   .p19(),	        //(RD_B),     * * * * * : no-connect on CPU card - available for system signals
		   .p17(GND),           //(HALT_B),   o o o o o : HALT Never connected
		   .p15(NMI_B_PU),      //(NMI_B),    o * o o o :
		   .p13(HALT_B_PU),     //(BUSACK_B), o * o * o :
		   .p11(),              //(BUSRESET_B)o * o o * : no-connect on CPU card - available for system signals
		   .p9 ()               //(ROMEN_B),  * * o o o :
		   .p7 (BS),            //(RAMRD_B),  o * o o * : no-connect on CPU card - available for system signals
		   .p5 (VDD),           //(CURSOR),   * * * * o : CURSOR not connected - reused as additional VDD
		   .p3 (GND),           //(EXP_B),    * * * * o : EXP_B not connected - reused as additional GND
		   .p1 (ECLK)           //(CLK),      * * * * * :
		   );


  mc6809 IC_0 (
    	       .vss(GND ),         .haltb(HALT_B_PU),
    	       .nmib(NMI_B_PU ),   .xtal(XTAL_I),
    	       .irqb(IRQ_B_PU ),   .extal(XTAL_O),
    	       .firqb(FIRQ_B_PU ), .resetb(RESET_B),
    	       .bs(BS),            .mrdy(MRDY_PU),
    	       .ba(BA),            .q(Q_0),
    	       .vcc(VDD),          .e(E_0),
    	       .a0(A0),            .dma_breqb(BREQ_B_PU),
    	       .a1(A1),            .rnw(WR_B),
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
  SN7414 IC_1(
	      .i0(E_0),     .vdd(VDD),
	      .o0(E_B_1),   .i3(RST_B_0),
	      .i1(E_B_1),   .o3(RST_1),
	      .o1(E_2),     .i4(RST_1),
	      .i2(Q_0),     .o4(RESET_B),
	      .o2(Q_B_1),   .i5(Q_B_1),
	      .vss(GND),    .o5(Q_2)
	      );



  // Oscillator for CPU
  cap18pf   capx_0  ( .p0(XTAL_I), .p1(GND));
  cap18pf   capx_1  ( .p0(XTAL_O), .p1(GND));
  hdr1x03   xtal_0  ( .p1(XTAL_I), .p3(XTAL_O));

  // Link options - select 6809 clock out or buffered clock
  hdr1x03 lk_0( .p1(E_0),.p2(ECLK),.p3(E_2));
  hdr1x03 lk_1( .p1(Q_0), .p2(QCLK),.p3(Q_2));

  // Test Point for clock
  hdr1x04 tp_0(.p1(GND),.p2(ECLK), .p3(GND), .p4(QCLK));


  // Reset button/cap/resistor combination
  resistor res4k7_0 (.p0(VDD),.p1(RST_B_0));
  cap100nf cap_2( .p0(RST_B_0), .p1(GND));

  TSWITCH switch_0 (
		    .a_0(RST_B_0), .a_1(RST_B_0),
		    .b_0(GND),.b_1(GND)
		    );

  // Power ON LED
  LED3MM led_0 (.A(LED_PU),.K(GND));

  DIP4 dip4_0(
              // DIP1 to physically disconnect IRQ_B
              .sw0_a(IRQ_B), .sw0_b(IRQ_B_PU),
              .sw1_a(),.sw1_b(),
              .sw2_a(),.sw2_b(),
              .sw3_a(),.sw3_b(),
              );

  // Misc pull-ups
  r10k_sil9 sil10k_0(
    		 .common(VDD),
    		 .p0(MRDY_PU),
    		 .p1(BREQ_B_PU),
    		 .p2(HALT_B_PU),
    		 .p3(IRQ_B_PU),
    		 .p4(FIRQ_B_PU),
    		 .p5(NMI_B_PU),
    		 .p6(LED_PU), // Eff. 5Kohm for LED PU
		 .p7(LED_PU)
    		 );

  // current limiting resistors on databus
  vresistor res100r_0 (.p0(D0), .p1(DR0));
  vresistor res100r_1 (.p0(D1), .p1(DR1));
  vresistor res100r_2 (.p0(D2), .p1(DR2));
  vresistor res100r_3 (.p0(D3), .p1(DR3));
  vresistor res100r_4 (.p0(D4), .p1(DR4));
  vresistor res100r_5 (.p0(D5), .p1(DR5));
  vresistor res100r_6 (.p0(D6), .p1(DR6));
  vresistor res100r_7 (.p0(D7), .p1(DR7));

  // IC decoupling
  cap100nf dcap_0 ( .p0(VDD), .p1(GND) );
  cap100nf dcap_1 ( .p0(VDD), .p1(GND) );

  //board decoupling
  cap22uf ecap_0  (.plus(VDD), .minus(GND) );

endmodule
