`timescale 1ns / 1ps

//==============================================================================
// TOP LEVEL MODULE
// Connects Xilinx DDS Compiler IP (AXI4-Stream) to Asynchronous FIFO Buffer
//==============================================================================
module dds_top (
    input  wire        dds_clk,       // Fast Clock for DDS Core (e.g., 100 MHz)
    input  wire        fifo_rd_clk,   // Read Clock for FIFO domain (e.g., 25 MHz)
    input  wire        reset,         // Active High Reset
    input  wire [15:0] phase_inc,     // Phase Increment (Controls output frequency)
    input  wire        rd_enb,        // Read Enable from external system
    
    output wire [15:0] fifo_dout,     // Buffered Sine Wave output
    output wire        full,          // FIFO Full flag
    output wire        empty          // FIFO Empty flag
);

    // Internal Wires between DDS IP and FIFO
    wire [15:0] sine_data;
    wire        sine_valid;
    reg         phase_tvalid;

    // Enable DDS streaming after reset release
    always @(posedge dds_clk or posedge reset) begin
        if (reset) begin
            phase_tvalid <= 1'b0;
        end else begin
            phase_tvalid <= 1'b1;
        end
    end

    // 1. Instantiate Xilinx DDS Compiler IP
    dds_compiler_0 your_dds_ip_inst (
        .aclk                  (dds_clk),
        .s_axis_phase_tvalid   (phase_tvalid),
        .s_axis_phase_tdata    (phase_inc),
        .m_axis_data_tvalid    (sine_valid),
        .m_axis_data_tdata     (sine_data)
    );

    // 2. Instantiate Asynchronous FIFO
    asynch_fifo dds_fifo_inst (
        .reset     (reset),
        .wr_clk    (dds_clk),         // Write domain matches DDS clock
        .rd_clk    (fifo_rd_clk),      // Read domain driven by external clock
        .wr_enb    (sine_valid),      // Push data into FIFO when DDS valid is HIGH
        .rd_enb    (rd_enb),
        .fifo_din  (sine_data),       // Connect DDS sine output to FIFO input
        .fifo_dout (fifo_dout),
        .full      (full),
        .empty     (empty)
    );

endmodule
