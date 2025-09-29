module pwm #(
    parameter PWM_INTERVAL = 1200 // CLK frequency is 12Mhz, so the PWM cycle would complete every 100us
) (
    input logic clk,
    input logic [$clog2(PWM_INTERVAL) - 1: 0] pwm_value,
    output logic pwm_out
);

    // Counter for the output
    logic [$clog2(PWM_INTERVAL) - 1: 0] count = 0;

    always_ff @(posedge clk) begin
        // Reset counter after the PWM cycle completes
        if (count == (PWM_INTERVAL - 1)) begin
            count <= 0;
        end

        // Increase counter every clock cycle
        else begin
            count <= count + 1;
        end
    end

    // Output according to the counter and the input pwm value
    assign pwm_out = (count <= pwm_value) ? 1'b1 : 1'b0;

endmodule
