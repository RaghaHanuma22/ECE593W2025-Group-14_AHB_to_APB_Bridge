///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Slave Interface
// 
// Description:
// This module implements the AHB (Advanced High-performance Bus) slave interface.
// It includes address and data pipelining, valid signal generation, and tempsel (temporary select)
// signal generation logic. The module ensures proper handling of AHB transactions and
// interfaces with the AHB-to-APB bridge.
// 
// Key Features:
// - Address and data pipelining for timing optimization.
// - Valid signal generation based on address range and transaction type.
// - Tempsel signal generation for selecting the appropriate APB slave.
// 
// Inputs:
// - clk: System clock.
// - rst_n: Active-low reset signal.
// - br: AHB slave interface signals (from AHB-to-APB bridge).
// 
// Outputs:
// - haddr1, haddr2: Pipelined address signals.
// - hwdata1, hwdata2: Pipelined write data signals.
// - valid: Indicates a valid AHB transaction.
// - hwritereg: Pipelined write signal.
// - tempsel: Temporary select signal for APB slave selection.
// 
///////////////////////////////////////////////////////////////////////////////////////////

module AHB_slave_interface (
    ahb2apb_interface.ahb_slave br,  // AHB slave interface
    input  logic             clk,    // System clock
    input  logic             rst_n,  // Active-low reset
    output logic [31:0]      haddr1, haddr2,   // Pipelined address signals
    output logic [31:0]      hwdata1, hwdata2, // Pipelined write data signals
    output logic             valid,            // Valid transaction signal
    output logic             hwritereg,        // Pipelined write signal
    output logic [2:0]       tempsel           // Temporary select signal for APB slave
);

    // ** Address Pipelining **
    // Pipeline the AHB address to improve timing and handle address changes.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset pipelined addresses to 0
            haddr1 <= '0;
            haddr2 <= '0;
        end else begin
            // Update pipelined addresses
            haddr1 <= br.haddr;  // Capture current address
            haddr2 <= haddr1;    // Pipeline to second stage
        end
    end

    // ** Data Pipelining **
    // Pipeline the AHB write data to improve timing and handle data changes.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset pipelined write data to 0
            hwdata1 <= '0;
            hwdata2 <= '0;
        end else begin
            // Update pipelined write data
            hwdata1 <= br.hwdata;  // Capture current write data
            hwdata2 <= hwdata1;    // Pipeline to second stage
        end
    end

    // ** Write Signal Pipelining **
    // Pipeline the AHB write signal to align with pipelined address and data.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            // Reset pipelined write signal to 0
            hwritereg <= '0;
        else
            // Update pipelined write signal
            hwritereg <= br.hwrite;  // Capture current write signal
    end

    // ** Valid Generation Logic **
    // Generate the valid signal based on address range and transaction type.
    always_comb begin
        valid = '0;  // Default to invalid transaction
        if (rst_n && br.hreadyin &&  // Check if reset is inactive and master is ready
            (br.haddr >= 32'h8000_0000 && br.haddr < 32'h8C00_0000) &&  // Check address range
            (br.htrans == 2'b10 || br.htrans == 2'b11)) begin  // Check transaction type (NONSEQ or SEQ)
            valid = 1'b1;  // Signal valid transaction
        end else
            valid = 1'b0;  // Signal invalid transaction
    end

    // ** Tempsel Generation Logic **
    // Generate the tempsel signal to select the appropriate APB slave based on address range.
    always_comb begin
        tempsel = '0;  // Default to no selection
        if (rst_n) begin
            // Select APB slave based on address range
            if (br.haddr >= 32'h8000_0000 && br.haddr < 32'h8400_0000)
                tempsel = 3'b001;  // Select slave 1
            else if (br.haddr >= 32'h8400_0000 && br.haddr < 32'h8800_0000)
                tempsel = 3'b010;  // Select slave 2
            else if (br.haddr >= 32'h8800_0000 && br.haddr < 32'h8C00_0000)
                tempsel = 3'b100;  // Select slave 3
        end else 
            tempsel = '0;  // Reset tempsel to 0
    end

    // ** Assign Bridge Outputs **
    assign br.hresp = 2'b00;  // Always respond with OKAY (no error)

endmodule