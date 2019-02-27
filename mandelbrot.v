`timescale 1ns/1ps
module mandelbrot (
    input clk,
    input [N-1:0] c_real,
    input [N-1:0] c_imag,
    input run,
    output reg done,
    output reg [NC-1:0] count);

    // fixed point number of fractional bits
    parameter Q = 12;
    // fixed point number of total bits
    parameter N = 16;
    // number of bits for counter
    parameter NC = 8;

    reg [N-1:0] z_real = 0;
    reg [N-1:0] z_imag = 0;

    wire [N-1:0] z_real_new;
    wire [N-1:0] z_imag_new;

    wire [N-1:0] z_real_squared;
    wire [N-1:0] z_imag_squared;
    wire [N-1:0] z_abs_squared;
    wire [N-1:0] z_real_times_imag;

    wire [N-1:0] z_real_times_imag_times_two = {z_real_times_imag[N-1], z_real_times_imag[N-3:0], 1'b0};

    wire [N-1:0] real_sq_minus_imag_sq;

    wire [N-1:0] z_imag_squared_negative = {~z_imag_squared[N-1], z_imag_squared[N-2:0]};

    wire overflow = z_abs_squared[N-2:0] >= (1 << (Q + 1));

    initial begin
        done <= 1;
        count <= 0;
    end

    reg run_run = 0;
    reg run_clk = 1;

    always @ (posedge run) begin
        run_run <= ~run_run;
    end

    always @ (posedge clk) begin
        if (done) begin
            if (run_run == run_clk) begin
                run_clk = ~run_clk;
                count = 0;
                z_real = 0;
                z_imag = 0;
                done = 0;
            end
        end
        if (!done) begin
            if (overflow) begin
                done <= 1;
            end else begin
                z_real <= z_real_new;
                z_imag <= z_imag_new;
                count = count + 1;
                if (count == {NC{1'b1}})
                    done <= 1;
            end
        end
    end

    qmult #(Q, N) real_squarer (
        .i_multiplicand(z_real),
        .i_multiplier(z_real),
        .o_result(z_real_squared)
        );
    qmult #(Q, N) imag_squarer(
        .i_multiplicand(z_imag),
        .i_multiplier(z_imag),
        .o_result(z_imag_squared)
        );
    qmult #(Q, N) imag_real_mult(
        .i_multiplicand(z_real),
        .i_multiplier(z_imag),
        .o_result(z_real_times_imag)
        );
    qadd #(Q, N) new_imag_adder(
        .a(z_real_times_imag_times_two),
        .b(c_imag),
        .c(z_imag_new)
        );
    qadd #(Q, N) new_real_intermediate_adder(
        .a(z_real_squared),
        .b(z_imag_squared_negative),
        .c(real_sq_minus_imag_sq)
        );
    qadd #(Q, N) new_real_adder(
        .a(real_sq_minus_imag_sq),
        .b(c_real),
        .c(z_real_new)
        );
    qadd #(Q, N) z_abs_adder(
        .a(z_real_squared),
        .b(z_imag_squared),
        .c(z_abs_squared)
        );
endmodule
