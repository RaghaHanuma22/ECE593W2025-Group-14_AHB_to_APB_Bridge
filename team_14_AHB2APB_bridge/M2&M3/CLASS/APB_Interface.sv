///////////////////////////////////////////////////////////////////////////////////////////
// Module: APB Interface
// 
// Description:
// This module represents an APB interface that facilitates communication between the APB bus
// and other components. It passes through key control signals such as Pwrite, Pselx, and Penable.
// Additionally, it handles read operations by generating a random read data value when a read
// operation is initiated.
// 
// Functionality:
// - Directly passes Pwrite, Pselx, Penable, Paddr, and Pwdata to their respective outputs.
// - Generates a random read data value when Penable is asserted and Pwrite is low.
// - Holds the generated read data for the duration of the read operation.
//
///////////////////////////////////////////////////////////////////////////////////////////

module APB_Interface(input logic Hclk, Pwrite,input logic [2:0] Pselx,input logic Penable,input logic [31:0] Paddr,Pwdata,output logic Pwriteout,output logic [2:0] Pselxout,output logic Penableout,output logic [31:0] Paddrout,Pwdataout,Prdata);

assign Penableout=Penable;
assign Pselxout=Pselx;
assign Pwriteout=Pwrite;
assign Paddrout=Paddr;
assign Pwdataout=Pwdata;

logic [31:0] Prdata_reg; // New register to hold the value of Prdata

always_ff @(posedge Hclk)
 begin
  if (~Pwrite && Penable)
   Prdata_reg=($random)%256; // Update Prdata_reg when a new read operation starts
  else
   Prdata_reg=0; // Reset Prdata_reg when not reading
 end

assign Prdata = Prdata_reg; // Prdata now holds its value for the entire duration of the read operation

endmodule
