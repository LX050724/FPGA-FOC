`timescale 1ns / 1ps

module top (
        input clk_in,
        input rst,
        output [1:0] events_out,
        output [2:0] pwm_h,
        output [2:0] pwm_l
    );

    localparam FARCTIONAL_BITS = 15;
    localparam FARCTIONAL_SHIFT = (2 ** FARCTIONAL_BITS);

    localparam real M_PI = 3.14159265358979323846;
    localparam signed [17:0] PI_BY_2 = $rtoi((M_PI / 2) * FARCTIONAL_SHIFT);
    localparam signed [17:0] PI = $rtoi((M_PI) * FARCTIONAL_SHIFT);
    localparam signed [17:0] add = $rtoi((M_PI / 10) * FARCTIONAL_SHIFT);

    wire rstn = ~rst;
    wire clk;
    wire [33:0] sin_cos_tdata;
    wire sin_cos_tvalid;
    wire [47:0] pwm_out_tdata;
    wire pwm_out_tvalid;


    Gowin_PLL main_pll (
                  .clkout0(clk),    //output clkout0
                  .clkin  (clk_in)  //input clkin
              );


    reg signed [17:0] cnt = -PI_BY_2;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt <= -PI;
        end
        else begin
            if (events_out[0]) begin
                if (cnt < PI)
                    cnt <= cnt + 1'd1;
                else
                    cnt <= -PI;
            end
        end
    end

    sin_cos sin_cos_i (
                .clk(clk),
                .rstn(rstn),
                .theta_tdata(cnt),
                .theta_tvalid(events_out[0]),
                .sin_cos_tdata(sin_cos_tdata),
                .sin_cos_tvalid(sin_cos_tvalid)
            );

    // 16<1:0:15>
    // localparam signed [15:0] L1 = $rtoi(1.0 * (2 ** 15));
    // localparam signed [15:0] L2 = $rtoi(0.9 * (2 ** 15));
    // localparam signed [15:0] L3 = $rtoi(0.1 * (2 ** 15));

    wire [15:0] alpha = sin_cos_tdata[33:33-15];
    wire [15:0] beat = sin_cos_tdata[16:1];
    wire alpha_beat_tvalid = sin_cos_tvalid;

    SVPWM svpwm(
              .clk(clk),
              .rstn(rstn),
              .alpha_beat_tdata({alpha, beat}),
              .alpha_beat_tvalid(alpha_beat_tvalid),
              .pwm_out_tdata(pwm_out_tdata),
              .pwm_out_tvalid(pwm_out_tvalid)
          );

    PWM_Controller#(
                      .PWMH_ACTIVE_LEVEL(1),
                      .PWML_ACTIVE_LEVEL(1),
                      .PWM_RELOAD(4999), // 20KHz
                      .DEAT_TIME(5) // 50ns
                  ) pwm (
                      .clk(clk),
                      .rstn(rstn),
                      .events_out(events_out),
                      .brake(1'b0),
                      .axis_tvalid(pwm_out_tvalid),
                      .axis_tdata(pwm_out_tdata),
                      .events_comp({ 16'd0, 16'd2500 }),
                      .PWM_H(pwm_h),
                      .PWM_L(pwm_l)
                  );

endmodule
