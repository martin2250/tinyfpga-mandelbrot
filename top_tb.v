`timescale 1ns/1ps
module tb ();
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, tb);
    end

    parameter Q = 12;
    parameter N = 16;

    reg CLK;
    wire LED;

    reg [N-1:0] c_real = 16'b110000;
    reg [N-1:0] c_imag = 16'b110000;
    wire [7:0] count;

    reg run = 0;

    initial begin
        CLK = 1'b0;
        #1 run = 1;
        forever #1 CLK = ~CLK;
    end

    initial begin
        repeat(20000) @(posedge CLK);
        $finish;
    end


    initial begin
        repeat(2) @(posedge LED);
        $finish;
    end

    mandelbrot #(Q, N) mdbr(
        .clk(CLK),
        .c_real(c_real),
        .c_imag(c_imag),
        .count(count),
        .run(run),
        .done(LED)
        );
endmodule
