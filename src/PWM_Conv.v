`timescale 1ns / 1ps


module PWM_Conv #(
        parameter integer PWM_CHANNEL_NUM = 3,
        parameter integer PWM_WIDTH = 16,
        parameter [PWM_WIDTH-1:0] PWM_RELOAD = 5000
    ) (
        input clk,
        input rstn,
        input [PWM_CHANNEL_NUM*PWM_WIDTH-1:0] axis_tdata,
        input axis_tvalid,

        output [PWM_CHANNEL_NUM*PWM_WIDTH-1:0] comp1,
        output [PWM_CHANNEL_NUM*PWM_WIDTH-1:0] comp2
    );

    localparam signed [PWM_WIDTH-1:0] RESIZE =  $rtoi($itor(PWM_RELOAD) / ((2 ** PWM_WIDTH) * 2.0) * (2 ** (PWM_WIDTH - 1)));
    
    integer i;

    function [PWM_WIDTH-1:0] perunit_to_unsigned;
        input [PWM_WIDTH-1:0] D;
        begin
            perunit_to_unsigned = D * RESIZE / (2 ** (PWM_WIDTH - 1));
        end
    endfunction

    reg  [PWM_WIDTH-1:0] comp1_array[PWM_CHANNEL_NUM-1:0];
    reg  [PWM_WIDTH-1:0] comp2_array[PWM_CHANNEL_NUM-1:0];
    wire [PWM_WIDTH-1:0] pwm_array  [PWM_CHANNEL_NUM-1:0];

    genvar gi;
    generate
        for (gi = 0; gi < PWM_CHANNEL_NUM; gi = gi + 1) begin
            assign pwm_array[gi] = perunit_to_unsigned(axis_tdata[(gi+1)*PWM_WIDTH-1:gi*PWM_WIDTH]);
            assign comp1[(gi+1)*PWM_WIDTH-1:gi*PWM_WIDTH] = comp1_array[gi];
            assign comp2[(gi+1)*PWM_WIDTH-1:gi*PWM_WIDTH] = comp2_array[gi];
        end
    endgenerate


    always @(posedge clk) begin
        if (!rstn) begin
            for (i = 0; i < PWM_CHANNEL_NUM; i = i + 1) begin
                comp1_array[i] <= 0;
                comp2_array[i] <= 0;
            end
        end
        else begin
            if (axis_tvalid) begin
                for (i = 0; i < PWM_CHANNEL_NUM; i = i + 1) begin
                    comp1_array[i] <= (PWM_RELOAD / 2) - pwm_array[i]; //((pwm_array[i] * RESIZE) >> PWM_WIDTH);
                    comp2_array[i] <= (PWM_RELOAD / 2) + pwm_array[i]; //((pwm_array[i] * RESIZE) >> PWM_WIDTH);
                end
            end
        end

    end


endmodule
