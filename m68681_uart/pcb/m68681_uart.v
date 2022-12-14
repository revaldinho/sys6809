module m68681_uart();

  supply1 VDD;
  supply0 GND;

  wire    A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0;
  wire    A8SYS;
  wire    D7,D6,D5,D4,D3,D2,D1,D0;
  wire    DR7,DR6,DR5,DR4,DR3,DR2,DR1,DR0;
  wire    E_0,E_B_1,E_2,ECLK;
  wire    Q_0,Q_B_1,Q_2,QCLK;
  wire    WR_B;
  wire    IRQ_B, NMI_B, FIRQ_B;
  wire    MRDY, BREQ_B, HALT_B;
  wire    RST_B_0, RST_1, RESET_B;
  wire    BS, BA;
  wire    XTAL_I, XTAL_O;
  wire    CSUART_B;
  wire    UART_OP2,UART_OP3_PU,UART_OP4_PU,UART_OP5_PU,UART_OP6_PU,UART_OP7_PU;
  wire    RTSA_B, RTSB_B, CTSA_B_PU, CTSB_B_PU;
  wire    RXB, RXA, TXA, TXB;
  wire    UART_X1, UART_X2;
  wire    UART_IP2_PU, UART_IP3_PU, UART_IP4_PU, UART_IP5_PU;
  wire    IACK_B_PU;

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
    		   .p14(BREQ_B),        //(BUSRQ_B),  o * o * o :
    		   .p12(MRDY),          //(READY),    o * * * o :
    		   .p10(RESET_B),       //(RESET_B),  * * * * o :
    		   .p8 (BA),            //(ROMDIS),   * * o o o :
    		   .p6 (),              //(RAMDIS),   o * o o * : no-connect on CPU card - available for system signals
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
		   .p23(FIRQ_B),        //(MREQ_B),   * * * * * :
		   .p21(A8),            //(RFSH_B),   o * o o * : A8 from CPU to system logic for potential remapping
		   .p19(),	        //(RD_B),     * * * * * : no-connect on CPU card - available for system signals
		   .p17(GND),           //(HALT_B),   o o o o o : HALT Never connected
		   .p15(NMI_B),         //(NMI_B),    o * o o o :
		   .p13(HALT_B),        //(BUSACK_B), o * o * o :
		   .p11(),              //(BUSRESET_B)o * o o * : no-connect on CPU card - available for system signals
		   .p9 (BS)             //(ROMEN_B),  * * o o o :
		   .p7 (),	        //(RAMRD_B),  o * o o * : no-connect on CPU card - available for system signals
		   .p5 (VDD),           //(CURSOR),   * * * * o : CURSOR not connected - reused as additional VDD
		   .p3 (GND),           //(EXP_B),    * * * * o : EXP_B not connected - reused as additional GND
		   .p1 (ECLK)           //(CLK),      * * * * * :
		   );

  mc68681 IC_0(
	       .rs1(A0),               .vdd(VDD),
	       .ip3_txca(UART_IP3_PU), .ip4_rxcb(UART_IP4_PU),
	       .rs2(A1),	       .ip5_txcb(UART_IP5_PU),
	       .ip1_ctsb_b(CTSB_B_PU), .iack_b(IACK_B_PU),
	       .rs3(A2),               .ip2_rxcb(UART_IP2_PU),
	       .rs4(A3),               .cs_b(CSUART_B),
	       .ip0_ctsa_b(CTSA_B_PU), .reset_b(RESET_B),
	       .rnw(WR_B),             .x2(UART_X2),
	       .dtack_b(),             .x1_clk(UART_X1),
	       .rxdb(RXB),             .rxda(RXA),
	       .txdb(TXB),             .txda(TXA),
	       .op1_rtsb_b(RTSB_B),    .op0_rtsa_b(RTSA_B),
	       .op3(UART_OP3_PU),      .op2(UART_OP2),
	       .op5(UART_OP5_PU),      .op4(UART_OP4_PU),
	       .op7(UART_OP7_PU),      .op6(UART_OP6_PU),
	       .d1(D1),                .d0(D0),
	       .d3(D3),                .d2(D2),
	       .d5(D5),                .d4(D4),
	       .d7(D7),                .d6(D6),
	       .gnd(GND),              .irq_b(IRQ_B_PU)
	       );

  // Schmitt Trigger for buffering
  SN7414 IC_1(
	      .i0(E_0),     .vdd(VDD),
	      .o0(E_B_1),   .i3(RST_1),
	      .i1(E_B_1),   .o3(RESET_B),
	      .o1(E_2),     .i4(Q_0),
	      .i2(RST_B_0), .o4(Q_B_1),
	      .o2(RST_1),   .i5(Q_B_1),
	      .vss(GND),    .o5(Q_2)
	      );

  // UART Oscillator - independent of CPU clock
  cap18pf   capx_0 ( .p0(UART_X1), .p1(GND));
  cap18pf   capx_1 ( .p0(UART_X2), .p1(GND));
  hdr1x03   xtal_0  (.p1(UART_X1), .p2(), .p3(UART_X2));


  // GPIO Header for all UART input/output pins
  hdr2x08 gpio_0(
                 .p1(RTSA_B),        .p2(CTSA_B_PU)
                 .p3(RTSB_B),        .p4(CTSB_B_PU),
                 .p5(UART_OP2),      .p6(UART_IP2_PU),
                 .p7(UART_OP3_PU),   .p8(UART_IP3_PU),
                 .p9(UART_OP4_PU),   .p10(UART_IP4_PU),
                 .p11(UART_OP5_PU),  .p12(UART_IP5_PU),
                 .p13(UART_OP6_PU),  .p14(GND),
                 .p15(UART_OP7_PU),  .p16(GND)
          );

  // Dual UART Header
  hdr2x05 uart_0 (
	          .p1(GND), .p2(GND),
	          .p3(TXA), .p4(TXB),
	          .p5(RXA), .p6(RXB),
	          .p7(CTSA_B_PU), .p8(CTSB_B_PU),
	          .p9(RTSA_B), .p10(RTSB_B)
	          );

  DIP8 dip8_0(
              // Use IP2-5 as GP DIP inputs
              .sw0_a(UART_IP2_PU), .sw0_b(GND),
              .sw1_a(UART_IP3_PU), .sw1_b(GND),
              .sw2_a(UART_IP4_PU), .sw2_b(GND),
              .sw3_a(UART_IP5_PU), .sw3_b(GND),
              // allow use of E as CTC clock input
              .sw4_a(ECLK),.sw4_b(UART_IP2_PU),
              // IRQ connector for counter interrupt - set one switch to enable CTC interrupts
              .sw5_a(UART_OP3_PU),.sw5_b(IRQ_B),
              .sw6_a(UART_OP3_PU),.sw6_b(FIRQ_B),
              .sw7_a(UART_OP3_PU),.sw7_b(NMI_B),
              );

  // Relatively high value PU on these inputs to hold static voltages, but
  // not interfere with DIP settings and  driven logic (or clock) timing into the UART
  r10k_sil9 pu_1 (
                  .common(VDD),
                  .p0(CTSB_B_PU),
                  .p1(CTSA_B_PU),
                  .p2(UART_IP3_PU),
                  .p3(UART_IP4_PU),
                  .p4(UART_IP4_PU),
                  .p5(UART_IP5_PU),
                  .p6(IACK_B_PU),
                  .p7()
                  );
  r10k_sil9 pu_2 (
                  .common(VDD),
                  .p0(UART_OP3_PU),
                  .p1(UART_OP4_PU),
                  .p2(UART_OP5_PU),
                  .p3(UART_OP6_PU),
                  .p4(UART_OP7_PU),
                  .p5(),
                  .p6(),
                  .p7(),
                  );

  // IC decoupling
  cap100nf dcap_0 ( .p0(VDD), .p1(GND) );
  cap100nf dcap_1 ( .p0(VDD), .p1(GND) );

  //board decoupling
  cap22uf ecap_0  (.plus(VDD), .minus(GND) );

endmodule
