`timescale 1ns / 1ps


module SVPWM #(
        parameter integer PWM_WIDTH = 16
    ) (
        input clk,
        input rstn,
        input [PWM_WIDTH*2-1:0] alpha_beat_tdata,
        input alpha_beat_tvalid,

        output [PWM_WIDTH*3-1:0] pwm_out_tdata,
        output pwm_out_tvalid
    );

    // 10<1:1:8>
    localparam signed [PWM_WIDTH/2+1:0] SQRT3_BY_2 = $rtoi(1.732050807568877 / 2 * (2 ** (PWM_WIDTH / 2)));

    // 17<1:2:14>
    reg signed [PWM_WIDTH:0] alpha_tmp;
    reg signed [PWM_WIDTH:0] va[2:0];
    reg signed [PWM_WIDTH:0] vb[2:0];
    reg signed [PWM_WIDTH:0] vc[2:0];
    reg signed [PWM_WIDTH:0] mux;
    reg signed [PWM_WIDTH:0] vmax;
    reg signed [PWM_WIDTH:0] vmin;
    reg signed [PWM_WIDTH:0] vcom;

    // 16<1:1:14>
    reg [PWM_WIDTH-1:0] pwm_u;
    reg [PWM_WIDTH-1:0] pwm_v;
    reg [PWM_WIDTH-1:0] pwm_w;
    reg [4:0] valid_delay;

    // 17<1:2:14>  <- 16<1:1:14>
    wire signed [PWM_WIDTH:0] alpha = {
             alpha_beat_tdata[PWM_WIDTH*2-1], alpha_beat_tdata[PWM_WIDTH*2-1:PWM_WIDTH]
         };
    wire signed [PWM_WIDTH/2-1:0] beta = {alpha_beat_tdata[PWM_WIDTH-1:PWM_WIDTH/2]};

    assign pwm_out_tdata  = {pwm_u, pwm_v, pwm_w};
    assign pwm_out_tvalid = valid_delay[4];

    function [PWM_WIDTH:0] MAX;
        input signed [PWM_WIDTH:0] a;
        input signed [PWM_WIDTH:0] b;
        begin
            if (a > b)
                MAX = a;
            else
                MAX = b;
        end
    endfunction

    function [PWM_WIDTH:0] MIN;
        input signed [PWM_WIDTH:0] a;
        input signed [PWM_WIDTH:0] b;
        begin
            if (a < b)
                MIN = a;
            else
                MIN = b;
        end
    endfunction

    always @(posedge clk) begin
        if (!rstn) begin
            alpha_tmp <= 0;
            va[0] <= 0;
            vb[0] <= 0;
            vc[0] <= 0;
            va[1] <= 0;
            vb[1] <= 0;
            vc[1] <= 0;
            va[2] <= 0;
            vb[2] <= 0;
            vc[2] <= 0;
            mux <= 0;
            vmax <= 0;
            vmin <= 0;
            vcom <= 0;
            pwm_u <= 0;
            pwm_v <= 0;
            pwm_w <= 0;
            valid_delay <= 0;
        end
        else begin
            // valid delay
            valid_delay <= valid_delay << 1 | alpha_beat_tvalid;

            // 1
            mux <= beta * SQRT3_BY_2;
            alpha_tmp <= alpha;

            // 2
            va[0] <= alpha_tmp;
            vb[0] <= -alpha_tmp / 2 + mux;
            vc[0] <= -alpha_tmp / 2 - mux;

            // 3
            vmax <= MAX(va[0], MAX(vb[0], vc[0]));
            vmin <= MIN(va[0], MIN(vb[0], vc[0]));
            va[1] <= va[0] * 2;
            vb[1] <= vb[0] * 2;
            vc[1] <= vc[0] * 2;

            // 4
            vcom <= vmax + vmin;
            va[2] <= va[1] + (2 ** (PWM_WIDTH - 1));
            vb[2] <= vb[1] + (2 ** (PWM_WIDTH - 1));
            vc[2] <= vc[1] + (2 ** (PWM_WIDTH - 1));

            // 5
            pwm_u <= vcom - va[2];
            pwm_v <= vcom - vb[2];
            pwm_w <= vcom - vc[2];
        end
    end


endmodule

