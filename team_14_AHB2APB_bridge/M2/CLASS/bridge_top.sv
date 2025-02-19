///////////////////////////////////////////////////////////////////////////////////////////
// Module: Top module
// 
// Description:
// Top-level module for an AHB-to-APB bridge
// This module integrates the AHB slave interface, APB FSM controller, and APB interface.
// It handles the conversion of AHB transactions to APB transactions.
//
///////////////////////////////////////////////////////////////////////////////////////////

`include "APB_Interface.sv"
`include "APB_Controller.sv"
`include "AHB_Slave_Interface.sv"
`include "AHB_Master.sv"

module Bridge_Top(input logic Hclk,Hresetn,Hwrite,Hreadyin, output logic Hreadyout,input logic [31:0] Hwdata,Haddr,input logic [1:0] Htrans,input logic [31:0] Prdata,output logic Penable,Pwrite,output logic [2:0] Pselx,output logic [31:0] Paddr,
output logic [31:0] Pwdata,output logic [1:0] Hresp,output logic [31:0] Hrdata);

//////////INTERMEDIATE SIGNALS

logic valid;
logic [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
logic Hwritereg;
logic [2:0] tempselx;

//////////MODULE INSTANTIATIONS
AHB_slave_interface AHBSlave (Hclk,Hresetn,Hwrite,Hreadyin,Htrans,Haddr,Hwdata,Prdata,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,Hwritereg,tempselx,Hresp);

APB_FSM_Controller APBControl ( Hclk,Hresetn,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwritereg,tempselx,Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);

// Instantiate APB_Interface module
logic Pwriteout, Penableout;
logic [2:0] Pselxout;
logic [31:0] Pwdataout, Paddrout;
logic [31:0] Prdataout;

APB_Interface APBIntf (Hclk,Pwrite, Pselx, Penable, Paddr, Pwdata, Pwriteout, Pselxout, Penableout, Paddrout, Pwdataout, Prdataout);

endmodule
