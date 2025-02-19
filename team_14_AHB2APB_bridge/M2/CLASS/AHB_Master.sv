///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Master
// 
// Description:
// This module is a non-synthesizable module designed to mimic the behavior of an AHB master.
// It drives signals to the AHB-to-APB bridge for simulation and verification purposes.
// The module includes tasks for single read/write and burst read/write operations.
// 
// 
// Tasks:
// - single_read: Performs a single read operation from a specified address.
// - single_write: Performs a single write operation to a specified address.
// 
///////////////////////////////////////////////////////////////////////////////////////////


module AHB_Master(input logic Hclk,Hresetn,input logic [1:0] Hresp,input logic [31:0] Hrdata, output logic Hwrite,Hreadyin,input logic Hreadyout, output logic [1:0] Htrans, output logic [31:0] Hwdata,Haddr);

logic [2:0] Hburst;
logic [2:0] Hsize;



task single_write();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=1;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_0001;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
    Hwdata=8'hA3;
   end 
 end
endtask


task single_read();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=0;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_00A2;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
   end 
 end
endtask


endmodule
