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

module AHB_Master(ahb2apb_interface.ahb_master hm,input logic clk);


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


task burst_read();
int i;
@(posedge clk);
hm.hwrite=0;
hm.htrans=2'b10;
hm.hsize=3'b010;
hm.hburst=3'b011;
hm.hreadyin=1;
hm.haddr=32'h8000_00C0;

for(i=0;i<4;i++)begin
  @(posedge clk);
  hm.htrans=2'b11;
  hm.haddr=hm.haddr+4;
  hm.data_read=32'hA300_1111+i;
end

@(posedge clk);
hm.htrans=2'b00;

endtask

task burst_write();
int i;
@(posedge clk);
hm.hwrite=1;
hm.htrans=2'b10;
hm.hsize=3'b010;
hm.hburst=3'b011;
hm.hreadyin=1;
hm.haddr=32'h8000_00FF;

for(i=0;i<4;i++)begin
  @(posedge clk);
  hm.htrans=2'b11;
  hm.hwdata=32'hA300_1111+i;
  hm.haddr=hm.haddr+4;
end

@(posedge clk);
hm.htrans=2'b00;

endtask


endmodule