module top (
	input CLK,
	output LED,
	input PIN_13,
	output PIN_12,
	// output PIN_14,
	output USBPU
	);

	// actual parameters
	parameter Q = 24;
	parameter N = 30;
	parameter NC = 8;
	parameter UART_DIV = 32;

	parameter BLOCK_SIZE = 64;

	// disable USB
	assign USBPU = 0;

	// state machine
	parameter STATE_IDLE = 0;
	parameter STATE_RX = 1;
	parameter STATE_WORKING = 2;

	reg [1:0] state = 0;

	// uart definitions
	parameter CMD_RESET = 0;
	parameter CMD_SEND_BUFFER = 1;

	parameter RX_BUFFER_SIZE = 12;
	reg [7:0] rx_buffer [RX_BUFFER_SIZE-1:0];
	reg [3:0] rx_index;

	wire rx_ready;
	wire [7:0] rx_data;

	// tx stuff
	wire tx_active;
	reg tx_start;
	reg [7:0] tx_data;

	// debug tx stuff
	wire debug_tx_active;
	reg debug_tx_start;
	reg [15:0] debug_tx_data;

	// rx_buffer decode
	wire [N-1:0] c_real_init = {rx_buffer[0][5:0], rx_buffer[1], rx_buffer[2], rx_buffer[3]};
	wire [N-1:0] c_imag_init = {rx_buffer[4][5:0], rx_buffer[5], rx_buffer[6], rx_buffer[7]};
	wire [N-1:0] c_step = {rx_buffer[8][5:0], rx_buffer[9], rx_buffer[10], rx_buffer[11]};

	// mandelbrot state
	reg [N-1:0] c_real = 0;
	reg [N-1:0] c_imag = 0;

	reg [7:0] pos_x;
	reg [7:0] pos_y;

	reg mandelbrot_run = 0;
	wire [NC-1:0] mandelbrot_count;
	wire mandelbrot_done;

	reg [16:0] send_count = 0;

	// state machine

	// reg [2:0] cnt = 0;
	// always @(posedge CLK) begin
	// 	cnt <= cnt + 1;
	// end
	// wire clk = cnt[1];


	reg [23:0] led_counter = 0;
	assign LED = led_counter[22];


	always @(posedge CLK) begin
		tx_start <= 0;
		mandelbrot_run <= 0;
		debug_tx_start <= 0;
		led_counter <= led_counter + 1;

		case (state)
			STATE_IDLE: begin
				if (rx_ready) begin
					if (rx_data == CMD_SEND_BUFFER) begin
						state <= STATE_RX;
						rx_index <= 0;
					end
				end
			end
			STATE_RX: begin
				if (rx_ready) begin
					rx_buffer[rx_index] <= rx_data;

					if (rx_index == (RX_BUFFER_SIZE-1)) begin
						state <= STATE_WORKING;
						c_real <= c_real_init;
						c_imag <= c_imag_init;
						pos_x <= 0;
						pos_y <= 0;
						mandelbrot_run <= 1;
					end
					else
						rx_index <= rx_index + 1;
				end
			end
			STATE_WORKING: begin
				if (mandelbrot_done & (~mandelbrot_run)) begin
					if (!tx_active) begin
						tx_data <= mandelbrot_count;
						tx_start <= 1;
						send_count <= send_count + 1;

						if (pos_x == (BLOCK_SIZE - 1)) begin
							c_real <= c_real_init;
							c_imag[N-2:0] <= c_imag[N-2:0] + c_step[N-2:0];

							pos_x <= 0;
							pos_y <= pos_y + 1;
							if (pos_y == (BLOCK_SIZE - 1)) begin
								state = STATE_IDLE;
							end
						end else begin
							pos_x <= pos_x + 1;
							c_real[N-2:0] <= c_real[N-2:0] + c_step[N-2:0];
						end

						// debug_tx_data = {pos_x, pos_y};
						// debug_tx_start <= 1;

						if (state != STATE_IDLE) begin
							mandelbrot_run <= 1;
						end
					end
				end
			end
		endcase
	end

	mandelbrot #(
		.Q(Q),
		.N(N),
		.NC(NC)
		) mdbr(
		.clk(CLK),
		.c_real(c_real),
		.c_imag(c_imag),
		.count(mandelbrot_count),
		.run(mandelbrot_run),
		.done(mandelbrot_done)
		);

	uart_rx #(UART_DIV) rx(
		.i_Clock(CLK),
		.i_Rx_Serial(PIN_13),
		.o_Rx_Byte(rx_data),
		.o_Rx_DV(rx_ready)
		);
	uart_tx #(UART_DIV) tx(
		.i_Clock(CLK),
		.i_Tx_Byte(tx_data),
		.i_Tx_DV(tx_start),
		.o_Tx_Serial(PIN_12),
		.o_Tx_Active(tx_active)
		);

	// uart_tx_16 #(8) debug_tx(
	// 	.i_Clock(CLK),
	// 	.i_Tx_Byte(debug_tx_data),
	// 	.i_Tx_DV(debug_tx_start),
	// 	.o_Tx_Serial(PIN_14),
	// 	.o_Tx_Active(debug_tx_active)
	// 	);
endmodule
