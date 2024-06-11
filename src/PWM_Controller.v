`timescale 1ns / 1ps

module PWM_Controller #(
        parameter integer PWM_CHANNEL_NUM = 3,
        parameter integer EVENT_CHANNEL_NUM = 2,
        parameter integer PWM_WIDTH = 16,
        parameter integer PWMH_ACTIVE_LEVEL = 1,
        parameter integer PWML_ACTIVE_LEVEL = 1,
        parameter [PWM_WIDTH-1:0] PWM_RELOAD = 5000,
        parameter [PWM_WIDTH-1:0] DEAT_TIME = 100
    ) (
        input clk,
        input rstn,
        input [PWM_CHANNEL_NUM*PWM_WIDTH-1:0] axis_tdata,
        input axis_tvalid,
        input brake,
        input [PWM_WIDTH*EVENT_CHANNEL_NUM-1:0] events_comp,
        output [PWM_CHANNEL_NUM-1:0] PWM_H,
        output [PWM_CHANNEL_NUM-1:0] PWM_L,
        output [EVENT_CHANNEL_NUM-1:0] events_out
    );

    reg [PWM_WIDTH-1:0] cnt;

    genvar gi;
    // integer i;

    generate
        for (gi = 0; gi < EVENT_CHANNEL_NUM; gi = gi + 1) begin: events_out_genloop
            assign events_out[gi] = cnt == events_comp[(gi+1)*PWM_WIDTH-1:gi*PWM_WIDTH] ? 1'b1 : 1'b0;
        end
    endgenerate

    always @(posedge clk) begin
        if (!rstn) begin
            cnt <= 0;
        end
        else begin
            if (cnt < PWM_RELOAD)
                cnt <= cnt + 1;
            else
                cnt <= 0;
        end
    end

    wire [PWM_CHANNEL_NUM*PWM_WIDTH-1:0] comp1;
    wire [PWM_CHANNEL_NUM*PWM_WIDTH-1:0] comp2;

    PWM_Conv #(
                 .PWM_CHANNEL_NUM(PWM_CHANNEL_NUM),
                 .PWM_WIDTH(PWM_WIDTH),
                 .PWM_RELOAD(PWM_RELOAD)
             ) pwm_conv_0 (
                 .clk(clk),
                 .rstn(rstn),
                 .axis_tdata(axis_tdata),
                 .axis_tvalid(axis_tvalid),

                 .comp1 (comp1),
                 .comp2 (comp2)
             );

    generate
        for (gi = 0; gi < PWM_CHANNEL_NUM; gi = gi + 1) begin: pwm_genloop
            wire [PWM_WIDTH-1:0] pwm_comp1 = comp1[(gi+1)*PWM_WIDTH-1:gi*PWM_WIDTH];
            wire [PWM_WIDTH-1:0] pwm_comp2 = comp2[(gi+1)*PWM_WIDTH-1:gi*PWM_WIDTH];

            PWM #(
                    .PWM_WIDTH(PWM_WIDTH),
                    .PWMH_ACTIVE_LEVEL(PWMH_ACTIVE_LEVEL),
                    .PWML_ACTIVE_LEVEL(PWML_ACTIVE_LEVEL),
                    .DEAT_TIME(DEAT_TIME)
                ) pwm (
                    .clk(clk),
                    .rstn(rstn),
                    .brake(brake),
                    .cnt(cnt),
                    .comp1(pwm_comp1),
                    .comp2(pwm_comp2),
                    .PWM_H(PWM_H[gi]),
                    .PWM_L(PWM_L[gi])
                );
        end
    endgenerate


endmodule
