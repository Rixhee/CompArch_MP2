`timescale 10ns/10ns
`include "top.sv"

module fade_tb;
    
    parameter PWM_INTERVAL = 1000;

    logic clk = 0;

    // Keeping track of the same PWM but for all colors
    logic [$clog2(PWM_INTERVAL) - 1: 0] red_pwm_value;
    logic [$clog2(PWM_INTERVAL) - 1: 0] green_pwm_value;
    logic [$clog2(PWM_INTERVAL) - 1: 0] blue_pwm_value;

    top # (
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u0 (
        .clk (clk)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, fade_tb);
        #100000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

    // Update specific color's PWM value based on current state
    always_comb begin
        case (u0.current_state)
            u0.GREEN_INC: begin
                green_pwm_value = u0.pwm_value;
                red_pwm_value = PWM_INTERVAL;
                blue_pwm_value = 0;
            end
            u0.RED_DEC: begin
                green_pwm_value = PWM_INTERVAL;
                red_pwm_value = u0.pwm_value;
                blue_pwm_value = 0;
            end
            u0.BLUE_INC: begin
                green_pwm_value = PWM_INTERVAL;
                red_pwm_value = 0;
                blue_pwm_value = u0.pwm_value;
            end
            u0.GREEN_DEC: begin
                green_pwm_value = u0.pwm_value;
                red_pwm_value = 0;
                blue_pwm_value = PWM_INTERVAL;
            end
            u0.RED_INC: begin
                green_pwm_value = 0;
                red_pwm_value = u0.pwm_value;
                blue_pwm_value = PWM_INTERVAL;
            end
            u0.BLUE_DEC: begin
                green_pwm_value = 0;
                red_pwm_value = PWM_INTERVAL;
                blue_pwm_value = u0.pwm_value;
            end
        endcase
    end
endmodule
