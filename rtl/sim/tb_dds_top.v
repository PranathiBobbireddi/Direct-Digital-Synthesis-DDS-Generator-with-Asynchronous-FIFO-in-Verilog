`timescale 1ns / 1ps

//==============================================================================
// SYSTEM TESTBENCH: tb_dds_top
// Multi-clock testbench driving dynamic frequency scaling and CDC verification
//==============================================================================
module tb_dds_top;

    // 1. Testbench Signals
    reg        dds_clk;       // Fast Write Clock (100 MHz)
    reg        fifo_rd_clk;   // Read Clock (25 MHz)
    reg        reset;         // Active-High Reset
    reg [15:0] phase_inc;     // Frequency control step size
    reg        rd_enb;        // Read enable control

    wire [15:0] fifo_dout;    // Buffered Sine Wave output
    wire        full;         // FIFO Full flag
    wire        empty;        // FIFO Empty flag

    // 2. Instantiate Unit Under Test (UUT)
    dds_top uut (
        .dds_clk     (dds_clk),
        .fifo_rd_clk (fifo_rd_clk),
        .reset       (reset),
        .phase_inc   (phase_inc),
        .rd_enb      (rd_enb),
        .fifo_dout   (fifo_dout),
        .full        (full),
        .empty       (empty)
    );

    // 3. Clock Generation Logic
    
    // 100 MHz DDS Clock (Period = 10ns -> Toggle every 5ns)
    always #5 dds_clk = ~dds_clk;

    // 25 MHz FIFO Read Clock (Period = 40ns -> Toggle every 20ns)
    always #20 fifo_rd_clk = ~fifo_rd_clk;

    // 4. Stimulus Process
    initial begin
        // --- Step 1: Initialize Inputs ---
        dds_clk     = 0;
        fifo_rd_clk = 0;
        reset       = 1;
        rd_enb      = 0;
        phase_inc   = 16'd2000; // Set initial frequency step size

        // --- Step 2: Apply System Reset ---
        #300;                   // Ensure reset covers both clock domain periods
        reset = 0;              // Release reset
        $display("[%0t ns] System Reset Released. Starting DDS Generation...", $time);

        // --- Step 3: Allow FIFO to fill up from DDS ---
        #500;

        // --- Step 4: Start Reading from FIFO ---
        $display("[%0t ns] Enabling Read operations from FIFO...", $time);
        @(posedge fifo_rd_clk);
        rd_enb = 1;

        #2000;

        // --- Step 5: Test Dynamic Frequency Change ---
        $display("[%0t ns] Changing Phase Increment (Increasing Frequency)...", $time);
        phase_inc = 16'd5000;   // Step size increased -> Higher output frequency

        #3000;

        // --- Step 6: Pause Reading to observe FIFO Full flag ---
        $display("[%0t ns] Disabling Read Enable to test FIFO Full condition...", $time);
        @(posedge fifo_rd_clk);
        rd_enb = 0;

        #1000;

        // --- Step 7: Complete Simulation ---
        $display("[%0t ns] Simulation Complete!", $time);
        $finish;
    end

    // 5. Monitor Output Data in Console
    always @(posedge fifo_rd_clk) begin
        if (rd_enb && !empty) begin
            $display("[%0t ns] READ DATA: %d | Empty Flag: %b | Full Flag: %b", 
                      $time, $signed(fifo_dout), empty, full);
        end
    end

endmodule
