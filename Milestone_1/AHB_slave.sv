///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Slave Interface
// 
// Description:
// This module implements the AHB slave interface with address pipelining and
// valid/tempselx generation logic
///////////////////////////////////////////////////////////////////////////////////////////

module AHB_slave_interface (
    ahb2apb_interface.bridge br,    
    input  logic             clk,   
    input  logic             rst_n, 
    output logic [31:0]      haddr1, haddr2,   
    output logic [31:0]      hwdata1, hwdata2,  
    output logic             valid,    
    output logic             hwritereg, 
    output logic [2:0]       tempselx 
);

    // Address pipelining
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            haddr1 <= '0;
            haddr2 <= '0;
        end
        else begin
            haddr1 <= br.haddr;
            haddr2 <= haddr1;
        end
    end

    // Data pipelining
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            hwdata1 <= '0;
            hwdata2 <= '0;
        end
        else begin
            hwdata1 <= br.hwdata;
            hwdata2 <= hwdata1;
        end
    end

    // Write signal pipelining
    always_ff @(posedge clk) begin
        if (!rst_n)
            hwritereg <= '0;
        else
            hwritereg <= br.hwrite;
    end

    // Valid generation logic
    always_comb begin
        valid = '0;
        if (rst_n && br.hreadyin && 
            (br.haddr >= 32'h8000_0000 && br.haddr < 32'h8C00_0000) && 
            (br.htrans == 2'b10 || br.htrans == 2'b11)) begin
            valid = 1'b1;
        end
    end

    // Tempselx generation logic
    always_comb begin
        tempselx = '0;
        if (rst_n) begin
            if (br.haddr >= 32'h8000_0000 && br.haddr < 32'h8400_0000)
                tempselx = 3'b001;
            else if (br.haddr >= 32'h8400_0000 && br.haddr < 32'h8800_0000)
                tempselx = 3'b010;
            else if (br.haddr >= 32'h8800_0000 && br.haddr < 32'h8C00_0000)
                tempselx = 3'b100;
        end
    end

    // Assign bridge outputs
    assign br.hrdata = br.prdata;
    assign br.hresp = 2'b00;

endmodule