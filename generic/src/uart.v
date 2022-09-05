 /*
  * regsel = 0 - Control Reg (W) or Status Reg (R)
  *          1 - Data Reg (R/W)
  *
  * MC6850 Control Register (W)
  *
  *  0-1  [NOT SUPPORTED - FIXED @ CLK/16] Baudrate (0=CLK/64, 1=CLK/16, 2=CLK/1, 3=RESET)
  *  2-4  [NOT SUPPORTED - FIXED 8n1     ] Mode (0..7 = 7e2,7o2,7e1,7o1,8n2,8n1,8e1,8o1) (data/stop bits, parity)
  *  5-6  Transmit Interrupt/RTS/Break control (0..3)         [ RTS control not supported ]
  *         0 = Output /RTS=low,  and disable Tx Interrupt
  *         1 = Output /RTS=low,  and enable Tx Interrupt
  *         2 = Output /RTS=high, and disable Tx Interrupt
  *         3 = Output /RTS=low,  and disable Tx Interrupt, and send a Break
  *  7    Receive Interrupt (1=Enable on buffer full/buffer overrun)
  *
  * MC6850 Status Register (R)
  *
  *  0    Receive Data  (0=No data, 1=Data can be read)
  *  1    Transmit Data (0=Busy, 1=Ready/Empty, Data can be written)
  *  2    [=0] /DCD level
  *  3    [=0] /CTS level
  *  4    [=0] Receive Framing Error (1=Error)
  *  5    [=0] Receive Overrun Error (1=Error)
  *  6    [=0] Receive Parity Error  (1=Error)
  *  7    Interrupt Flag (see Control Bits 5-7)
  */

`include "uart.vh"

module uart (
	     input        RXD,
	     output       TXD,
	     output       CTS_B,
	     input        RTS_B,
	     input        regsel,
	     input        cs_b,
	     input        rnw,
	     input [7:0]  din,
	     output [7:0] dout,
             output       irq_b,
             output       frame_error,
             output       overrun,
	     input        clk,
	     input        reset_b
	     ) ;

  wire [7:0]              host_dout_w;
  wire                    host_dir_w;
  wire                    host_dor_w;
  wire                    cts_w;
  wire                    host_data_rd_w = rnw & !cs_b & regsel ;
  wire                    host_data_wr_w = !rnw & !cs_b & regsel;

  reg [1:0]               tx_ctrl_q;
  reg                     rx_int_en_q;
  reg                     irq_q;

  reg                     tx_int_en_w;

`ifndef ERROR_FLAGS
  assign overrun = 1'b0;
  assign frame_error = 1'b0;
`endif

  assign CTS_B = !cts_w;
  assign dout = (regsel) ? host_dout_w : { irq_q, 5'b0, host_dir_w, host_dor_w } ;
  assign irq_b = !irq_q;

  always @ ( * ) begin
    case  (tx_ctrl_q )
      2'b00 : { tx_int_en_w } = 1'b0;
      2'b01 : { tx_int_en_w } = 1'b1;
      2'b10 : { tx_int_en_w } = 1'b0;
      2'b11 : { tx_int_en_w } = 1'b0; // transmit a break on TXDO
    endcase // case (tx_ctrl_q )
  end

  always @ ( negedge clk or negedge reset_b ) begin
    if ( !reset_b ) begin
      {tx_ctrl_q, irq_q } <= 0;
    end
    else begin
      if ( !rnw & !cs_b & !regsel) begin
        {rx_int_en_q, tx_ctrl_q}  <= din[7:5];
      end
      irq_q <= ( tx_int_en_w & host_dir_w ) | ( rx_int_en_q & host_dor_w);
    end
  end

  uarttx uarttx_0(
 		  .din(din),
 		  .host_wr(host_data_wr_w),
 		  .serout(TXD),
 		  .host_dir(host_dir_w),
 		  .clk(clk),
 		  .reset_b(reset_b)
 		  );
  uartrx uartrx_0(
                  .serin(RXD),
                  .host_rd(host_data_rd_w),
                  .host_dout(host_dout_w),
                  .host_dor(host_dor_w),
`ifdef ERROR_FLAGS
                  .overrun(overrun),
                  .frame_error(frame_error),
`endif
                  .cts(cts_w),
                  .clk(clk),
                  .reset_b(reset_b)
                  );


endmodule
