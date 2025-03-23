/*
-----------------------------------------------------------------------------
Module Name: reshaper
Description: Generates the ws2812 serial output signal, then uses an internal
counter to reshape the signal if its short of the ideal timing. This module will
reproduce the input signal by driving high when a rising edge is detected and will
drive low when a falling edge is detected, unless the threshold has not been met. In that case,
the signal will be held high until the threshold is met.

Author: Curtis Button
Date: March 19, 2025
-----------------------------------------------------------------------------
*/

module reshaper (
    input logic i_clk,             // Clock input
    input logic i_reset_n,         // Active low reset
    input logic i_rising,          // Synchronized rising edge for LED control
    input logic i_falling,         // Synchronized falling edge for LED control
    output logic o_reshaped_signal // Reshaped output signal
);

    //////////////////////////////////////////////////////////////////////
    // Parameters and Constants
    //////////////////////////////////////////////////////////////////////
    localparam int Cwidthcounter = 8;  // Fixed width of the counter

    import timing_constants::*;
    timing_params_t #(Cwidthcounter) timing;

    // FSM States
    typedef enum logic [1:0] {
        SERIAL_LOW,       // Drive the signal low
        SERIAL_HIGH,      // Drive the signal high
        WAIT_FOR_T0L,  // Wait for T0L timing to be met
        WAIT_FOR_T0H   // Wait for T0H timing to be met
    } state_t;

    //////////////////////////////////////////////////////////////////////
    // Internal Signals
    //////////////////////////////////////////////////////////////////////
    state_t q_state, d_state;               // Current and next state
    logic [Cwidthcounter-1:0] r_counter;    // Internal counter register

    //////////////////////////////////////////////////////////////////////
    // State Register (Sequential Process)
    //////////////////////////////////////////////////////////////////////
    always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
            q_state <= SET_LOW;  // Reset to initial state
        end else begin
            q_state <= d_state;  // Update the current state
        end
    end

    //////////////////////////////////////////////////////////////////////
    // Next State Logic (Combinational Process)
    //////////////////////////////////////////////////////////////////////
    always_comb begin
        // Default next state
        d_state = q_state;

        case (q_state)
            SERIAL_HIGH: begin
                if (i_falling && r_counter < timing.T0H_CYCLES) begin
                    d_state = WAIT_FOR_T0H;  // Transition to wait for T0H
                end
                else if (i_falling && r_counter >= timing.T0H_CYCLES) begin
                    d_state = SERIAL_LOW;
                end
                else if (i_falling && r_counter < timing.T1H_CYCLES) begin
                    d_state = WAIT_FOR_T0H;  // Transition to wait for T0H
                end
                else if (i_falling && r_counter >= timing.T1H_CYCLES) begin
                    d_state = SERIAL_LOW;
                end
            end

            WAIT_FOR_T0H: begin
                if (r_counter >= timing.T0H_CYCLES) begin
                    d_state = SET_LOW;  // Transition to drive low
                end
            end

            SET_LOW: begin
                if (i_falling) begin
                    d_state = WAIT_FOR_T0L;  // Transition to wait for T0L
                end
            end

            WAIT_FOR_T0L: begin
                if (r_counter >= timing.T1H_CYCLES) begin
                    d_state = SET_HIGH;  // Transition to drive high
                end
            end

            default: begin
                d_state = SET_LOW;  // Default state
            end
        endcase
    end

    //////////////////////////////////////////////////////////////////////
    // Output Logic (Combinational Process)
    //////////////////////////////////////////////////////////////////////
    always_comb begin
        // Default outputs
        o_reshaped_signal = 1'b0;

        case (q_state)
            SET_HIGH: begin
                o_reshaped_signal = 1'b1;  // Drive the signal high
            end

            WAIT_FOR_T0H: begin
                o_reshaped_signal = 1'b1;  // Hold the signal high
            end

            SET_LOW: begin
                o_reshaped_signal = 1'b0;  // Drive the signal low
            end

            WAIT_FOR_T0L: begin
                o_reshaped_signal = 1'b0;  // Hold the signal low
            end
        endcase
    end

    //////////////////////////////////////////////////////////////////////
    // Counter Logic (Sequential Process)
    //////////////////////////////////////////////////////////////////////
    always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
            r_counter <= '0;  // Reset the counter
        end else begin
            if (q_state == WAIT_FOR_T0L || q_state == WAIT_FOR_T0H) begin
                r_counter <= r_counter + 1;  // Increment the counter in WAIT states
            end else begin
                r_counter <= '0;  // Reset the counter in other states
            end
        end
    end
endmodule