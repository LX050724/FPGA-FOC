`timescale 1ns / 1ps

module PWM #(
        parameter PWM_WIDTH = 16,
        parameter [0:0] PWMH_ACTIVE_LEVEL = 1'b1,
        parameter [0:0] PWML_ACTIVE_LEVEL = 1'b1,
        parameter [PWM_WIDTH-1:0] DEAT_TIME = 100
    ) (
        input clk,
        input rstn,
        input brake,
        input [PWM_WIDTH-1:0] cnt,
        input [PWM_WIDTH-1:0] comp1,
        input [PWM_WIDTH-1:0] comp2,
        output PWM_H,
        output PWM_L
    );


    localparam [1:0] STATE_HOLD_L   = 2'd0;
    localparam [1:0] STATE_HOLD_H   = 2'd1;
    localparam [1:0] STATE_CHANGE_L = 2'd2;
    localparam [1:0] STATE_CHANGE_H = 2'd3;


    reg PWM_H_reg, PWM_L_reg;
    reg [1:0] deat_state;
    reg [PWM_WIDTH-1:0] dcnt;

    assign PWM_H = (PWM_H_reg && !brake) ? PWMH_ACTIVE_LEVEL : ~PWMH_ACTIVE_LEVEL;
    assign PWM_L = (PWM_L_reg && !brake) ? PWML_ACTIVE_LEVEL : ~PWML_ACTIVE_LEVEL;

    assign comp1_val = cnt <= comp1;
    assign comp2_val = cnt <= comp2;
    assign pwm_state = (comp1_val ^ comp2_val);

    always @(posedge clk) begin
        if (!rstn) begin
            PWM_L_reg <= 0;
            PWM_H_reg <= 0;
            dcnt <= 0;
            deat_state <= STATE_HOLD_L;
        end
        else begin
            case (deat_state)
                STATE_HOLD_L: begin
                    PWM_H_reg <= 0;
                    PWM_L_reg <= 1;
                    if (pwm_state == 1) begin
                        deat_state <= STATE_CHANGE_H;
                        dcnt <= 0;
                    end
                end

                STATE_HOLD_H: begin
                    PWM_H_reg <= 1;
                    PWM_L_reg <= 0;
                    if (pwm_state == 0) begin
                        deat_state <= STATE_CHANGE_L;
                        dcnt <= 0;
                    end
                end

                STATE_CHANGE_L: begin
                    dcnt <= dcnt + 1;
                    PWM_H_reg <= 0;
                    PWM_L_reg <= 0;
                    if (dcnt == DEAT_TIME) begin
                        dcnt <= 0;
                        PWM_H_reg <= 0;
                        PWM_L_reg <= 1;
                        deat_state <= STATE_HOLD_L;
                    end
                    else if (pwm_state == 1) begin
                        PWM_H_reg  <= 1;
                        PWM_L_reg  <= 0;
                        deat_state <= STATE_HOLD_H;
                    end
                end

                STATE_CHANGE_H: begin
                    dcnt <= dcnt + 1;
                    PWM_H_reg <= 0;
                    PWM_L_reg <= 0;
                    if (dcnt == DEAT_TIME) begin
                        dcnt <= 0;
                        PWM_H_reg <= 1;
                        PWM_L_reg <= 0;
                        deat_state <= STATE_HOLD_H;
                    end
                    else if (pwm_state == 0) begin
                        PWM_H_reg  <= 0;
                        PWM_L_reg  <= 1;
                        deat_state <= STATE_HOLD_L;
                    end
                end
            endcase
        end
    end

endmodule
