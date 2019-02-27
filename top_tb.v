`timescale 1ns/1ns
module tb ();
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, tb);
    end

	parameter UART_DIV = 16;

    reg clk;

    initial begin
        clk = 1'b0;

        repeat(100) #1 clk = ~clk;

		tx_data = 8'h01;

		tx_start = 1;
		repeat(139) #1 clk = ~clk;
		tx_start = 0;
		repeat(139 * 20) #1 clk = ~clk;

		tx_data = 0;

		repeat(5) begin
			tx_start = 1;
			repeat(139) #1 clk = ~clk;
			tx_start = 0;
			repeat(139 * 20) #1 clk = ~clk;
		end

		tx_data = 16;

		tx_start = 1;
		repeat(139) #1 clk = ~clk;
		tx_start = 0;
		repeat(139 * 20) #1 clk = ~clk;

		forever #1 clk = ~clk;
    end

    initial begin
        repeat(2000000) @(posedge clk);
        $finish;
    end

	reg [7:0] tx_data;
	reg tx_start;
	wire tx_signal;

	uart_tx #(UART_DIV) tx(
		.i_Clock(clk),
		.i_Tx_DV(tx_start),
		.i_Tx_Byte(tx_data),
		.o_Tx_Serial(tx_signal)
		);

    top #(.UART_DIV(UART_DIV)) t(
		.CLK(clk),
		.PIN_13(tx_signal)
		);
endmodule
