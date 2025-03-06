///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Slave Interface
//
// Description:
// This module implements an AHB slave interface that captures and processes transactions
// from an AHB master. It includes pipelined logic for address, data, and control signals,
// as well as logic for validity checks and selection signals.
//
// Features:
// - Pipelined storage for address and write data.
// - Valid signal generation based on address range and transaction type.
// - Selection logic for different address regions.
// - Pass-through read data and response signal.
///////////////////////////////////////////////////////////////////////////////////////////

module AHB_slave_interface(
    input  logic        Hclk,       // AHB clock
    input  logic        Hresetn,    // Active-low reset
    input  logic        Hwrite,     // Write enable signal
    input  logic        Hreadyin,   // Ready input signal
    input  logic [1:0]  Htrans,     // Transfer type
    input  logic [31:0] Haddr,      // Address bus
    input  logic [31:0] Hwdata,     // Write data bus
    input  logic [31:0] Prdata,     // Read data from peripheral
    
    output logic        valid,      // Valid signal for transaction
    output logic [31:0] Haddr1,     // Pipelined address stage 1
    output logic [31:0] Haddr2,     // Pipelined address stage 2
    output logic [31:0] Hwdata1,    // Pipelined write data stage 1
    output logic [31:0] Hwdata2,    // Pipelined write data stage 2
    output logic [31:0] Hrdata,     // Read data output
    output logic        Hwritereg,  // Registered write enable signal
    output logic [2:0]  tempselx,   // Selection signal for different address ranges
    output logic [1:0]  Hresp       // Response signal (always OKAY)
);

//-----------------------------------------------------------------------------------------
// Pipeline Logic for Address, Data, and Control Signals
//-----------------------------------------------------------------------------------------

// Address Pipelining
always_ff @(posedge Hclk) begin
    if (~Hresetn) begin
        Haddr1 <= 0;
        Haddr2 <= 0;
    end else begin
        Haddr1 <= Haddr;
        Haddr2 <= Haddr1;
    end
end

// Write Data Pipelining
always_ff @(posedge Hclk) begin
    if (~Hresetn) begin
        Hwdata1 <= 0;
        Hwdata2 <= 0;
    end else begin
        Hwdata1 <= Hwdata;
        Hwdata2 <= Hwdata1;
    end
end

// Write Register Latching
always_ff @(posedge Hclk) begin
    if (~Hresetn)
        Hwritereg <= 0;
    else
        Hwritereg <= Hwrite;
end

//-----------------------------------------------------------------------------------------
// Valid Signal Generation
//-----------------------------------------------------------------------------------------

always_comb begin
    valid = 0;
    if (Hresetn && Hreadyin && (Haddr >= 32'h8000_0000 && Haddr < 32'h8C00_0000) && 
        (Htrans == 2'b10 || Htrans == 2'b11)) 
        valid = 1;
end

//-----------------------------------------------------------------------------------------
// Selection Logic (tempselx) Based on Address Ranges
//-----------------------------------------------------------------------------------------

always_comb begin
    tempselx = 3'b000;
    if (Hresetn) begin
        if (Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000)
            tempselx = 3'b001;
        else if (Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000)
            tempselx = 3'b010;
        else if (Haddr >= 32'h8800_0000 && Haddr < 32'h8C00_0000)
            tempselx = 3'b100;
    end
end

//-----------------------------------------------------------------------------------------
// Output Assignments
//-----------------------------------------------------------------------------------------

assign Hrdata = Prdata;  // Direct pass-through of read data
assign Hresp  = 2'b00;   // Always OKAY response

endmodule
