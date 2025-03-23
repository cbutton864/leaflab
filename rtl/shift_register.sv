module shift_register (
    input logic i_clk,
    input logic i_reset_n,
    input pipeline_types::shift_reg_input_t i_shift_reg,  // Input struct for shift register
    output logic [23:0] o_led_data,  // Output for the LED data (24 bits)
    output logic o_passthru_en  // Output for passthrough enable
);

    //////////////////////////////////////////////////////////////////////
    // Parameters and Constants
    localparam int WIDTH = 25;  // Fixed width of the shift register
    localparam logic [WIDTH-1:0] Cresetvalue = {{(WIDTH-1){1'b0}}, 1'b1};  // SR Reset value

    //////////////////////////////////////////////////////////////////////
    // State Machine Signals
    typedef enum logic [1:0] {
        SHIFT,
        PASSTHRU
    } state_t;  // FSM states

    state_t q_state, d_state;  // Current and next state

    //////////////////////////////////////////////////////////////////////
    // Shift Register Signals
    logic [WIDTH-1:0] r_shift_reg;  // Internal shift register (25 bits)

    //////////////////////////////////////////////////////////////////////
    // Control Signals
    logic w_passthru_en;  // Passthrough enable signal
    logic w_shift_en;  // Shift enable signal

    //////////////////////////////////////////////////////////////////////
    // FSM Logic
    // State transition logic
    //////////////////////////////////////////////////////////////////////
    always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
            q_state <= SHIFT;
        end else begin
            q_state <= d_state;
        end
    end

    //////////////////////////////////////////////////////////////////////
    // FSM Logic
    // Combinational process to determine the next state
    //////////////////////////////////////////////////////////////////////
    always_comb begin
        // Default next state
        d_state = q_state;
        case (q_state)
            SHIFT: begin
                // If the shift register's extra bit is high, transition to PASSTHRU
                if (r_shift_reg[0]) begin
                    d_state = PASSTHRU;
                end
            end
            PASSTHRU: begin
                // If the shift register's extra bit is low, transition back to SHIFT
                if (!r_shift_reg[0]) begin
                    d_state = SHIFT;
                end
            end
            default: begin
                d_state = SHIFT;  // Default state
            end
        endcase
    end

    //////////////////////////////////////////////////////////////////////
    // State Behavior Logic
    // Combinational process to manage control signals based on the state
    //////////////////////////////////////////////////////////////////////
    always_comb begin
        // Default Initial
        w_passthru_en = 1'b0;
        w_shift_en = 1'b0;
        case (q_state)
            SHIFT: begin
                // Allow the valid strobe to be forwarded as the shift enable
                w_shift_en = i_shift_reg.valid_strobe;
            end
            PASSTHRU: begin
                w_passthru_en = 1'b1;
                o_led_data = r_shift_reg[24:1]; // Output the upper 24-bits SR as LED data
            end
            default: begin
                // Default "other"
                w_passthru_en = 1'b0;
                w_shift_en = 1'b0;
            end
        endcase
    end

    //////////////////////////////////////////////////////////////////////
    // Shift Register Logic
    // This will manage the shift register operation based on the input signals
    ///////////////////////////////////////////////////////////////////////
    always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
            r_shift_reg <= Cresetvalue;
        end else if (i_shift_reg.treset) begin
            r_shift_reg <= Cresetvalue;
        end else if (i_shift_reg.valid) begin
            r_shift_reg <= {r_shift_reg[WIDTH-2:0], i_shift_reg.decode_bit};
        end
    end

    //////////////////////////////////////////////////////////////////////
    // Output Assignments
    assign o_passthru_en = w_passthru_en;  // Assign passthrough enable output

endmodule
