`include "fade.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL = 1200,
    parameter ONE_SECOND = 12000000,
    parameter ONE_SIXTH = ONE_SECOND / 6,
    parameter TWO_SIXTH = ONE_SECOND / 3,
    parameter THREE_SIXTH = ONE_SECOND / 2,
    parameter FOUR_SIXTH = ONE_SECOND * 2 / 3,
    parameter FIVE_SIXTH = ONE_SECOND * 5 / 6
)
(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    logic [$clog2(PWM_INTERVAL) - 1: 0] pwm_value;
    logic [$clog2(ONE_SECOND) - 1: 0] count;
    logic pwm_out;

    initial begin
        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;
    end

    fade #(
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u1 (
        .clk (clk),
        .pwm_value (pwm_value)
    );

    pwm #(
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u2 (
        .clk (clk),
        .pwm_value (pwm_value),
        .pwm_out (pwm_out)
    );
    
    always_ff @(posedge clk) begin
        // Reset count every second
        if (count == ONE_SECOND - 1) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end

        // Set RGB values for each interval
        if (count < ONE_SIXTH) begin
            RGB_R = 1'b0;
            RGB_G = ~pwm_out;
            RGB_B = 1'b1;
        end else if (count < TWO_SIXTH) begin
            RGB_R = ~pwm_out;
            RGB_G = 1'b0;
            RGB_B = 1'b1;
        end else if (count < THREE_SIXTH) begin
            RGB_R = 1'b1;
            RGB_G = 1'b0;
            RGB_B = ~pwm_out;
        end else if (count < FOUR_SIXTH) begin
            RGB_R = 1'b1;
            RGB_G = ~pwm_out;
            RGB_B = 1'b0;
        end else if (count < FIVE_SIXTH) begin
            RGB_R = ~pwm_out;
            RGB_G = 1'b1;
            RGB_B = 1'b0;
        end else begin
            RGB_R = 1'b0;
            RGB_G = 1'b1;
            RGB_B = ~pwm_out;
        end
    end

endmodule
