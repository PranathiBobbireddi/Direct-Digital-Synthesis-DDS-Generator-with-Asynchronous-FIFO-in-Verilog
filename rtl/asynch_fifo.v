`timescale 1ns / 1ps

//==============================================================================
// ASYNCHRONOUS FIFO MODULE
// Synthesizable 16-deep, 16-bit wide dual-clock FIFO design using Gray code
// pointers and 2-stage flip-flop synchronizers for CDC safety.
//==============================================================================
module asynch_fifo (
    input  wire        reset,
    input  wire        wr_clk,
    input  wire        rd_clk,
    input  wire        wr_enb,
    input  wire        rd_enb,
    input  wire [15:0] fifo_din,
    
    output reg  [15:0] fifo_dout,
    output wire        full,
    output wire        empty
);

    // 1. Memory Array (Depth = 16, Width = 16)
    reg [15:0] mem[0:15];
    
    // 2. Binary Pointers (5 bits to track full/empty conditions for depth 16)
    reg [4:0] wr_ptr_bin;
    reg [4:0] rd_ptr_bin;
    
    // 3. Gray Pointers
    reg [4:0] wr_ptr_gray;
    reg [4:0] rd_ptr_gray;
    
    // 4. Synchronizer Registers (2-stage Flip-Flops for Cross Clock Domain)
    reg [4:0] rd_gray_sync1, rd_gray_sync2;
    reg [4:0] wr_gray_sync1, wr_gray_sync2;

    // 5. Next Pointer Logic
    wire [4:0] wr_bin_next;
    wire [4:0] wr_gray_next;
    wire [4:0] rd_bin_next;
    wire [4:0] rd_gray_next;
    
    assign wr_bin_next  = wr_ptr_bin + 5'd1;
    assign wr_gray_next = wr_bin_next ^ (wr_bin_next >> 1);
    
    assign rd_bin_next  = rd_ptr_bin + 5'd1;
    assign rd_gray_next = rd_bin_next ^ (rd_bin_next >> 1);

    // 6. Write Logic
    always @(posedge wr_clk or posedge reset) begin
        if (reset) begin
            wr_ptr_bin  <= 5'd0;
            wr_ptr_gray <= 5'd0;
        end 
        else if (wr_enb && !full) begin
            mem[wr_ptr_bin[3:0]] <= fifo_din; // Lower 4 bits map to 0-15 memory index
            wr_ptr_bin           <= wr_bin_next;
            wr_ptr_gray          <= wr_gray_next;
        end
    end

    // 7. Read Logic
    always @(posedge rd_clk or posedge reset) begin
        if (reset) begin
            rd_ptr_bin  <= 5'd0;
            rd_ptr_gray <= 5'd0;
            fifo_dout   <= 16'd0;
        end 
        else if (rd_enb && !empty) begin
            fifo_dout   <= mem[rd_ptr_bin[3:0]]; // Lower 4 bits map to 0-15 memory index
            rd_ptr_bin  <= rd_bin_next;
            rd_ptr_gray <= rd_gray_next;
        end
    end

    // 8. Synchronizer Logic: Passing Read Pointer (Gray) into Write Clock Domain
    always @(posedge wr_clk or posedge reset) begin
        if (reset) begin
            rd_gray_sync1 <= 5'd0;
            rd_gray_sync2 <= 5'd0;
        end else begin
            rd_gray_sync1 <= rd_ptr_gray;
            rd_gray_sync2 <= rd_gray_sync1;
        end
    end

    // 9. Synchronizer Logic: Passing Write Pointer (Gray) into Read Clock Domain
    always @(posedge rd_clk or posedge reset) begin
        if (reset) begin
            wr_gray_sync1 <= 5'd0;
            wr_gray_sync2 <= 5'd0;
        end else begin
            wr_gray_sync1 <= wr_ptr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
        end
    end

    // 10. Status Flags
    assign empty = (rd_ptr_gray == wr_gray_sync2);
    assign full  = (wr_ptr_gray == {~rd_gray_sync2[4], ~rd_gray_sync2[3], rd_gray_sync2[2:0]});

endmodule
