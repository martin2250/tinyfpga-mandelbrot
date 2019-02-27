module top (input CLK, output LED, input PIN_1, output USBPU);
    assign USBPU = 0;

    parameter Q = 12;
    parameter N = 16;

    reg [N-1:0] c_real = 16'b11000000;
    reg [N-1:0] c_imag = 16'b1100000;
    wire [7:0] count;
    reg run = 0;

    initial begin
        #100 run = 1;
    end

    mandelbrot #(Q, N) mdbr(
        .clk(CLK),
        .c_real(c_real),
        .c_imag(c_imag),
        .count(count),
        .run(PIN_1),
        .done(LED)
        );
endmodule
