`include "fade.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL = 1000,
    parameter ONE_SECOND = 12000000,
    parameter STATE_TRANSITION_INTERVAL = ONE_SECOND / 6 // Change the state every 0.167s for controlling different colors
)
(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    // Defining variabels to keep track of clock count and pwm
    logic [$clog2(PWM_INTERVAL) - 1: 0] pwm_value;
    logic [$clog2(STATE_TRANSITION_INTERVAL) - 1: 0] count;
    logic pwm_out;

    // Defining various states for changing RGB values 
    localparam GREEN_INC = 3'b000;
    localparam RED_DEC = 3'b001;
    localparam BLUE_INC = 3'b010;
    localparam GREEN_DEC = 3'b011;
    localparam RED_INC = 3'b100;
    localparam BLUE_DEC = 3'b101;

    logic [2:0] current_state = GREEN_INC;
    logic [2:0] next_state;
    logic time_to_switch_state;

    initial begin
        count = 0;
    end

    // Updating next state and setting RGB values according to current state
    always_comb begin
        next_state = 3'bxxx;
        RGB_R = 1'b1;
        RGB_G = 1'b1;
        RGB_B = 1'b1;
        
        case (current_state)
            GREEN_INC: begin
                RGB_R = 1'b0;
                RGB_G = ~pwm_out;
                RGB_B = 1'b1;
                next_state = RED_DEC;
            end
            RED_DEC: begin
                RGB_R = ~pwm_out;
                RGB_G = 1'b0;
                RGB_B = 1'b1;
                next_state = BLUE_INC;
            end
            BLUE_INC: begin
                RGB_R = 1'b1;
                RGB_G = 1'b0;
                RGB_B = ~pwm_out;
                next_state = GREEN_DEC;
            end
            GREEN_DEC: begin
                RGB_R = 1'b1;
                RGB_G = ~pwm_out;
                RGB_B = 1'b0;
                next_state = RED_INC;
            end
            RED_INC: begin
                RGB_R = ~pwm_out;
                RGB_G = 1'b1;
                RGB_B = 1'b0;
                next_state = BLUE_DEC;
            end
            BLUE_DEC: begin
                RGB_R = 1'b0;
                RGB_G = 1'b1;
                RGB_B = ~pwm_out;
                next_state = GREEN_INC;
            end
            default: begin
                next_state = GREEN_INC;
            end
        endcase
    end

    // Updating the clock count and setting time_to_switch_state according to the interval
    always_ff @(posedge clk) begin
        if (count == ($clog2(STATE_TRANSITION_INTERVAL))'(STATE_TRANSITION_INTERVAL - 1)) begin
            count <= 0;
            time_to_switch_state <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_switch_state <= 1'b0;
        end
    end

    always_ff @(posedge time_to_switch_state) begin
        current_state <= next_state;
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

endmodule
