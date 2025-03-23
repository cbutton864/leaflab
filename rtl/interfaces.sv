interface fifo_if (
    input logic i_clk,       // Clock signal
    input logic i_reset_n    // Active low reset
);

    // FIFO signals
    logic i_data;            // Input data (single bit)
    logic i_write;           // Write enable
    logic o_data;            // Output data (single bit)
    logic o_read;            // Read enable
    logic o_empty;           // FIFO empty flag
    logic o_full;            // FIFO full flag

    // Modports for directionality
    modport producer (
        input  i_data,       // Producer writes data
        input  i_write,      // Producer asserts write enable
        output o_full        // Producer checks if FIFO is full
    );

    modport consumer (
        output o_data,       // Consumer reads data
        input  o_read,       // Consumer asserts read enable
        output o_empty       // Consumer checks if FIFO is empty
    );

endinterface
