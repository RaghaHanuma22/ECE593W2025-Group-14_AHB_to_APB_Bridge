///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Master
// 
// Description:
// This module is a non-synthesizable module being designed to mimic the
// behavior of AHB master to drive signals to the AHB to APB bridge
// 
// Interfaces:
// - interface.sv
// 
// 
///////////////////////////////////////////////////////////////////////////////////////////

module AHB_Master(ahb2apb_interface.ahb_master hm,clk);


task single_read();

  @(posedge clk);
    hm.hwrite=0;
    hm.htrans=2'b10;
    hm.hsize=3'b000;
    hm.hburst=3'b000;
    hm.hreadyin=1;
    hm.haddr=32'h8000_00A2;

  @(posedge clk);
    hm.htrans=2'b00;
    hm.data_read=32'h0000_FFFF; //to be replaced by hrdata upon controller completion
  

endtask


task single_write();
  @(posedge clk);
    hm.hwrite=1;
    hm.htrans=2'b10;
    hm.hsize=3'b000;
    hm.hburst=3'b000;
    hm.hreadyin=1;
    hm.haddr=32'h8000_0001;
  @(posedge clk)
    hm.htrans=2'b00;
    hm.hwdata=32'hA300_1111;
endtask


endmodule