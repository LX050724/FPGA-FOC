`timescale 1ns / 1ps

module sin_cos (
        input clk,
        input rstn,

        input signed [17:0] theta_tdata,
        input theta_tvalid,

        output [17*2-1:0] sin_cos_tdata,
        output sin_cos_tvalid
    );

    localparam ITERATION = 17;
    localparam FARCTIONAL_BITS = 15;
    localparam FARCTIONAL_SHIFT = (2 ** FARCTIONAL_BITS);

    localparam [16:0] x_i = $rtoi(0.607253 * FARCTIONAL_SHIFT);
    localparam [16:0] y_i = 0;

    localparam real M_PI = 3.14159265358979323846;
    localparam signed [17:0] PI_BY_2 = $rtoi((M_PI / 2) * FARCTIONAL_SHIFT);
    localparam signed [17:0] PI = $rtoi((M_PI) * FARCTIONAL_SHIFT);

    reg [ITERATION-1:0] tvalid_delay;
    wire signed [16:0] sin_o;
    wire signed [16:0] cos_o;
    reg [ITERATION-1:0] quadrant;
    reg [16:0] cordic_core_thera_in;

    assign sin_cos_tvalid = tvalid_delay[ITERATION-1];
    assign sin_cos_tdata = {sin_o, quadrant[ITERATION-1] ? -cos_o : cos_o};

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            tvalid_delay <= 0;
            cordic_core_thera_in <= 0;
            quadrant <= 0;
        end
        else begin
            tvalid_delay <= tvalid_delay << 1 | theta_tvalid;
            if (theta_tvalid) begin
                if (theta_tdata > PI_BY_2) begin
                    cordic_core_thera_in <= -theta_tdata + PI;
                    quadrant <= quadrant << 1 | 1'b1;
                end
                else if (theta_tdata < -PI_BY_2) begin
                    cordic_core_thera_in <= -theta_tdata - PI;
                    quadrant <= quadrant << 1 | 1'b1;
                end
                else begin
                    cordic_core_thera_in <= theta_tdata;
                    quadrant <= quadrant << 1;
                end
            end else begin
                cordic_core_thera_in <= 0;
                quadrant <= quadrant << 1;
            end
        end
    end


    CORDIC_Top cordic_core (
                   .clk(clk),  //input clk
                   .rst(~rstn),  //input rst
                   .x_i(x_i),  //input [16:0] x_i
                   .y_i(y_i),  //input [16:0] y_i
                   .theta_i(cordic_core_thera_in),  //input [16:0] theta_i
                   .x_o(cos_o),  //output [16:0] x_o
                   .y_o(sin_o)  //output [16:0] y_o
                   //    .theta_o(theta_o) //output [16:0] theta_o
               );
endmodule

